#!/usr/bin/env python3
"""
Full Pipeline: STL → Slice → Extract Hull → Create Hull STL → Slice Hull STL
Usage: python full_pipeline.py <input_stl_file>
"""

import os
import sys
import time
import json
import zipfile
import subprocess
from pathlib import Path
from datetime import datetime


def get_script_directory():
    """Get the directory containing this script."""
    return Path(__file__).parent.absolute()


def check_input_file(input_stl):
    """Check if input STL file exists and is valid."""
    if not os.path.exists(input_stl):
        print(f"[ERROR] Error: Input STL file not found: {input_stl}")
        return False
    
    if not input_stl.lower().endswith('.stl'):
        print(f"[ERROR] Error: Input file must be an STL file: {input_stl}")
        return False
    
    return True


def create_output_directory(stl_path):
    """Create output directory for pipeline results."""
    stl_path = os.path.abspath(stl_path)  # Convert to absolute path
    stl_dir = os.path.dirname(stl_path)
    stl_name = os.path.splitext(os.path.basename(stl_path))[0]
    output_dir = os.path.abspath(os.path.join(stl_dir, f"{stl_name}_pipeline"))
    
    os.makedirs(output_dir, exist_ok=True)
    return output_dir, stl_name


def slice_original_stl(input_stl, script_dir):
    """Slice the original STL file using platform-specific automation."""
    print("[STEP] Step 1: Slicing original STL...")
    print("   Running Bambu Studio automation...")
    
    # Change to script directory to ensure imports work
    original_cwd = os.getcwd()
    os.chdir(script_dir)
    
    try:
        # Add script directory to Python path
        import sys
        if script_dir not in sys.path:
            sys.path.insert(0, str(script_dir))
        
        # Import the appropriate automation module based on platform
        import platform
        if platform.system() == "Windows":
            from automation_windows import slice_stl_file
        elif platform.system() == "Darwin":
            from automation_mac import slice_stl_file
        else:
            print("[ERROR] Error: Unsupported platform. Only Windows and macOS are supported.")
            return False
        
        return slice_stl_file(input_stl)
    
    finally:
        os.chdir(original_cwd)


def find_generated_files(stl_path):
    """Find the generated .gcode.3mf file."""
    stl_path = os.path.abspath(stl_path)  # Convert to absolute path
    stl_dir = os.path.dirname(stl_path)
    stl_name = os.path.splitext(os.path.basename(stl_path))[0]
    gcode_3mf = os.path.abspath(os.path.join(stl_dir, f"{stl_name}.gcode.3mf"))
    
    if not os.path.exists(gcode_3mf):
        print(f"[ERROR] Error: Generated .gcode.3mf file not found: {gcode_3mf}")
        return None
    
    print(f"[OK] Found: {gcode_3mf}")
    return gcode_3mf


def create_hull_stl(gcode_3mf, output_dir, stl_name, script_dir, input_stl):
    """Create hull STL from gcode."""
    print("[HULL] Step 3: Extracting convex hull and creating hull STL...")
    
    # Convert all paths to absolute
    gcode_3mf = os.path.abspath(gcode_3mf)
    output_dir = os.path.abspath(output_dir)
    script_dir = os.path.abspath(script_dir)
    input_stl = os.path.abspath(input_stl)
    
    # Change to script directory and activate virtual environment
    original_cwd = os.getcwd()
    os.chdir(script_dir)
    
    try:
        # Activate virtual environment
        if os.name == 'nt':  # Windows
            activate_script = os.path.abspath(os.path.join(script_dir, "venv", "Scripts", "activate.bat"))
            python_exe = os.path.abspath(os.path.join(script_dir, "venv", "Scripts", "python.exe"))
        else:  # macOS/Linux
            activate_script = os.path.abspath(os.path.join(script_dir, "venv", "bin", "activate"))
            python_exe = os.path.abspath(os.path.join(script_dir, "venv", "bin", "python"))
        
        if not os.path.exists(python_exe):
            print("[ERROR] Error: Virtual environment not found. Please run setup first.")
            return False
        
        # Create hull STL
        hull_stl = os.path.abspath(os.path.join(output_dir, f"{stl_name}_hull.stl"))
        
        # Run hull_to_stl.py
        cmd = [python_exe, "hull_to_stl.py", gcode_3mf, hull_stl, input_stl]
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode != 0:
            print(f"[ERROR] Error: Failed to create hull STL: {result.stderr}")
            return False
        
        print(f"[OK] Created hull STL: {hull_stl}")
        return hull_stl
        
    finally:
        os.chdir(original_cwd)


