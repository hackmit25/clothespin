#!/usr/bin/env python3
"""
Script to run the FastAPI application with image similarity features
"""
import uvicorn
from main_similarity import app

if __name__ == "__main__":
    uvicorn.run(
        "main_similarity:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
