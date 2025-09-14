import os
import uuid
from typing import Optional, Dict, Any
from PIL import Image
import aiofiles
from fastapi import UploadFile
from config import settings

class ImageProcessor:
    def __init__(self):
        self.upload_dir = settings.UPLOAD_DIR
        self.max_file_size = settings.MAX_FILE_SIZE
        self.allowed_extensions = {'.jpg', '.jpeg', '.png', '.bmp', '.tiff', '.webp'}
        self._ensure_upload_dir()
    
    def _ensure_upload_dir(self):
        """Create upload directory if it doesn't exist"""
        if not os.path.exists(self.upload_dir):
            os.makedirs(self.upload_dir)
            print(f"Created upload directory: {self.upload_dir}")
    
    def _validate_image(self, file: UploadFile) -> bool:
        """Validate uploaded image file"""
        # Check file size
        if file.size and file.size > self.max_file_size:
            raise ValueError(f"File size exceeds maximum allowed size of {self.max_file_size} bytes")
        
        # Check file extension
        if file.filename:
            file_ext = os.path.splitext(file.filename)[1].lower()
            if file_ext not in self.allowed_extensions:
                raise ValueError(f"File extension {file_ext} not allowed. Allowed extensions: {self.allowed_extensions}")
        
        return True
    
    async def save_uploaded_image(self, file: UploadFile) -> str:
        """Save uploaded image and return the file path"""
        try:
            # Validate image
            self._validate_image(file)
            
            # Generate unique filename
            file_ext = os.path.splitext(file.filename)[1].lower() if file.filename else '.jpg'
            unique_filename = f"{uuid.uuid4()}{file_ext}"
            file_path = os.path.join(self.upload_dir, unique_filename)
            
            # Save file
            async with aiofiles.open(file_path, 'wb') as f:
                content = await file.read()
                await f.write(content)
            
            # Validate that it's a valid image
            try:
                with Image.open(file_path) as img:
                    img.verify()
            except Exception as e:
                # Clean up invalid file
                if os.path.exists(file_path):
                    os.remove(file_path)
                raise ValueError(f"Invalid image file: {e}")
            
            print(f"Saved image to: {file_path}")
            return file_path
            
        except Exception as e:
            print(f"Error saving image: {e}")
            raise e
    
    def process_image_for_analysis(self, image_path: str) -> str:
        """Process image for better analysis (resize, normalize, etc.)"""
        try:
            with Image.open(image_path) as img:
                # Convert to RGB if necessary
                if img.mode != 'RGB':
                    img = img.convert('RGB')
                
                # Resize if too large (keep aspect ratio)
                max_size = 1024
                if max(img.size) > max_size:
                    img.thumbnail((max_size, max_size), Image.Resampling.LANCZOS)
                
                # Save processed image
                processed_path = image_path.replace('.', '_processed.')
                img.save(processed_path, 'JPEG', quality=95)
                
                return processed_path
                
        except Exception as e:
            print(f"Error processing image: {e}")
            return image_path  # Return original if processing fails
    
    def extract_basic_metadata(self, image_path: str) -> Dict[str, Any]:
        """Extract basic metadata from image"""
        try:
            with Image.open(image_path) as img:
                metadata = {
                    "width": img.width,
                    "height": img.height,
                    "format": img.format,
                    "mode": img.mode,
                    "file_size": os.path.getsize(image_path)
                }
                
                # Try to extract EXIF data
                if hasattr(img, '_getexif') and img._getexif():
                    exif_data = img._getexif()
                    if exif_data:
                        metadata["exif"] = dict(exif_data)
                
                return metadata
                
        except Exception as e:
            print(f"Error extracting metadata: {e}")
            return {}
    
    def cleanup_file(self, file_path: str):
        """Clean up temporary files"""
        try:
            if os.path.exists(file_path):
                os.remove(file_path)
                print(f"Cleaned up file: {file_path}")
        except Exception as e:
            print(f"Error cleaning up file {file_path}: {e}")

# Global instance
image_processor = ImageProcessor()
