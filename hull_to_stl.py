#!/usr/bin/env python3
"""
Complete pipeline: Extract convex hull from first 15 layers of gcode and create extruded STL.
"""

import sys
import os
import tempfile
import numpy as np
from stl import mesh
from extract_and_analyze import extract_gcode_from_3mf_file, parse_gcode_first_layer, compute_convex_hull
from extrude_hull_to_stl import create_stl_from_hull


def main():
    if len(sys.argv) != 4:
        print("Usage: python3 hull_to_stl.py <gcode_3mf_file> <output_stl_file> <original_stl_file>")
        print("Example: python3 hull_to_stl.py model.gcode.3mf extruded_hull.stl original_model.stl")
        sys.exit(1)
    
    gcode_3mf_path = sys.argv[1]
    output_stl_path = sys.argv[2]
    original_stl_path = sys.argv[3]
    
    if not os.path.exists(gcode_3mf_path):
        print(f"[ERROR] Error: File not found: {gcode_3mf_path}")
        sys.exit(1)
    
    if not os.path.exists(original_stl_path):
        print(f"[ERROR] Error: Original STL file not found: {original_stl_path}")
        sys.exit(1)
    
    try:
        print(f"[START] Starting hull extraction and STL creation...")
        print(f"[FILE] Input: {gcode_3mf_path}")
        print(f"[FILE] Output: {output_stl_path}")
        
        # Step 1: Extract gcode
        print("\n[PACKAGE] Step 1: Extracting gcode...")
        gcode_content = extract_gcode_from_3mf_file(gcode_3mf_path)
        
        # Step 2: Parse first 15 layers
        print("[SEARCH] Step 2: Analyzing first 15 layers...")
        first_layer_points = parse_gcode_first_layer(gcode_content)
        
        # Step 3: Compute convex hull
        print("[HULL] Step 3: Computing convex hull...")
        hull, hull_points = compute_convex_hull(first_layer_points)
        
        # Step 4: Create STL (no buffer applied - using exact convex hull)
        print("[CREATE] Step 4: Creating extruded STL...")
        create_stl_from_hull(hull_points, height=1.0, output_path=output_stl_path)
        
        print(f"\n[OK] Successfully created extruded STL: {output_stl_path}")
        print(f"[ANALYSIS] Hull vertices: {len(hull_points)}")
        print(f"[ANALYSIS] Extrusion height: 1.0mm")
        print(f"[ANALYSIS] No buffer applied - using exact convex hull")
        
    except Exception as e:
        print(f"[ERROR] Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
