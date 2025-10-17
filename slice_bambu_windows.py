#!/usr/bin/env python3
"""
Windows slice script for Bambu Studio automation.
Usage: python slice_bambu_windows.py <input_stl_file>
"""

import os
import sys
from pathlib import Path


def main():
    """Main function for Windows slicing."""
    if len(sys.argv) != 2:
        print("❌ Error: Please provide an STL file path")
        print("Usage: python slice_bambu_windows.py <input_stl_file>")
        print("Example: python slice_bambu_windows.py C:\\path\\to\\model.stl")
        sys.exit(1)
    
    input_stl = sys.argv[1]
    
    if not os.path.exists(input_stl):
        print(f"❌ Error: Input STL file not found: {input_stl}")
        sys.exit(1)
    
    if not input_stl.lower().endswith('.stl'):
        print(f"❌ Error: Input file must be an STL file: {input_stl}")
        sys.exit(1)
    
    print(f"🔧 Slicing STL file: {input_stl}")
    
    # Import Windows automation
    try:
        from automation_windows import slice_stl_file
    except ImportError as e:
        print(f"❌ Error importing Windows automation: {e}")
        print("   Make sure automation_windows.py is in the same directory")
        sys.exit(1)
    
    # Get the directory of the input STL file
    stl_dir = os.path.dirname(input_stl)
    
    # Slice the STL file
    success = slice_stl_file(input_stl, output_dir=stl_dir)
    
    if success:
        print("✅ STL slicing completed successfully")
        
        # Run the Python analysis script
        print("🐍 Running first layer analysis...")
        script_dir = Path(__file__).parent
        
        # Change to script directory
        original_cwd = os.getcwd()
        os.chdir(script_dir)
        
        try:
            # Activate virtual environment
            if os.name == 'nt':  # Windows
                python_exe = os.path.join(script_dir, "venv", "Scripts", "python.exe")
            else:  # macOS/Linux
                python_exe = os.path.join(script_dir, "venv", "bin", "python")
            
            if not os.path.exists(python_exe):
                print("❌ Error: Virtual environment not found. Please run setup first.")
                sys.exit(1)
            
            # Run extract_and_analyze.py
            import subprocess
            cmd = [python_exe, "extract_and_analyze.py", input_stl]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print("✅ First layer analysis completed")
            else:
                print(f"⚠️  Warning: Analysis script had issues: {result.stderr}")
        
        finally:
            os.chdir(original_cwd)
    else:
        print("❌ Error: Failed to slice STL file")
        sys.exit(1)


if __name__ == "__main__":
    main()