def slice_naive_baseplate(hull_stl, output_dir, stl_name, script_dir):
    """Slice the hull STL without any movement to create naive baseplate."""
    print("   Creating naive baseplate (slicing hull without movement)...")
    
    # Convert all paths to absolute
    hull_stl = os.path.abspath(hull_stl)
    output_dir = os.path.abspath(output_dir)
    script_dir = os.path.abspath(script_dir)
    
    # Prepare file paths for naive baseplate
    naive_gcode_3mf = os.path.abspath(os.path.join(output_dir, f"{stl_name}_naive_baseplate.gcode.3mf"))
    naive_3mf = os.path.abspath(os.path.join(output_dir, f"{stl_name}_naive_baseplate.3mf"))
    
    # Change to script directory to ensure imports work
    original_cwd = os.getcwd()
    os.chdir(script_dir)
    
    try:
        # Add script directory to Python path
        import sys
        if script_dir not in sys.path:
            sys.path.insert(0, str(script_dir))
        
        # Import the appropriate automation module based on platform
        import platform
        if platform.system() == "Windows":
            from automation_windows import import_move_slice_file
        elif platform.system() == "Darwin":
            from automation_mac import import_move_slice_file
        else:
            print("[ERROR] Error: Unsupported platform. Only Windows and macOS are supported.")
            return None
        
        # Slice without movement (x_moves=0, y_moves=0)
        success = import_move_slice_file(hull_stl, 0, 0, naive_gcode_3mf, naive_3mf)
        
        if success and os.path.exists(naive_gcode_3mf):
            print(f"   [OK] Naive baseplate created: {naive_gcode_3mf}")
            return naive_gcode_3mf
        else:
            print(f"   [ERROR] Failed to create naive baseplate")
            return None
    
    finally:
        os.chdir(original_cwd)


