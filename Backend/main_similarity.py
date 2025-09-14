from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional, List
import os
import uuid
from datetime import datetime
import numpy as np
from PIL import Image
import torch
import torchvision.transforms as transforms
from torchvision.models import resnet50, ResNet50_Weights

from models import (
    ClothingItem, 
    ClothingItemCreate, 
    ClothingItemUpdate, 
    ImageUploadResponse
)
from firebase_client import firebase_client
from image_processor import image_processor
from config import settings

# Initialize FastAPI app
app = FastAPI(
    title="Fashion Sustainability API (Image Similarity)",
    description="API for clothing item management using image similarity comparison",
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

class ImageSimilarityEngine:
    def __init__(self):
        self.model = None
        self.transform = None
        self._load_model()
    
    def _load_model(self):
        """Load ResNet50 for image feature extraction"""
        try:
            print("Loading ResNet50 for image similarity...")
            self.model = resnet50(weights=ResNet50_Weights.IMAGENET1K_V2)
            self.model.eval()
            
            # Image preprocessing
            self.transform = transforms.Compose([
                transforms.Resize(256),
                transforms.CenterCrop(224),
                transforms.ToTensor(),
                transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
            ])
            print("✅ ResNet50 model loaded successfully!")
        except Exception as e:
            print(f"Error loading ResNet50 model: {e}")
            raise e
    
    def extract_image_features(self, image_path: str) -> np.ndarray:
        """Extract features from an image"""
        try:
            image = Image.open(image_path).convert('RGB')
            input_tensor = self.transform(image).unsqueeze(0)
            
            with torch.no_grad():
                features = self.model(input_tensor)
                # Use the last layer before classification
                features = features.squeeze().numpy()
            
            return features
        except Exception as e:
            print(f"Error extracting features: {e}")
            return np.array([])
    
    def calculate_similarity(self, features1: np.ndarray, features2: np.ndarray) -> float:
        """Calculate cosine similarity between two feature vectors"""
        if len(features1) == 0 or len(features2) == 0:
            return 0.0
        
        # Normalize vectors
        norm1 = np.linalg.norm(features1)
        norm2 = np.linalg.norm(features2)
        
        if norm1 == 0 or norm2 == 0:
            return 0.0
        
        # Calculate cosine similarity
        similarity = np.dot(features1, features2) / (norm1 * norm2)
        return float(similarity)

# Global similarity engine
similarity_engine = ImageSimilarityEngine()

@app.on_event("startup")
async def startup_event():
    """Initialize services on startup"""
    print("Starting Fashion Sustainability API with Image Similarity...")
    # Ensure upload directory exists
    os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
    print("API startup complete")

@app.get("/")
async def root():
    """Root endpoint"""
    return {"message": "Fashion Sustainability API (Image Similarity)", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.utcnow()}

@app.post("/upload-clothing", response_model=ImageUploadResponse)
async def upload_clothing_item(image: UploadFile = File(...)):
    """
    Upload a clothing item image and find similar items using image similarity
    """
    try:
        # Save uploaded image
        image_path = await image_processor.save_uploaded_image(image)
        
        try:
            # Process image for better analysis
            processed_image_path = image_processor.process_image_for_analysis(image_path)
            
            # Extract features from the uploaded image
            print("🔍 Extracting image features for similarity comparison...")
            uploaded_features = similarity_engine.extract_image_features(processed_image_path)
            
            # Find similar items in the database
            similar_items = await find_similar_items(uploaded_features, threshold=0.7)
            
            if similar_items:
                # Found similar item - update it with new image
                best_match = similar_items[0]
                existing_item = await firebase_client.get_clothing_item(best_match['item_id'])
                
                if existing_item:
                    # Update the existing item with new image and increment usage
                    current_time = datetime.utcnow()
                    current_usage = existing_item.times_used or 0
                    
                    update_data = ClothingItemUpdate(
                        times_used=current_usage + 1,  # Increment usage counter
                        last_time_used=current_time,   # Update last used time
                        metadata={
                            **existing_item.metadata,
                            "latest_image": image_path,
                            "similarity_score": best_match['similarity'],
                            "matched_at": current_time.isoformat()
                        }
                    )
                    await firebase_client.update_clothing_item(best_match['item_id'], update_data)
                    
                    # Clean up processed image
                    if processed_image_path != image_path:
                        image_processor.cleanup_file(processed_image_path)
                    
                    return ImageUploadResponse(
                        success=True,
                        message=f"Matched existing item with {best_match['similarity']:.2f} similarity",
                        item_id=best_match['item_id'],
                        is_new_item=False,
                        similarity_score=best_match['similarity'],
                        matched_item_id=best_match['item_id']
                    )
            
            # No similar item found - create new item
            current_time = datetime.utcnow()
            item_data = ClothingItemCreate(
                brand="Unknown",  # User can update later
                category=None,    # User can update later
                color=None,       # User can update later
                material=None,    # User can update later
                style=None,       # User can update later
                size=None,        # User can update later
                times_used=1,     # First time used
                last_time_used=current_time,
                metadata={
                    "image_features": uploaded_features.tolist(),  # Store features for future comparison
                    "upload_timestamp": current_time.isoformat(),
                    "similarity_threshold": 0.7
                }
            )
            
            # Create new item in Firebase
            item_id = await firebase_client.create_clothing_item(item_data, image_path)
            
            # Clean up processed image
            if processed_image_path != image_path:
                image_processor.cleanup_file(processed_image_path)
            
            return ImageUploadResponse(
                success=True,
                message="Created new clothing item",
                item_id=item_id,
                is_new_item=True,
                similarity_score=similar_items[0]['similarity'] if similar_items else None,
                matched_item_id=None
            )
            
        except Exception as e:
            # Clean up image file on error
            image_processor.cleanup_file(image_path)
            raise e
            
    except Exception as e:
        print(f"Error in upload_clothing_item: {e}")
        raise HTTPException(status_code=500, detail=str(e))

async def find_similar_items(uploaded_features: np.ndarray, threshold: float = 0.7) -> List[dict]:
    """Find similar items in the database"""
    try:
        all_items = await firebase_client.get_all_clothing_items()
        similar_items = []
        
        for item in all_items:
            if item.metadata and "image_features" in item.metadata:
                stored_features = np.array(item.metadata["image_features"])
                similarity = similarity_engine.calculate_similarity(uploaded_features, stored_features)
                
                if similarity >= threshold:
                    similar_items.append({
                        "item_id": item.id,
                        "similarity": similarity,
                        "item": item
                    })
        
        # Sort by similarity (highest first)
        similar_items.sort(key=lambda x: x['similarity'], reverse=True)
        return similar_items
        
    except Exception as e:
        print(f"Error finding similar items: {e}")
        return []

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

@app.post("/find-similar")
async def find_similar_to_image(image: UploadFile = File(...), threshold: float = 0.7):
    """Find similar items to an uploaded image"""
    try:
        # Save uploaded image
        image_path = await image_processor.save_uploaded_image(image)
        
        try:
            # Process image
            processed_image_path = image_processor.process_image_for_analysis(image_path)
            
            # Extract features
            uploaded_features = similarity_engine.extract_image_features(processed_image_path)
            
            # Find similar items
            similar_items = await find_similar_items(uploaded_features, threshold)
            
            # Clean up files
            image_processor.cleanup_file(image_path)
            if processed_image_path != image_path:
                image_processor.cleanup_file(processed_image_path)
            
            return {
                "success": True,
                "similar_items": similar_items,
                "threshold": threshold
            }
            
        except Exception as e:
            image_processor.cleanup_file(image_path)
            raise e
            
    except Exception as e:
        print(f"Error in find_similar_to_image: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/clothing-items/most-used")
async def get_most_used_items(limit: int = 10):
    """Get the most frequently used clothing items"""
    try:
        items = await firebase_client.get_all_clothing_items()
        # Sort by times_used (descending) and then by last_time_used (descending)
        sorted_items = sorted(
            items, 
            key=lambda x: (x.times_used or 0, x.last_time_used or datetime.min), 
            reverse=True
        )
        return sorted_items[:limit]
    except Exception as e:
        print(f"Error getting most used items: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/clothing-items/recently-used")
async def get_recently_used_items(limit: int = 10):
    """Get recently used clothing items"""
    try:
        items = await firebase_client.get_all_clothing_items()
        # Filter items that have been used at least once
        used_items = [item for item in items if item.times_used and item.times_used > 0]
        # Sort by last_time_used (descending)
        sorted_items = sorted(
            used_items, 
            key=lambda x: x.last_time_used or datetime.min, 
            reverse=True
        )
        return sorted_items[:limit]
    except Exception as e:
        print(f"Error getting recently used items: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/clothing-items/usage-stats")
async def get_usage_statistics():
    """Get overall usage statistics"""
    try:
        items = await firebase_client.get_all_clothing_items()
        
        total_items = len(items)
        used_items = len([item for item in items if item.times_used and item.times_used > 0])
        total_usage = sum(item.times_used or 0 for item in items)
        
        # Most used item
        most_used = max(items, key=lambda x: x.times_used or 0) if items else None
        
        # Recently used (last 7 days)
        from datetime import timedelta
        week_ago = datetime.utcnow() - timedelta(days=7)
        recently_used = len([
            item for item in items 
            if item.last_time_used and item.last_time_used >= week_ago
        ])
        
        return {
            "total_items": total_items,
            "used_items": used_items,
            "unused_items": total_items - used_items,
            "total_usage_count": total_usage,
            "average_usage": round(total_usage / total_items, 2) if total_items > 0 else 0,
            "recently_used_week": recently_used,
            "most_used_item": {
                "id": most_used.id,
                "brand": most_used.brand,
                "times_used": most_used.times_used,
                "last_time_used": most_used.last_time_used
            } if most_used else None
        }
    except Exception as e:
        print(f"Error getting usage statistics: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
