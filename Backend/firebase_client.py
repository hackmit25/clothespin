import firebase_admin
from firebase_admin import credentials, firestore
from typing import Optional, List, Dict, Any
import json
from datetime import datetime
from config import settings
from models import ClothingItem, ClothingItemCreate, ClothingItemUpdate

class FirebaseClient:
    def __init__(self):
        self.db = None
        self._initialize_firebase()
    
    def _initialize_firebase(self):
        """Initialize Firebase Admin SDK"""
        try:
            # Check if Firebase is already initialized
            if not firebase_admin._apps:
                # Create credentials from environment variables
                cred_dict = {
                    "type": "service_account",
                    "project_id": settings.FIREBASE_PROJECT_ID,
                    "private_key_id": settings.FIREBASE_PRIVATE_KEY_ID,
                    "private_key": settings.FIREBASE_PRIVATE_KEY,
                    "client_email": settings.FIREBASE_CLIENT_EMAIL,
                    "client_id": settings.FIREBASE_CLIENT_ID,
                    "auth_uri": settings.FIREBASE_AUTH_URI,
                    "token_uri": settings.FIREBASE_TOKEN_URI,
                }
                
                cred = credentials.Certificate(cred_dict)
                firebase_admin.initialize_app(cred)
            
            self.db = firestore.client()
            print("Firebase initialized successfully")
            print(f"Connected to project: {self.db.project}")
            
        except Exception as e:
            print(f"Error initializing Firebase: {e}")
            raise e
    
    async def create_clothing_item(self, item_data: ClothingItemCreate, image_path: str = None) -> str:
        """Create a new clothing item in Firestore"""
        try:
            doc_data = {
                "brand": item_data.brand,
                "category": item_data.category,
                "color": item_data.color,
                "material": item_data.material,
                "style": item_data.style,
                "size": item_data.size,
                "image_path": image_path,
                "metadata": item_data.metadata or {},
                "times_used": item_data.times_used or 0,
                "last_time_used": item_data.last_time_used,
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            }
            
            # Remove None values
            doc_data = {k: v for k, v in doc_data.items() if v is not None}
            
            doc_ref = self.db.collection('clothing_items').add(doc_data)
            item_id = doc_ref[1].id
            
            print(f"Created clothing item with ID: {item_id}")
            return item_id
            
        except Exception as e:
            print(f"Error creating clothing item: {e}")
            raise e
    
    async def get_clothing_item(self, item_id: str) -> Optional[ClothingItem]:
        """Get a clothing item by ID"""
        try:
            doc_ref = self.db.collection('clothing_items').document(item_id)
            doc = doc_ref.get()
            
            if doc.exists:
                data = doc.to_dict()
                data['id'] = doc.id
                return ClothingItem(**data)
            return None
            
        except Exception as e:
            print(f"Error getting clothing item: {e}")
            raise e
    
    async def update_clothing_item(self, item_id: str, update_data: ClothingItemUpdate) -> bool:
        """Update a clothing item"""
        try:
            doc_ref = self.db.collection('clothing_items').document(item_id)
            
            update_dict = update_data.dict(exclude_unset=True)
            update_dict['updated_at'] = datetime.utcnow()
            
            doc_ref.update(update_dict)
            print(f"Updated clothing item: {item_id}")
            return True
            
        except Exception as e:
            print(f"Error updating clothing item: {e}")
            raise e
    
    async def get_clothing_items_by_brand(self, brand: str) -> List[ClothingItem]:
        """Get all clothing items for a specific brand"""
        try:
            items = []
            docs = self.db.collection('clothing_items').where('brand', '==', brand).stream()
            
            for doc in docs:
                data = doc.to_dict()
                data['id'] = doc.id
                items.append(ClothingItem(**data))
            
            return items
            
        except Exception as e:
            print(f"Error getting clothing items by brand: {e}")
            raise e
    
    async def get_all_clothing_items(self) -> List[ClothingItem]:
        """Get all clothing items"""
        try:
            items = []
            docs = self.db.collection('clothing_items').stream()
            
            for doc in docs:
                data = doc.to_dict()
                data['id'] = doc.id
                items.append(ClothingItem(**data))
            
            return items
            
        except Exception as e:
            print(f"Error getting all clothing items: {e}")
            raise e
    
    async def delete_clothing_item(self, item_id: str) -> bool:
        """Delete a clothing item"""
        try:
            self.db.collection('clothing_items').document(item_id).delete()
            print(f"Deleted clothing item: {item_id}")
            return True
            
        except Exception as e:
            print(f"Error deleting clothing item: {e}")
            raise e

# Global instance
firebase_client = FirebaseClient()