def calculate_offset(original_3mf, hull_stl, output_dir, stl_name, script_dir):
    """Calculate alignment offset by slicing naive baseplate and comparing bounding box corners."""
    print("   ============================================================")
    print("   Calculating alignment offset using naive baseplate method...")
    print("   ============================================================")
    
    try:
        import zipfile
        import json
        import numpy as np
        
        def get_bbox_from_3mf(three_mf_path):
            """Get bounding box from 3MF file metadata (entire model, all layers)."""
            with zipfile.ZipFile(three_mf_path, 'r') as zip_ref:
                with zip_ref.open('Metadata/plate_1.json') as f:
                    data = json.load(f)
            
            bbox = data['bbox_objects'][0]['bbox']
            print(f"   [DEBUG] Raw bbox from 3MF: {bbox}")
            print(f"   [DEBUG] Bbox format: [min_x, min_y, max_x, max_y]")
            print(f"   [NOTE] This is the bounding box of the ENTIRE model (all layers), not just first 15 layers")
            min_x, min_y, max_x, max_y = bbox[0], bbox[1], bbox[2], bbox[3]
            center_x = (min_x + max_x) / 2
            center_y = (min_y + max_y) / 2
            return {
                'min_x': min_x, 'min_y': min_y,
                'max_x': max_x, 'max_y': max_y,
                'center_x': center_x, 'center_y': center_y,
                'width': max_x - min_x,
                'height': max_y - min_y
            }
        
        def get_stl_bbox(stl_path):
            """Get bounding box from STL file by reading all vertices."""
            try:
                from stl import mesh
                stl_mesh = mesh.Mesh.from_file(stl_path)
                
                # Get all vertices (each triangle has 3 vertices)
                vertices = stl_mesh.vectors.reshape(-1, 3)
                
                # Project to XY plane (ignore Z)
                xy_vertices = vertices[:, :2]
                
                min_x, min_y = np.min(xy_vertices, axis=0)
                max_x, max_y = np.max(xy_vertices, axis=0)
                center_x = (min_x + max_x) / 2
                center_y = (min_y + max_y) / 2
                
                return {
                    'min_x': min_x, 'min_y': min_y,
                    'max_x': max_x, 'max_y': max_y,
                    'center_x': center_x, 'center_y': center_y,
                    'width': max_x - min_x,
                    'height': max_y - min_y,
                    'num_vertices': len(vertices)
                }
            except Exception as e:
                print(f"   [WARNING] Could not read STL bbox: {e}")
                return None
        
        # Step 1: Get original model bounding boxes
        print("\n   [STEP 1] Analyzing original model...")
        
        # Get 3MF bbox (entire model, all layers)
        original_3mf_bbox = get_bbox_from_3mf(original_3mf)
        print(f"   [DEBUG] Original model 3MF bbox (ENTIRE model, all layers):")
        print(f"      min_x: {original_3mf_bbox['min_x']:.3f}, min_y: {original_3mf_bbox['min_y']:.3f}")
        print(f"      max_x: {original_3mf_bbox['max_x']:.3f}, max_y: {original_3mf_bbox['max_y']:.3f}")
        print(f"      center: ({original_3mf_bbox['center_x']:.3f}, {original_3mf_bbox['center_y']:.3f})")
        print(f"      width: {original_3mf_bbox['width']:.3f}mm, height: {original_3mf_bbox['height']:.3f}mm")
        
        # Get STL bbox
        stl_dir = os.path.dirname(original_3mf)
        original_stl_path = os.path.join(stl_dir, f"{stl_name}.stl")
        if os.path.exists(original_stl_path):
            original_stl_bbox = get_stl_bbox(original_stl_path)
            if original_stl_bbox:
                print(f"   [DEBUG] Original STL bbox:")
                print(f"      min_x: {original_stl_bbox['min_x']:.3f}, min_y: {original_stl_bbox['min_y']:.3f}")
                print(f"      max_x: {original_stl_bbox['max_x']:.3f}, max_y: {original_stl_bbox['max_y']:.3f}")
                print(f"      center: ({original_stl_bbox['center_x']:.3f}, {original_stl_bbox['center_y']:.3f})")
                print(f"      width: {original_stl_bbox['width']:.3f}mm, height: {original_stl_bbox['height']:.3f}mm")
                print(f"      vertices: {original_stl_bbox['num_vertices']}")
        
        # Get original model G-code and extract first 15 layers bbox
        print(f"\n   [STEP 1B] Extracting first 15 layers bbox from original model G-code...")
        original_gcode_3mf = os.path.join(stl_dir, f"{stl_name}.gcode.3mf")
        if os.path.exists(original_gcode_3mf):
            from extract_and_analyze import extract_gcode_from_3mf_file, parse_gcode_first_layer, compute_convex_hull
            original_gcode_content = extract_gcode_from_3mf_file(original_gcode_3mf)
            original_points = parse_gcode_first_layer(original_gcode_content)
            print(f"   [DEBUG] Extracted {len(original_points)} points from original model G-code (first 15 layers)")
            
            _, original_hull_points = compute_convex_hull(original_points)
            print(f"   [DEBUG] Computed convex hull with {len(original_hull_points)} vertices")
            
            original_hull_min_x, original_hull_min_y = np.min(original_hull_points, axis=0)
            original_hull_max_x, original_hull_max_y = np.max(original_hull_points, axis=0)
            original_hull_center_x = (original_hull_min_x + original_hull_max_x) / 2
            original_hull_center_y = (original_hull_min_y + original_hull_max_y) / 2
            original_hull_width = original_hull_max_x - original_hull_min_x
            original_hull_height = original_hull_max_y - original_hull_min_y
            
            original_bbox = {
                'min_x': original_hull_min_x, 'min_y': original_hull_min_y,
                'max_x': original_hull_max_x, 'max_y': original_hull_max_y,
                'center_x': original_hull_center_x, 'center_y': original_hull_center_y,
                'width': original_hull_width, 'height': original_hull_height
            }
            
            print(f"   [DEBUG] Original model first 15 layers convex hull bbox:")
            print(f"      min_x: {original_bbox['min_x']:.3f}, min_y: {original_bbox['min_y']:.3f}")
            print(f"      max_x: {original_bbox['max_x']:.3f}, max_y: {original_bbox['max_y']:.3f}")
            print(f"      center: ({original_bbox['center_x']:.3f}, {original_bbox['center_y']:.3f})")
            print(f"      width: {original_bbox['width']:.3f}mm, height: {original_bbox['height']:.3f}mm")
            
            print(f"\n   [DEBUG] Comparison: 3MF bbox (all layers) vs First 15 layers hull bbox:")
            print(f"      min_x diff: {original_3mf_bbox['min_x'] - original_bbox['min_x']:.3f}mm")
            print(f"      min_y diff: {original_3mf_bbox['min_y'] - original_bbox['min_y']:.3f}mm")
            print(f"      max_x diff: {original_3mf_bbox['max_x'] - original_bbox['max_x']:.3f}mm")
            print(f"      max_y diff: {original_3mf_bbox['max_y'] - original_bbox['max_y']:.3f}mm")
        else:
            print(f"   [WARNING] Original G-code 3MF not found: {original_gcode_3mf}")
            print(f"   [WARNING] Using 3MF bbox instead (may not be accurate for first 15 layers)")
            original_bbox = original_3mf_bbox
        
        # Step 2: Slice hull STL without movement (naive baseplate)
        print("\n   [STEP 2] Creating naive baseplate (slicing hull without movement)...")
        naive_gcode_3mf = slice_naive_baseplate(hull_stl, output_dir, stl_name, script_dir)
        if not naive_gcode_3mf:
            print("   [WARNING] Failed to create naive baseplate, using zero offset")
            return 0, 0
        
        # Step 3: Extract convex hull from naive baseplate G-code
        print("\n   [STEP 3] Extracting convex hull from naive baseplate G-code...")
        from extract_and_analyze import extract_gcode_from_3mf_file, parse_gcode_first_layer, compute_convex_hull
        
        gcode_content = extract_gcode_from_3mf_file(naive_gcode_3mf)
        naive_points = parse_gcode_first_layer(gcode_content)
        print(f"   [DEBUG] Extracted {len(naive_points)} points from naive baseplate G-code")
        
        _, naive_hull_points = compute_convex_hull(naive_points)
        print(f"   [DEBUG] Computed convex hull with {len(naive_hull_points)} vertices")
        
        # Step 4: Calculate bounding box of naive hull
        print("\n   [STEP 4] Calculating naive hull bounding box...")
        naive_min_x, naive_min_y = np.min(naive_hull_points, axis=0)
        naive_max_x, naive_max_y = np.max(naive_hull_points, axis=0)
        naive_center_x = (naive_min_x + naive_max_x) / 2
        naive_center_y = (naive_min_y + naive_max_y) / 2
        naive_width = naive_max_x - naive_min_x
        naive_height = naive_max_y - naive_min_y
        
        print(f"   [DEBUG] Naive hull bbox (first 15 layers, with 1mm buffer):")
        print(f"      min_x: {naive_min_x:.3f}, min_y: {naive_min_y:.3f}")
        print(f"      max_x: {naive_max_x:.3f}, max_y: {naive_max_y:.3f}")
        print(f"      center: ({naive_center_x:.3f}, {naive_center_y:.3f})")
        print(f"      width: {naive_width:.3f}mm, height: {naive_height:.3f}mm")
        
        # Get hull STL bbox for comparison
        if os.path.exists(hull_stl):
            hull_stl_bbox = get_stl_bbox(hull_stl)
            if hull_stl_bbox:
                print(f"\n   [DEBUG] Hull STL bbox:")
                print(f"      min_x: {hull_stl_bbox['min_x']:.3f}, min_y: {hull_stl_bbox['min_y']:.3f}")
                print(f"      max_x: {hull_stl_bbox['max_x']:.3f}, max_y: {hull_stl_bbox['max_y']:.3f}")
                print(f"      center: ({hull_stl_bbox['center_x']:.3f}, {hull_stl_bbox['center_y']:.3f})")
                print(f"      width: {hull_stl_bbox['width']:.3f}mm, height: {hull_stl_bbox['height']:.3f}mm")
                print(f"      vertices: {hull_stl_bbox['num_vertices']}")
        
        # Step 5: Calculate offset to minimize total error across all four corners
        print("\n   [STEP 5] Calculating offset to minimize total error across all corners...")
        print("   [DEBUG] Comparing original model first 15 layers bbox to naive hull first 15 layers bbox")
        print("   [NOTE] Finding offset that minimizes error at all four corners (min_x, min_y, max_x, max_y)")
        
        # Calculate offset for each corner
        offset_x_min = original_bbox['min_x'] - naive_min_x
        offset_y_min = original_bbox['min_y'] - naive_min_y
        offset_x_max = original_bbox['max_x'] - naive_max_x
        offset_y_max = original_bbox['max_y'] - naive_max_y
        
        print(f"   [DEBUG] Individual corner offsets:")
        print(f"      min_x offset: {offset_x_min:.3f}mm (original {original_bbox['min_x']:.3f} - naive {naive_min_x:.3f})")
        print(f"      min_y offset: {offset_y_min:.3f}mm (original {original_bbox['min_y']:.3f} - naive {naive_min_y:.3f})")
        print(f"      max_x offset: {offset_x_max:.3f}mm (original {original_bbox['max_x']:.3f} - naive {naive_max_x:.3f})")
        print(f"      max_y offset: {offset_y_max:.3f}mm (original {original_bbox['max_y']:.3f} - naive {naive_max_y:.3f})")
        
        # Average the offsets to minimize total error
        offset_x = (offset_x_min + offset_x_max) / 2
        offset_y_raw = (offset_y_min + offset_y_max) / 2
        
        # Invert Y offset to match Bambu Studio's coordinate system
        # In Bambu Studio, positive Y moves UP, but our coordinate system has positive Y going DOWN
        offset_y = -offset_y_raw
        
        print(f"\n   [DEBUG] Averaged offset (minimizes total error):")
        print(f"      offset_x = ({offset_x_min:.3f} + {offset_x_max:.3f}) / 2 = {offset_x:.3f}mm")
        print(f"      offset_y_raw = ({offset_y_min:.3f} + {offset_y_max:.3f}) / 2 = {offset_y_raw:.3f}mm")
        print(f"      offset_y (inverted for Bambu Studio) = -{offset_y_raw:.3f} = {offset_y:.3f}mm")
        
        # Calculate errors at each corner after applying the offset
        # Note: Use raw offset for error calculation (position alignment), not inverted (movement direction)
        error_min_x = abs(original_bbox['min_x'] - (naive_min_x + offset_x))
        error_min_y = abs(original_bbox['min_y'] - (naive_min_y + offset_y_raw))
        error_max_x = abs(original_bbox['max_x'] - (naive_max_x + offset_x))
        error_max_y = abs(original_bbox['max_y'] - (naive_max_y + offset_y_raw))
        
        total_error = error_min_x + error_min_y + error_max_x + error_max_y
        max_error = max(error_min_x, error_min_y, error_max_x, error_max_y)
        
        print(f"\n   [DEBUG] Errors at each corner after applying offset:")
        print(f"      min_x error: {error_min_x:.3f}mm")
        print(f"      min_y error: {error_min_y:.3f}mm")
        print(f"      max_x error: {error_max_x:.3f}mm")
        print(f"      max_y error: {error_max_y:.3f}mm")
        print(f"      Total error: {total_error:.3f}mm")
        print(f"      Maximum error: {max_error:.3f}mm")
        
        # Check if any error exceeds 5mm threshold
        if max_error > 5.0:
            error_msg = (
                f"ERROR: Maximum corner error ({max_error:.3f}mm) exceeds 5mm threshold!\n"
                f"   Corner errors: min_x={error_min_x:.3f}mm, min_y={error_min_y:.3f}mm, "
                f"max_x={error_max_x:.3f}mm, max_y={error_max_y:.3f}mm\n"
                f"   This indicates a significant misalignment between the original model and naive hull.\n"
                f"   Please check the hull generation and offset calculation."
            )
            print(f"   [ERROR] {error_msg}")
            raise ValueError(error_msg)
        
        # Also calculate center-based offset for comparison
        center_offset_x = original_bbox['center_x'] - naive_center_x
        center_offset_y = original_bbox['center_y'] - naive_center_y
        print(f"\n   [DEBUG] Center-based offset (for comparison):")
        print(f"      center_offset_x: {center_offset_x:.3f}mm")
        print(f"      center_offset_y: {center_offset_y:.3f}mm")
        
        x_moves = int(round(offset_x))
        y_moves = int(round(offset_y))
        
        print(f"\n   [RESULT] Calculated offset: X={offset_x:.3f}mm, Y={offset_y:.3f}mm")
        print(f"   [RESULT] Move counts: X={x_moves}, Y={y_moves}")
        print(f"   [DEBUG] Rounding details:")
        print(f"      offset_x={offset_x:.6f} -> rounded to {x_moves}")
        print(f"      offset_y={offset_y:.6f} -> rounded to {y_moves}")
        
        # Debug: Show what movements will be applied
        print(f"\n   [MOVEMENT] Movement plan:")
        if x_moves > 0:
            print(f"      X: Move hull {x_moves}mm RIGHT ({abs(x_moves)} steps)")
        elif x_moves < 0:
            print(f"      X: Move hull {abs(x_moves)}mm LEFT ({abs(x_moves)} steps)")
        else:
            print(f"      X: No movement needed")
        
        if y_moves > 0:
            print(f"      Y: Move hull {y_moves}mm UP ({abs(y_moves)} steps)")
        elif y_moves < 0:
            print(f"      Y: Move hull {abs(y_moves)}mm DOWN ({abs(y_moves)} steps)")
        else:
            print(f"      Y: No movement needed")
        
        print("   ============================================================")
        
        return x_moves, y_moves
        
    except Exception as e:
        print(f"   [ERROR] Could not calculate offset: {e}")
        import traceback
        traceback.print_exc()
        print("   Using zero offset as fallback")
        return 0, 0


