#!/usr/bin/env python3
"""
Windows import/move/slice script for Bambu Studio automation.
Usage: python import_move_slice_windows.py <stl_file> <x_moves> <y_moves> <output_gcode_3mf> <output_3mf>
"""

import os
import sys
from pathlib import Path


def main():
    """Main function for Windows import/move/slice."""
    if len(sys.argv) != 6:
        print("❌ Error: Please provide all required arguments")
        print("Usage: python import_move_slice_windows.py <stl_file> <x_moves> <y_moves> <output_gcode_3mf> <output_3mf>")
        print("Example: python import_move_slice_windows.py hull.stl 13 7 hull.gcode.3mf hull.3mf")
        sys.exit(1)
    
    stl_file = sys.argv[1]
    x_moves = int(sys.argv[2])
    y_moves = int(sys.argv[3])
    output_gcode_3mf = sys.argv[4]
    output_3mf = sys.argv[5]
    
    if not os.path.exists(stl_file):
        print(f"❌ Error: STL file not found: {stl_file}")
        sys.exit(1)
    
    print("🎯 Importing STL, moving, slicing, and exporting...")
    print(f"📁 STL: {stl_file}")
    print(f"📊 X moves: {x_moves}, Y moves: {y_moves}")
    print(f"📁 Output gcode: {output_gcode_3mf}")
    print(f"📁 Output 3MF: {output_3mf}")
    
    # Import Windows automation
    try:
        from automation_windows import import_move_slice_file
    except ImportError as e:
        print(f"❌ Error importing Windows automation: {e}")
        print("   Make sure automation_windows.py is in the same directory")
        sys.exit(1)
    
    # Import, move, slice, and export
    success = import_move_slice_file(stl_file, x_moves, y_moves, output_gcode_3mf, output_3mf)
    
    if success:
        print("🎉 Import, move, slice, and export completed successfully!")
        
        # Check if files were created
        if os.path.exists(output_gcode_3mf):
            print(f"✅ G-code 3MF created: {output_gcode_3mf}")
        else:
            print(f"❌ Error: G-code 3MF not created: {output_gcode_3mf}")
            sys.exit(1)
        
        if os.path.exists(output_3mf):
            print(f"✅ Project 3MF created: {output_3mf}")
        else:
            print(f"❌ Error: Project 3MF not created: {output_3mf}")
            sys.exit(1)
    else:
        print("❌ Error: Failed to import, move, and slice")
        sys.exit(1)


if __name__ == "__main__":
    main()
