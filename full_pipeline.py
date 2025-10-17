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


def calculate_offset(original_3mf, hull_stl):
    """Calculate alignment offset between original and hull."""
    print("   Calculating alignment offset...")
    
    try:
        import zipfile
        import json
        
        def get_bbox_center(three_mf_path):
            with zipfile.ZipFile(three_mf_path, 'r') as zip_ref:
                with zip_ref.open('Metadata/plate_1.json') as f:
                    data = json.load(f)
            
            bbox = data['bbox_objects'][0]['bbox']
            print(f"   Raw bbox: {bbox}")
            print(f"   Bbox format: [min_x, min_y, max_x, max_y]")
            center_x = (bbox[0] + bbox[2]) / 2
            center_y = (bbox[1] + bbox[3]) / 2
            return (center_x, center_y)
        
        # Get original center
        original_center = get_bbox_center(original_3mf)
        print(f"   Original model center: ({original_center[0]:.2f}, {original_center[1]:.2f})")
        
        # For hull, we need to estimate where it will be positioned
        # Since we don't have the hull 3MF yet, we'll use a default offset
        # This will be refined by the move_and_slice_hull.py script
        # hull_center = (175.0, 160.0)  # Default hull position for H2D printer
        hull_center = (90.0, 90.0)  # Default hull position for A1 mini
        print(f"   Default hull center: ({hull_center[0]:.2f}, {hull_center[1]:.2f})")
        
        offset_x = original_center[0] - hull_center[0]
        offset_y = original_center[1] - hull_center[1]
        
        x_moves = int(round(offset_x))
        y_moves = int(round(offset_y))
        
        print(f"   Calculated offset: X={offset_x:.2f}mm, Y={offset_y:.2f}mm")
        print(f"   Move counts: X={x_moves}, Y={y_moves}")
        
        # Debug: Show what movements will be applied
        if x_moves > 0:
            print(f"   Will move hull {x_moves}mm RIGHT")
        elif x_moves < 0:
            print(f"   Will move hull {abs(x_moves)}mm LEFT")
        
        if y_moves > 0:
            print(f"   Will move hull {y_moves}mm UP")
        elif y_moves < 0:
            print(f"   Will move hull {abs(y_moves)}mm DOWN")
        
        return x_moves, y_moves
        
    except Exception as e:
        print(f"   Warning: Could not calculate offset: {e}")
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


def main():
    """Main pipeline function."""
    if len(sys.argv) != 2:
        print("[ERROR] Error: Please provide an STL file path")
        print("Usage: python full_pipeline.py <input_stl_file>")
        print("Example: python full_pipeline.py /path/to/model.stl")
        sys.exit(1)
    
    input_stl = os.path.abspath(sys.argv[1])  # Convert to absolute path
    script_dir = get_script_directory()
    
    print("[START] Starting Full Pipeline")
    print(f"[FILE] Input STL: {input_stl}")
    
    # Check input file
    if not check_input_file(input_stl):
        sys.exit(1)
    
    # Create output directory
    output_dir, stl_name = create_output_directory(input_stl)
    print(f"[FILE] Output Directory: {output_dir}")
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
    
    # Calculate offset
    x_moves, y_moves = calculate_offset(original_3mf, hull_stl)
    
    # Import, move, slice, and export hull
    success, hull_gcode_3mf, hull_3mf = import_move_slice_hull(
        hull_stl, x_moves, y_moves, output_dir, stl_name, script_dir
    )
    
    if not success:
        print("[ERROR] Error: Failed to import, move, and slice hull")
        sys.exit(1)
    
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


if __name__ == "__main__":
    main()