def import_move_slice_hull(hull_stl, x_moves, y_moves, output_dir, stl_name, script_dir):
    """Import hull STL, move it, slice it, and export."""
    print("[PROCESS] Step 4: Calculating offset and moving/slicing hull...")
    print("   Importing hull STL, moving it, slicing, and exporting...")
    
    # Convert all paths to absolute
    hull_stl = os.path.abspath(hull_stl)
    output_dir = os.path.abspath(output_dir)
    script_dir = os.path.abspath(script_dir)
    
    # Prepare file paths
    hull_gcode_3mf = os.path.abspath(os.path.join(output_dir, f"{stl_name}_hull.gcode.3mf"))
    hull_3mf = os.path.abspath(os.path.join(output_dir, f"{stl_name}_hull.3mf"))
    
    # Change to script directory to ensure imports work
    original_cwd = os.getcwd()
    os.chdir(script_dir)
    
    try:
        # Add script directory to Python path
        import sys
        if script_dir not in sys.path:
            sys.path.insert(0, str(script_dir))
        
        # Import the appropriate automation module based on platform
        import platform
        if platform.system() == "Windows":
            from automation_windows import import_move_slice_file
        elif platform.system() == "Darwin":
            from automation_mac import import_move_slice_file
        else:
            print("[ERROR] Error: Unsupported platform. Only Windows and macOS are supported.")
            return False, None, None
        
        success = import_move_slice_file(hull_stl, x_moves, y_moves, hull_gcode_3mf, hull_3mf)
        
        if success:
            print("[OK] Hull import, move, slice, and export completed successfully")
            print(f"[FILE] Hull gcode: {hull_gcode_3mf}")
            print(f"[FILE] Hull 3MF: {hull_3mf}")
            return True, hull_gcode_3mf, hull_3mf
        else:
            print("[ERROR] Error: Failed to import, move, and slice hull")
            return False, None, None
    
    finally:
        os.chdir(original_cwd)


