#!/usr/bin/env python3
"""
Bulletproof Windows pipeline script that handles all edge cases.
Usage: python bulletproof_pipeline.py <input_stl_file>
"""

import os
import sys
import time
import subprocess
from pathlib import Path


def setup_environment():
    """Setup the Python environment and paths."""
    # Get script directory
    script_dir = Path(__file__).parent.absolute()
    
    # Add script directory to Python path
    if str(script_dir) not in sys.path:
        sys.path.insert(0, str(script_dir))
    
    # Change to script directory
    os.chdir(script_dir)
    
    return script_dir


def test_prerequisites():
    """Test all prerequisites before running the pipeline."""
    print("🔍 Testing prerequisites...")
    
    # Test 1: Check if we're in the right directory
    script_dir = Path(__file__).parent.absolute()
    if not (script_dir / "automation_windows.py").exists():
        print("❌ Error: automation_windows.py not found in script directory")
        return False
    
    # Test 2: Check if virtual environment exists
    venv_python = script_dir / "venv" / "Scripts" / "python.exe"
    if not venv_python.exists():
        print("❌ Error: Virtual environment not found. Please run setup_windows.py first.")
        return False
    
    # Test 3: Test imports using virtual environment
    try:
        cmd = [str(venv_python), "-c", """
import sys
sys.path.insert(0, '.')
try:
    from automation_windows import slice_stl_file
    print('SUCCESS: automation_windows imported')
except Exception as e:
    print(f'ERROR: {e}')
    sys.exit(1)
"""]
        result = subprocess.run(cmd, capture_output=True, text=True, cwd=str(script_dir))
        if result.returncode != 0:
            print(f"❌ Error: Cannot import automation modules: {result.stderr}")
            return False
        print("✅ Automation modules can be imported")
    except Exception as e:
        print(f"❌ Error testing imports: {e}")
        return False
    
    print("✅ All prerequisites passed")
    return True


def run_slice_automation(input_stl, script_dir):
    """Run the slice automation using the virtual environment."""
    print("🔧 Running slice automation...")
    
    venv_python = script_dir / "venv" / "Scripts" / "python.exe"
    
    # Create a simple slice script
    slice_script = script_dir / "temp_slice.py"
    slice_script_content = f'''
import sys
import os
sys.path.insert(0, ".")

from automation_windows import slice_stl_file

input_stl = r"{input_stl}"
print(f"Starting slice automation for: {{input_stl}}")

try:
    result = slice_stl_file(input_stl)
    if result:
        print("SUCCESS: Slice automation completed")
    else:
        print("ERROR: Slice automation failed")
        sys.exit(1)
except Exception as e:
    print(f"ERROR: {{e}}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
'''
    
    try:
        # Write the temporary script
        with open(slice_script, 'w') as f:
            f.write(slice_script_content)
        
        # Run the slice automation
        cmd = [str(venv_python), str(slice_script)]
        print(f"Running: {' '.join(cmd)}")
        
        result = subprocess.run(cmd, capture_output=True, text=True, cwd=str(script_dir))
        
        # Print output
        if result.stdout:
            print("STDOUT:", result.stdout)
        if result.stderr:
            print("STDERR:", result.stderr)
        
        if result.returncode == 0:
            print("✅ Slice automation completed successfully")
            return True
        else:
            print(f"❌ Slice automation failed with return code: {result.returncode}")
            return False
    
    except Exception as e:
        print(f"❌ Error running slice automation: {e}")
        return False
    
    finally:
        # Clean up temporary script
        if slice_script.exists():
            slice_script.unlink()


def main():
    """Main function."""
    if len(sys.argv) != 2:
        print("❌ Error: Please provide an STL file path")
        print("Usage: python bulletproof_pipeline.py <input_stl_file>")
        print("Example: python bulletproof_pipeline.py C:\\path\\to\\model.stl")
        sys.exit(1)
    
    input_stl = sys.argv[1]
    
    print("🚀 Bulletproof STL to Hull Baseplate Pipeline (Windows)")
    print(f"📁 Input STL: {input_stl}")
    print("")
    
    # Check input file
    if not os.path.exists(input_stl):
        print(f"❌ Error: Input STL file not found: {input_stl}")
        sys.exit(1)
    
    if not input_stl.lower().endswith('.stl'):
        print(f"❌ Error: Input file must be an STL file: {input_stl}")
        sys.exit(1)
    
    # Setup environment
    script_dir = setup_environment()
    
    # Test prerequisites
    if not test_prerequisites():
        print("❌ Prerequisites failed. Please fix the issues above.")
        sys.exit(1)
    
    # Run slice automation
    if not run_slice_automation(input_stl, script_dir):
        print("❌ Slice automation failed.")
        sys.exit(1)
    
    print("🎉 Pipeline completed successfully!")


if __name__ == "__main__":
    main()
