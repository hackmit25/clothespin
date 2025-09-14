from fastapi import FastAPI, File, UploadFile, Form, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from typing import Optional, List
import os
import asyncio
from datetime import datetime

from models import (
    ClothingItem, 
    ClothingItemCreate, 
    ClothingItemUpdate, 
    ImageUploadResponse,
    SimilarityMatch
)
from firebase_client import firebase_client
from marqo_client import marqo_client
from image_processor import image_processor
from config import settings

# Initialize FastAPI app
app = FastAPI(
    title="Fashion Sustainability API",
    description="API for clothing item analysis and management using Firebase and Marqo",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup_event():
    """Initialize services on startup"""
    print("Starting Fashion Sustainability API...")
    # Ensure upload directory exists
    os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
    print("API startup complete")

@app.get("/")
async def root():
    """Root endpoint"""
    return {"message": "Fashion Sustainability API", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.utcnow()}

@app.post("/upload-clothing", response_model=ImageUploadResponse)
async def upload_clothing_item(
    image: UploadFile = File(...),
    brand: str = Form(...),
    category: Optional[str] = Form(None),
    color: Optional[str] = Form(None),
    material: Optional[str] = Form(None),
    style: Optional[str] = Form(None),
    size: Optional[str] = Form(None)
):
    """
    Upload a clothing item image and either create a new entry or match to existing one
    """
    try:
        # Save uploaded image
        image_path = await image_processor.save_uploaded_image(image)
        
        try:
            # Process image for better analysis
            processed_image_path = image_processor.process_image_for_analysis(image_path)
            
            # Extract basic metadata
            image_metadata = image_processor.extract_basic_metadata(processed_image_path)
            
            # Prepare item data
            item_data = ClothingItemCreate(
                brand=brand,
                category=category,
                color=color,
                material=material,
                style=style,
                size=size,
                metadata=image_metadata
            )
            
            # Search for similar items using Marqo
            similar_items = await marqo_client.search_similar_items(
                image_path=processed_image_path,
                brand=brand,
                limit=5
            )
            
            # Check if we have a good match
            best_match = None
            if similar_items and similar_items[0].similarity_score >= settings.SIMILARITY_THRESHOLD:
                best_match = similar_items[0]
            
            if best_match:
                # Update existing item with new image
                existing_item = await firebase_client.get_clothing_item(best_match.item_id)
                if existing_item:
                    # Update the item with new image path
                    update_data = ClothingItemUpdate(
                        metadata={**existing_item.metadata, "latest_image": image_path}
                    )
                    await firebase_client.update_clothing_item(best_match.item_id, update_data)
                    
                    # Update Marqo index with new image
                    await marqo_client.update_item(
                        best_match.item_id, 
                        processed_image_path, 
                        item_data.dict()
                    )
                    
                    # Clean up processed image
                    if processed_image_path != image_path:
                        image_processor.cleanup_file(processed_image_path)
                    
                    return ImageUploadResponse(
                        success=True,
                        message=f"Matched existing item with {best_match.similarity_score:.2f} similarity",
                        item_id=best_match.item_id,
                        is_new_item=False,
                        similarity_score=best_match.similarity_score,
                        matched_item_id=best_match.item_id
                    )
            
            # Create new item
            item_id = await firebase_client.create_clothing_item(item_data, image_path)
            
            # Add to Marqo index
            await marqo_client.add_clothing_item(
                item_id, 
                processed_image_path, 
                item_data.dict()
            )
            
            # Clean up processed image
            if processed_image_path != image_path:
                image_processor.cleanup_file(processed_image_path)
            
            return ImageUploadResponse(
                success=True,
                message="Created new clothing item",
                item_id=item_id,
                is_new_item=True,
                similarity_score=similar_items[0].similarity_score if similar_items else None,
                matched_item_id=None
            )
            
        except Exception as e:
            # Clean up image file on error
            image_processor.cleanup_file(image_path)
            raise e
            
    except Exception as e:
        print(f"Error in upload_clothing_item: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/clothing-items", response_model=List[ClothingItem])
async def get_all_clothing_items():
    """Get all clothing items"""
    try:
        items = await firebase_client.get_all_clothing_items()
        return items
    except Exception as e:
        print(f"Error getting clothing items: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/clothing-items/{item_id}", response_model=ClothingItem)
async def get_clothing_item(item_id: str):
    """Get a specific clothing item by ID"""
    try:
        item = await firebase_client.get_clothing_item(item_id)
        if not item:
            raise HTTPException(status_code=404, detail="Clothing item not found")
        return item
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error getting clothing item: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/clothing-items/brand/{brand}", response_model=List[ClothingItem])
async def get_clothing_items_by_brand(brand: str):
    """Get all clothing items for a specific brand"""
    try:
        items = await firebase_client.get_clothing_items_by_brand(brand)
        return items
    except Exception as e:
        print(f"Error getting clothing items by brand: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.put("/clothing-items/{item_id}", response_model=ClothingItem)
async def update_clothing_item(item_id: str, update_data: ClothingItemUpdate):
    """Update a clothing item"""
    try:
        # Check if item exists
        existing_item = await firebase_client.get_clothing_item(item_id)
        if not existing_item:
            raise HTTPException(status_code=404, detail="Clothing item not found")
        
        # Update in Firebase
        success = await firebase_client.update_clothing_item(item_id, update_data)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to update clothing item")
        
        # Update in Marqo if image path is provided
        if existing_item.image_path:
            await marqo_client.update_item(
                item_id,
                existing_item.image_path,
                {**existing_item.dict(), **update_data.dict(exclude_unset=True)}
            )
        
        # Return updated item
        updated_item = await firebase_client.get_clothing_item(item_id)
        return updated_item
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error updating clothing item: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/clothing-items/{item_id}")
async def delete_clothing_item(item_id: str):
    """Delete a clothing item"""
    try:
        # Check if item exists
        existing_item = await firebase_client.get_clothing_item(item_id)
        if not existing_item:
            raise HTTPException(status_code=404, detail="Clothing item not found")
        
        # Delete from Firebase
        success = await firebase_client.delete_clothing_item(item_id)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to delete clothing item")
        
        # Delete from Marqo
        await marqo_client.delete_item(item_id)
        
        # Clean up image file
        if existing_item.image_path and os.path.exists(existing_item.image_path):
            image_processor.cleanup_file(existing_item.image_path)
        
        return {"message": "Clothing item deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error deleting clothing item: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/search-similar", response_model=List[SimilarityMatch])
async def search_similar_items(
    image: UploadFile = File(...),
    brand: Optional[str] = Form(None),
    limit: int = Form(5)
):
    """Search for similar clothing items using image"""
    try:
        # Save uploaded image
        image_path = await image_processor.save_uploaded_image(image)
        
        try:
            # Process image for better analysis
            processed_image_path = image_processor.process_image_for_analysis(image_path)
            
            # Search for similar items
            similar_items = await marqo_client.search_similar_items(
                image_path=processed_image_path,
                brand=brand,
                limit=limit
            )
            
            # Clean up files
            image_processor.cleanup_file(image_path)
            if processed_image_path != image_path:
                image_processor.cleanup_file(processed_image_path)
            
            return similar_items
            
        except Exception as e:
            # Clean up image file on error
            image_processor.cleanup_file(image_path)
            raise e
            
    except Exception as e:
        print(f"Error in search_similar_items: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