def run_replace_baseplate(hull_gcode_3mf, original_gcode_3mf, final_output, script_dir):
    """Run ReplaceBaseplate to combine hull baseplate with original model."""
    print("[PROCESS] Step 5: Running ReplaceBaseplate...")
    print("   Using hull as baseplate and original model as model...")
    
    # Convert all paths to absolute
    hull_gcode_3mf = os.path.abspath(hull_gcode_3mf)
    original_gcode_3mf = os.path.abspath(original_gcode_3mf)
    final_output = os.path.abspath(final_output)
    script_dir = os.path.abspath(script_dir)
    
    # Check if ReplaceBaseplate script exists
    replace_baseplate_script = os.path.abspath(os.path.join(script_dir, "ReplaceBaseplate", "replace_baseplate_layers.py"))
    if not os.path.exists(replace_baseplate_script):
        print(f"[ERROR] Error: ReplaceBaseplate script not found: {replace_baseplate_script}")
        return False
    
    # Prepare file paths for ReplaceBaseplate
    if not os.path.exists(hull_gcode_3mf):
        print(f"[ERROR] Error: Hull .gcode.3mf file not found: {hull_gcode_3mf}")
        return False
    
    if not os.path.exists(original_gcode_3mf):
        print(f"[ERROR] Error: Original .gcode.3mf file not found: {original_gcode_3mf}")
        return False
    
    # Run ReplaceBaseplate
    print("   Baseplate file:", hull_gcode_3mf)
    print("   Model file:", original_gcode_3mf)
    print("   Output file:", final_output)
    
    # Change to script directory and activate virtual environment
    original_cwd = os.getcwd()
    os.chdir(script_dir)
    
    try:
        # Activate virtual environment
        if os.name == 'nt':  # Windows
            python_exe = os.path.abspath(os.path.join(script_dir, "venv", "Scripts", "python.exe"))
        else:  # macOS/Linux
            python_exe = os.path.abspath(os.path.join(script_dir, "venv", "bin", "python"))
        
        if not os.path.exists(python_exe):
            print("[ERROR] Error: Virtual environment not found. Please run setup first.")
            return False
        
        # Run ReplaceBaseplate
        cmd = [python_exe, replace_baseplate_script, hull_gcode_3mf, original_gcode_3mf, final_output]
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode != 0:
            print(f"[ERROR] Error: ReplaceBaseplate failed: {result.stderr}")
            return False
        
        print("[OK] ReplaceBaseplate completed successfully")
        print(f"[FILE] Final output: {final_output}")
        return True
        
    finally:
        os.chdir(original_cwd)


