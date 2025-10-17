#!/usr/bin/env python3
"""
Extrude a convex hull upwards by 1mm and save as STL.

This script takes a convex hull (list of 2D points) and creates a 3D STL file
by extruding it vertically by 1mm.
"""

import numpy as np
import sys
import os
from stl import mesh
import argparse


def create_triangular_faces(hull_points, height=1.0):
    """
    Create triangular faces for the extruded hull.
    
    Args:
        hull_points: List of (x, y) points forming the convex hull
        height: Height of extrusion in mm (default: 1.0)
    
    Returns:
        List of triangular faces as numpy arrays
    """
    faces = []
    n_points = len(hull_points)
    
    # Create bottom face (triangulate the convex hull)
    for i in range(1, n_points - 1):
        # Each triangle uses the first point and two consecutive points
        face = np.array([
            [hull_points[0][0], hull_points[0][1], 0.0],           # First point
            [hull_points[i][0], hull_points[i][1], 0.0],           # Current point
            [hull_points[i + 1][0], hull_points[i + 1][1], 0.0]    # Next point
        ])
        faces.append(face)
    
    # Create top face (same triangulation but at height)
    for i in range(1, n_points - 1):
        face = np.array([
            [hull_points[0][0], hull_points[0][1], height],        # First point
            [hull_points[i + 1][0], hull_points[i + 1][1], height], # Next point (reversed for correct normal)
            [hull_points[i][0], hull_points[i][1], height]         # Current point
        ])
        faces.append(face)
    
    # Create side faces (connecting bottom to top)
    for i in range(n_points):
        next_i = (i + 1) % n_points
        
        # Each side face is a quad split into two triangles
        # Triangle 1
        face1 = np.array([
            [hull_points[i][0], hull_points[i][1], 0.0],           # Bottom current
            [hull_points[next_i][0], hull_points[next_i][1], 0.0], # Bottom next
            [hull_points[i][0], hull_points[i][1], height]         # Top current
        ])
        faces.append(face1)
        
        # Triangle 2
        face2 = np.array([
            [hull_points[next_i][0], hull_points[next_i][1], 0.0], # Bottom next
            [hull_points[next_i][0], hull_points[next_i][1], height], # Top next
            [hull_points[i][0], hull_points[i][1], height]         # Top current
        ])
        faces.append(face2)
    
    return faces


def create_stl_from_hull(hull_points, height=1.0, output_path="extruded_hull.stl"):
    """
    Create an STL file from a convex hull by extruding it vertically.
    
    Args:
        hull_points: List of (x, y) points forming the convex hull
        height: Height of extrusion in mm (default: 1.0)
        output_path: Path where to save the STL file
    """
    print(f"[HULL] Creating STL from convex hull with {len(hull_points)} vertices...")
    print(f"[MEASURE] Extrusion height: {height}mm")
    
    # Create triangular faces
    faces = create_triangular_faces(hull_points, height)
    
    # Create the mesh
    extruded_mesh = mesh.Mesh(np.zeros(len(faces), dtype=mesh.Mesh.dtype))
    
    # Fill the mesh with our faces
    for i, face in enumerate(faces):
        extruded_mesh.vectors[i] = face
    
    # Save the STL file
    extruded_mesh.save(output_path)
    print(f"[OK] STL saved to: {output_path}")
    
    # Calculate and print some stats
    volume = extruded_mesh.get_mass_properties()[0]
    print(f"[ANALYSIS] Extruded volume: {volume:.2f} mm³")
    print(f"[ANALYSIS] Surface area: {extruded_mesh.areas.sum():.2f} mm²")


def load_hull_from_file(file_path):
    """
    Load convex hull points from a text file.
    Expected format: one point per line as "x,y" or "x y"
    """
    points = []
    try:
        with open(file_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#'):
                    # Try comma-separated first, then space-separated
                    if ',' in line:
                        x, y = line.split(',', 1)
                    else:
                        x, y = line.split()
                    points.append((float(x), float(y)))
    except Exception as e:
        raise ValueError(f"Error reading hull file {file_path}: {e}")
    
    if len(points) < 3:
        raise ValueError(f"Need at least 3 points for a convex hull, got {len(points)}")
    
    print(f"[FILE] Loaded {len(points)} hull points from {file_path}")
    return points


def main():
    parser = argparse.ArgumentParser(description='Extrude a convex hull upwards by 1mm and save as STL')
    parser.add_argument('hull_file', help='File containing convex hull points (x,y format)')
    parser.add_argument('-o', '--output', default='extruded_hull.stl', 
                       help='Output STL file path (default: extruded_hull.stl)')
    parser.add_argument('--height', type=float, default=1.0,
                       help='Extrusion height in mm (default: 1.0)')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.hull_file):
        print(f"[ERROR] Error: Hull file not found: {args.hull_file}")
        sys.exit(1)
    
    try:
        # Load hull points
        hull_points = load_hull_from_file(args.hull_file)
        
        # Create STL
        create_stl_from_hull(hull_points, args.height, args.output)
        
        print(f"\n[OK] Successfully created extruded STL: {args.output}")
        
    except Exception as e:
        print(f"[ERROR] Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
