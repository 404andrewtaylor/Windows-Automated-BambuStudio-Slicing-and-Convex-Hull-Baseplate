#!/usr/bin/env python3
"""
One-stop script that does everything: setup, test, and run the pipeline.
Usage: python run_everything.py <stl_file>
"""

import os
import sys
import subprocess
from pathlib import Path

def run_command(cmd, description):
    """Run a command and return success status."""
    print(f"\n{description}...")
    print(f"Running: {' '.join(cmd) if isinstance(cmd, list) else cmd}")
    
    try:
        if isinstance(cmd, list):
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=os.getcwd())
        else:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=os.getcwd())
        
        if result.stdout:
            print("STDOUT:", result.stdout)
        if result.stderr:
            print("STDERR:", result.stderr)
            
        if result.returncode == 0:
            print(f"SUCCESS: {description} completed successfully")
            return True
        else:
            print(f"ERROR: {description} failed with return code: {result.returncode}")
            return False
    except Exception as e:
        print(f"ERROR: Error during {description}: {e}")
        return False

def main():
    if len(sys.argv) != 2:
        print("Usage: python run_everything.py <stl_file>")
        print("Example: python run_everything.py C:\\path\\to\\model.stl")
        sys.exit(1)
    
    input_stl = sys.argv[1]
    script_dir = Path(__file__).parent.absolute()
    
    print("One-Stop STL to Hull Baseplate Pipeline")
    print("=" * 50)
    print(f"Input STL: {input_stl}")
    print(f"Script Directory: {script_dir}")
    
    # Step 1: Change to the script directory
    print(f"\nChanging to script directory: {script_dir}")
    os.chdir(script_dir)
    print(f"Current directory: {os.getcwd()}")
    
    # Step 2: Run setup
    if not run_command([sys.executable, "setup_windows_clean.py"], "Running Windows setup"):
        print("ERROR: Setup failed. Please check the errors above.")
        sys.exit(1)
    
    # Step 3: Test basic functionality
    if not run_command([str(script_dir / "venv" / "Scripts" / "python.exe"), "simple_test.py"], "Testing basic functionality"):
        print("ERROR: Basic test failed. Please check the errors above.")
        sys.exit(1)
    
    # Step 4: Run the simple slice
    print(f"\nRunning slice automation on: {input_stl}")
    if not run_command([str(script_dir / "venv" / "Scripts" / "python.exe"), "simple_slice.py", input_stl], "Running slice automation"):
        print("ERROR: Slice automation failed. Please check the errors above.")
        sys.exit(1)
    
    print("\nSUCCESS! Pipeline completed successfully!")
    print("Check the output directory for your sliced files.")

if __name__ == "__main__":
    main()
