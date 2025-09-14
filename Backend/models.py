from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime

class ClothingItem(BaseModel):
    id: Optional[str] = None
    brand: str
    category: Optional[str] = None
    color: Optional[str] = None
    material: Optional[str] = None
    style: Optional[str] = None
    size: Optional[str] = None
    image_url: Optional[str] = None
    image_path: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None
    times_used: Optional[int] = 0
    last_time_used: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class ClothingItemCreate(BaseModel):
    brand: str
    category: Optional[str] = None
    color: Optional[str] = None
    material: Optional[str] = None
    style: Optional[str] = None
    size: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None
    times_used: Optional[int] = 0
    last_time_used: Optional[datetime] = None

class ClothingItemUpdate(BaseModel):
    category: Optional[str] = None
    color: Optional[str] = None
    material: Optional[str] = None
    style: Optional[str] = None
    size: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None
    times_used: Optional[int] = None
    last_time_used: Optional[datetime] = None

class ImageUploadResponse(BaseModel):
    success: bool
    message: str
    item_id: Optional[str] = None
    is_new_item: bool = False
    similarity_score: Optional[float] = None
    matched_item_id: Optional[str] = None

class SimilarityMatch(BaseModel):
    item_id: str
    similarity_score: float
    item_data: ClothingItem
