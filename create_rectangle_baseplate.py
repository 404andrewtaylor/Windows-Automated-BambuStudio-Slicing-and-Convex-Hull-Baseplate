#!/usr/bin/env python3
"""
Create a simple rectangle baseplate STL as a fallback when hull generation fails.
Rectangle dimensions: x = hull_width, y = 180mm, z = 1mm
"""

import numpy as np
from stl import mesh


def create_rectangle_stl(width_mm, height_mm=180.0, thickness_mm=1.0, output_path=None):
    """
    Create a simple rectangular baseplate STL.
    
    Args:
        width_mm: Width of rectangle (x dimension) in mm
        height_mm: Height of rectangle (y dimension) in mm (default 180mm)
        thickness_mm: Thickness of rectangle (z dimension) in mm (default 1mm)
        output_path: Path to save STL file
    
    Returns:
        Path to created STL file
    """
    if output_path is None:
        output_path = "rectangle_baseplate.stl"
    
    # Create vertices for a rectangular box
    # Bottom face (z=0)
    vertices = np.array([
        [0, 0, 0],                    # 0: bottom-left-front
        [width_mm, 0, 0],             # 1: bottom-right-front
        [width_mm, height_mm, 0],     # 2: bottom-right-back
        [0, height_mm, 0],            # 3: bottom-left-back
        [0, 0, thickness_mm],         # 4: top-left-front
        [width_mm, 0, thickness_mm],  # 5: top-right-front
        [width_mm, height_mm, thickness_mm],  # 6: top-right-back
        [0, height_mm, thickness_mm], # 7: top-left-back
    ])
    
    # Define faces (triangles) for the rectangular box
    # Each face is two triangles
    faces = np.array([
        # Bottom face (z=0)
        [0, 1, 2],
        [0, 2, 3],
        # Top face (z=thickness)
        [4, 7, 6],
        [4, 6, 5],
        # Front face (y=0)
        [0, 4, 5],
        [0, 5, 1],
        # Back face (y=height)
        [3, 2, 6],
        [3, 6, 7],
        # Left face (x=0)
        [0, 3, 7],
        [0, 7, 4],
        # Right face (x=width)
        [1, 5, 6],
        [1, 6, 2],
    ])
    
    # Create the mesh
    rectangle_mesh = mesh.Mesh(np.zeros(faces.shape[0], dtype=mesh.Mesh.dtype))
    for i, face in enumerate(faces):
        for j in range(3):
            rectangle_mesh.vectors[i][j] = vertices[face[j]]
    
    # Save to file
    rectangle_mesh.save(output_path)
    print(f"[FALLBACK] Created rectangle baseplate STL: {output_path}")
    print(f"[FALLBACK] Dimensions: {width_mm}mm x {height_mm}mm x {thickness_mm}mm")
    
    return output_path


if __name__ == "__main__":
    # Test
    create_rectangle_stl(100.0, 180.0, 1.0, "test_rectangle.stl")

