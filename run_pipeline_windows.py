#!/usr/bin/env python3
"""
Windows wrapper script that activates virtual environment before running the pipeline.
Usage: python run_pipeline_windows.py <input_stl_file>
"""

import os
import sys
import subprocess
from pathlib import Path


def main():
    """Main function that activates venv and runs the pipeline."""
    if len(sys.argv) != 2:
        print("❌ Error: Please provide an STL file path")
        print("Usage: python run_pipeline_windows.py <input_stl_file>")
        print("Example: python run_pipeline_windows.py C:\\path\\to\\model.stl")
        sys.exit(1)
    
    input_stl = sys.argv[1]
    script_dir = Path(__file__).parent.absolute()
    
    # Check if virtual environment exists
    venv_python = script_dir / "venv" / "Scripts" / "python.exe"
    if not venv_python.exists():
        print("❌ Error: Virtual environment not found. Please run setup_windows.py first.")
        sys.exit(1)
    
    # Check if input file exists
    if not os.path.exists(input_stl):
        print(f"❌ Error: Input STL file not found: {input_stl}")
        sys.exit(1)
    
    if not input_stl.lower().endswith('.stl'):
        print(f"❌ Error: Input file must be an STL file: {input_stl}")
        sys.exit(1)
    
    print("🚀 Starting STL to Hull Baseplate Pipeline (Windows)")
    print(f"📁 Input STL: {input_stl}")
    print("")
    
    # Run the pipeline using the virtual environment Python
    try:
        cmd = [str(venv_python), "full_pipeline.py", input_stl]
        result = subprocess.run(cmd, cwd=str(script_dir))
        sys.exit(result.returncode)
    except Exception as e:
        print(f"❌ Error running pipeline: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
