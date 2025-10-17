#!/usr/bin/env python3
"""
Extract convex hull points from the analysis results and save to a file.
This is a helper script to get hull points from extract_and_analyze.py results.
"""

import sys
import os
import numpy as np
from extract_and_analyze import extract_gcode_from_3mf_file, parse_gcode_first_layer, compute_convex_hull


def extract_and_save_hull_points(gcode_3mf_path, output_file="hull_points.txt"):
    """
    Extract convex hull points from a .gcode.3mf file and save to text file.
    """
    print(f"[PROCESS] Processing: {gcode_3mf_path}")
    
    # Extract gcode
    gcode_content = extract_gcode_from_3mf_file(gcode_3mf_path)
    
    # Parse first layer
    first_layer_points = parse_gcode_first_layer(gcode_content)
    
    # Compute convex hull
    hull, hull_points = compute_convex_hull(first_layer_points)
    
    # Save hull points to file
    with open(output_file, 'w') as f:
        f.write("# Convex hull points (x,y format)\n")
        f.write(f"# Generated from: {gcode_3mf_path}\n")
        f.write(f"# Total points: {len(hull_points)}\n")
        for point in hull_points:
            f.write(f"{point[0]},{point[1]}\n")
    
    print(f"[SUCCESS] Hull points saved to: {output_file}")
    print(f"[INFO] Total hull vertices: {len(hull_points)}")
    
    return hull_points


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 extract_hull_points.py <gcode_3mf_file>")
        sys.exit(1)
    
    gcode_3mf_path = sys.argv[1]
    if not os.path.exists(gcode_3mf_path):
        print(f"❌ Error: File not found: {gcode_3mf_path}")
        sys.exit(1)
    
    # Extract and save hull points
    hull_points = extract_and_save_hull_points(gcode_3mf_path)
    
    print(f"\n🎯 Next step: Run 'python3 extrude_hull_to_stl.py hull_points.txt' to create STL")