def create_analysis_files(gcode_3mf, output_dir, stl_name, script_dir):
    """Create analysis files and summary."""
    print("[ANALYSIS] Step 7: Creating analysis files...")
    
    # Convert all paths to absolute
    gcode_3mf = os.path.abspath(gcode_3mf)
    output_dir = os.path.abspath(output_dir)
    script_dir = os.path.abspath(script_dir)
    
    # Extract hull points for reference
    hull_points = os.path.abspath(os.path.join(output_dir, "hull_points.txt"))
    
    # Change to script directory and activate virtual environment
    original_cwd = os.getcwd()
    os.chdir(script_dir)
    
    try:
        # Activate virtual environment
        if os.name == 'nt':  # Windows
            python_exe = os.path.abspath(os.path.join(script_dir, "venv", "Scripts", "python.exe"))
        else:  # macOS/Linux
            python_exe = os.path.abspath(os.path.join(script_dir, "venv", "bin", "python"))
        
        if not os.path.exists(python_exe):
            print("[ERROR] Error: Virtual environment not found. Please run setup first.")
            return False
        
        # Run extract_hull_points.py
        cmd = [python_exe, "extract_hull_points.py", gcode_3mf]
        with open(hull_points, 'w') as f:
            result = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, text=True)
        
        if result.returncode == 0:
            print(f"[OK] Created hull points file: {hull_points}")
        else:
            print(f"[WARNING]  Warning: Could not create hull points file: {result.stderr}")
        
        # Create summary report
        summary_file = os.path.abspath(os.path.join(output_dir, "pipeline_summary.txt"))
        with open(summary_file, 'w') as f:
            f.write(f"""Full Pipeline Summary
====================
        Input STL: {gcode_3mf}
Output Directory: {output_dir}
Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}

Files Created:
- {stl_name}.gcode.3mf (original sliced)
- {stl_name}.3mf (original project)
- {stl_name}_hull.stl (extruded convex hull)
- {stl_name}_hull.gcode.3mf (hull sliced and aligned)
- {stl_name}_hull.3mf (hull project)
- {stl_name}_with_hull_baseplate.gcode.3mf (final combined gcode)
- hull_points.txt (hull vertices)
- first_layer_analysis.png (visualization)

Pipeline Steps:
1. [OK] Sliced original STL in Bambu Studio
2. [OK] Extracted convex hull from first layer
3. [OK] Created 1mm extruded hull STL
4. [OK] Calculated offset and moved/sliced aligned hull
5. [OK] Ran ReplaceBaseplate to combine hull baseplate with original model
6. [OK] Organized all output files
7. [OK] Created analysis files

Ready for 3D printing!
""")
        
        print(f"[OK] Created summary: {summary_file}")
        return True
        
    finally:
        os.chdir(original_cwd)


