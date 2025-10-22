#!/usr/bin/env python3
"""
Create a simple icon for the Hull Baseplate Pipeline GUI.
This creates a basic icon.ico file that can be used by the application.
"""

import tkinter as tk
from tkinter import Canvas
from PIL import Image, ImageDraw
import os

def create_icon():
    """Create a simple icon for the application."""
    # Create a 64x64 icon
    size = 64
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw a 3D cube-like shape representing a baseplate
    # Baseplate (bottom)
    draw.rectangle([10, 50, 54, 58], fill=(100, 100, 100, 255))  # Gray baseplate
    
    # Model on top (simplified)
    draw.rectangle([20, 35, 44, 50], fill=(200, 200, 200, 255))  # Light gray model
    draw.rectangle([25, 30, 39, 35], fill=(150, 150, 150, 255))  # Darker gray top
    
    # Add some details
    draw.rectangle([15, 52, 49, 54], fill=(50, 50, 50, 255))  # Baseplate edge
    draw.rectangle([22, 37, 42, 39], fill=(100, 100, 100, 255))  # Model detail
    
    # Save as ICO file
    img.save('icon.ico', format='ICO', sizes=[(64, 64), (32, 32), (16, 16)])
    print("Icon created: icon.ico")

if __name__ == "__main__":
    try:
        create_icon()
    except ImportError:
        print("PIL (Pillow) not available. Creating a simple text-based icon instead.")
        # Create a simple text file as placeholder
        with open('icon.ico', 'w') as f:
            f.write("# Icon placeholder - replace with actual icon.ico file")
        print("Icon placeholder created: icon.ico")