class TeeOutput:
    """Class to write output to both console and file."""
    def __init__(self, *files):
        self.files = files
    
    def write(self, obj):
        for f in self.files:
            f.write(obj)
            f.flush()
    
    def flush(self):
        for f in self.files:
            f.flush()


def main():
    """Main pipeline function."""
    if len(sys.argv) != 2:
        print("[ERROR] Error: Please provide an STL file path")
        print("Usage: python full_pipeline.py <input_stl_file>")
        print("Example: python full_pipeline.py /path/to/model.stl")
        sys.exit(1)
    
    input_stl = os.path.abspath(sys.argv[1])  # Convert to absolute path
    script_dir = get_script_directory()
    
    # Create output directory early so we can save logs there
    output_dir, stl_name = create_output_directory(input_stl)
    
    # Set up logging to file
    log_file_path = os.path.join(output_dir, f"{stl_name}_pipeline_log.txt")
    log_file = open(log_file_path, 'w', encoding='utf-8')
    
    # Create TeeOutput to write to both console and file
    tee = TeeOutput(sys.stdout, log_file)
    sys.stdout = tee
    sys.stderr = tee
    
    try:
        print("=" * 80)
        print(f"Pipeline Log - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 80)
        print(f"[START] Starting Full Pipeline")
        print(f"[FILE] Input STL: {input_stl}")
        print(f"[FILE] Output Directory: {output_dir}")
        print(f"[FILE] Log file: {log_file_path}")
        print("")
    
    # Check input file
    if not check_input_file(input_stl):
        sys.exit(1)
    
    print("")
    
    # Step 1: Slice the original STL
    if not slice_original_stl(input_stl, script_dir):
        print("[ERROR] Error: Failed to slice original STL")
        sys.exit(1)
    
    # Wait a moment for files to be written
    time.sleep(2)
    
    # Step 2: Find the generated .gcode.3mf file
    print("")
    print("[SEARCH] Step 2: Locating generated files...")
    gcode_3mf = find_generated_files(input_stl)
    if not gcode_3mf:
        sys.exit(1)
    
    # Copy files to output directory
    output_gcode_3mf = os.path.abspath(os.path.join(output_dir, os.path.basename(gcode_3mf)))
    import shutil
    shutil.copy2(gcode_3mf, output_gcode_3mf)
    print("[FILE] Copied .gcode.3mf to output directory")
    
    # Step 3: Extract convex hull and create hull STL
    hull_stl = create_hull_stl(gcode_3mf, output_dir, stl_name, script_dir, input_stl)
    if not hull_stl:
        print("[ERROR] Error: Failed to create hull STL")
        sys.exit(1)
    
    # Step 4: Calculate offset and move/slice hull
    print("")
    print("[PROCESS] Step 4: Calculating offset and moving/slicing hull...")
    print("   Importing hull STL, moving it, slicing, and exporting...")
    
    # Find original 3MF file
    stl_dir = os.path.dirname(input_stl)
    original_3mf = os.path.abspath(os.path.join(stl_dir, f"{stl_name}.3mf"))
    
    if not os.path.exists(original_3mf):
        print(f"[ERROR] Error: Original 3MF file not found: {original_3mf}")
        sys.exit(1)
    
        # Calculate offset using naive baseplate method
        x_moves, y_moves = calculate_offset(original_3mf, hull_stl, output_dir, stl_name, script_dir)
    
    # Import, move, slice, and export hull
    success, hull_gcode_3mf, hull_3mf = import_move_slice_hull(
        hull_stl, x_moves, y_moves, output_dir, stl_name, script_dir
    )
    
    # Fallback: If hull gcode not found, create rectangle baseplate
    if not success or not os.path.exists(hull_gcode_3mf):
        print("[WARNING] Hull .gcode.3mf not found, creating rectangle fallback baseplate...")
        
        # Calculate hull width from original gcode
        try:
            from extract_and_analyze import extract_gcode_from_3mf_file, parse_gcode_first_layer
            gcode_text = extract_gcode_from_3mf_file(gcode_3mf)
                points = parse_gcode_first_layer(gcode_text)
            
            # Calculate width (max X - min X)
            if len(points) > 0:
                min_x = points[:, 0].min()
                max_x = points[:, 0].max()
                hull_width = max_x - min_x
                # Cap width at 180mm maximum
                hull_width = min(hull_width, 180.0)
                print(f"[FALLBACK] Calculated hull width: {hull_width:.2f}mm (capped at 180mm)")
            else:
                # Default width if can't calculate (capped at 180mm)
                hull_width = 180.0
                print(f"[FALLBACK] Using default width: {hull_width}mm")
        except Exception as e:
            print(f"[WARNING] Could not calculate hull width: {e}")
            hull_width = 180.0  # Default width (capped at 180mm)
            print(f"[FALLBACK] Using default width: {hull_width}mm")
        
        # Create rectangle baseplate STL
        from create_rectangle_baseplate import create_rectangle_stl
        rectangle_stl = os.path.abspath(os.path.join(output_dir, f"{stl_name}_rectangle_baseplate.stl"))
        create_rectangle_stl(hull_width, height_mm=180.0, thickness_mm=1.0, output_path=rectangle_stl)
        
        # Slice the rectangle (don't move it - place at origin 0,0)
        print("[FALLBACK] Slicing rectangle baseplate at origin (no movement)...")
        success, hull_gcode_3mf, hull_3mf = import_move_slice_hull(
                rectangle_stl, 0, 0, output_dir, stl_name, script_dir
        )
        
        if not success or not os.path.exists(hull_gcode_3mf):
            print("[ERROR] Error: Failed to create rectangle fallback baseplate")
            sys.exit(1)
        
        print("[OK] Rectangle fallback baseplate created successfully")
    
    # Step 5: Run ReplaceBaseplate
    print("")
    print("[PROCESS] Step 5: Running ReplaceBaseplate...")
    print("   Using hull as baseplate and original model as model...")
    
    # Prepare file paths for ReplaceBaseplate
    original_gcode_3mf = os.path.abspath(os.path.join(stl_dir, f"{stl_name}.gcode.3mf"))
    final_output = os.path.abspath(os.path.join(output_dir, f"{stl_name}_with_hull_baseplate.gcode.3mf"))
    
    if not run_replace_baseplate(hull_gcode_3mf, original_gcode_3mf, final_output, script_dir):
        print("[ERROR] Error: ReplaceBaseplate failed")
        sys.exit(1)
    
    # Step 6: Organize all output files
    print("")
    print("[FILE] Step 6: Organizing output files...")
    
    # The hull files should already be in the output directory since we sliced the hull STL there
    # But let's check if they're in the original directory and move them if needed
    hull_gcode_in_original = os.path.abspath(os.path.join(stl_dir, f"{stl_name}_hull.gcode.3mf"))
    hull_3mf_in_original = os.path.abspath(os.path.join(stl_dir, f"{stl_name}_hull.3mf"))
    
    if os.path.exists(hull_gcode_in_original):
        shutil.move(hull_gcode_in_original, output_dir)
        print("[OK] Moved hull .gcode.3mf to output directory")
    
    if os.path.exists(hull_3mf_in_original):
        shutil.move(hull_3mf_in_original, output_dir)
        print("[OK] Moved hull .3mf to output directory")
    
    # Verify the files are now in the output directory
    if os.path.exists(hull_gcode_3mf):
        print("[OK] Hull .gcode.3mf confirmed in output directory")
    else:
        print("[ERROR] Error: Hull .gcode.3mf still not found after organization")
        sys.exit(1)
    
    # Step 7: Create analysis files
    if not create_analysis_files(gcode_3mf, output_dir, stl_name, script_dir):
        print("[WARNING]  Warning: Could not create all analysis files")
    
    # Final success message
    print("")
    print("[SUCCESS] Full Pipeline Completed Successfully!")
    print(f"[FILE] All files saved to: {output_dir}")
    print("")
    print("[FILES] Generated Files:")
    for file in os.listdir(output_dir):
        if file.endswith(('.stl', '.3mf', '.txt', '.png')):
            file_path = os.path.join(output_dir, file)
            file_size = os.path.getsize(file_path)
            print(f"   {file} ({file_size} bytes)")
    print("")
    print("[START] Ready for 3D printing both the original and hull models!")
        print("")
        print("=" * 80)
        print(f"Pipeline completed - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Log file saved to: {log_file_path}")
        print("=" * 80)
    
    except SystemExit:
        # Handle sys.exit() calls - still save the log
        if 'log_file' in locals():
            log_file.flush()
            log_file.close()
        # Re-raise to maintain exit behavior
        raise
    except Exception as e:
        # Handle any other exceptions - still save the log
        if 'log_file' in locals():
            print(f"\n[ERROR] Exception occurred: {e}", file=sys.__stdout__)
            log_file.flush()
            log_file.close()
        # Re-raise to maintain error behavior
        raise
    finally:
        # Restore stdout and stderr
        sys.stdout = sys.__stdout__
        sys.stderr = sys.__stderr__
        # Flush and close the log file (in case it wasn't closed in except block)
        if 'log_file' in locals() and not log_file.closed:
            try:
                log_file.flush()
                log_file.close()
                # Verify file exists and has content
                if os.path.exists(log_file_path):
                    file_size = os.path.getsize(log_file_path)
                    print(f"\n[LOG] Pipeline log saved to: {log_file_path} ({file_size} bytes)")
                else:
                    print(f"\n[WARNING] Log file was not created: {log_file_path}")
            except Exception as e:
                print(f"\n[ERROR] Failed to save log file: {e}", file=sys.__stdout__)


if __name__ == "__main__":
    main()
