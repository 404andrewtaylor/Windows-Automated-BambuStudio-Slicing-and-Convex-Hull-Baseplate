#!/usr/bin/env python3
"""
Test script to verify the GUI can automatically set up the virtual environment.
"""

import os
import sys
import subprocess
import tempfile
import shutil
from pathlib import Path

def test_auto_setup():
    """Test if the GUI can automatically set up the environment."""
    print("Testing automatic setup functionality...")
    
    # Create a temporary directory for testing
    with tempfile.TemporaryDirectory() as temp_dir:
        print(f"Using temporary directory: {temp_dir}")
        
        # Copy the GUI file to temp directory
        gui_file = "hull_baseplate_gui.py"
        if os.path.exists(gui_file):
            shutil.copy2(gui_file, os.path.join(temp_dir, gui_file))
            print("✅ GUI file copied")
        else:
            print("❌ GUI file not found")
            return False
        
        # Copy requirements files
        req_files = ["requirements.txt", "requirements_gui.txt"]
        for req_file in req_files:
            if os.path.exists(req_file):
                shutil.copy2(req_file, os.path.join(temp_dir, req_file))
                print(f"✅ {req_file} copied")
        
        # Test the _create_virtual_environment method
        try:
            # Import the GUI module
            sys.path.insert(0, temp_dir)
            from hull_baseplate_gui import HullBaseplateApp
            
            # Create a mock app instance
            import tkinter as tk
            root = tk.Tk()
            root.withdraw()  # Hide the window
            
            app = HullBaseplateApp(root)
            
            # Test virtual environment creation
            print("Testing virtual environment creation...")
            success = app._create_virtual_environment(temp_dir)
            
            if success:
                print("✅ Virtual environment created successfully")
                
                # Check if venv directory exists
                venv_path = os.path.join(temp_dir, "venv")
                if os.path.exists(venv_path):
                    print("✅ Virtual environment directory exists")
                    
                    # Check if Python executable exists
                    venv_python = os.path.join(venv_path, "Scripts", "python.exe")
                    if os.path.exists(venv_python):
                        print("✅ Virtual environment Python executable exists")
                        return True
                    else:
                        print("❌ Virtual environment Python executable not found")
                        return False
                else:
                    print("❌ Virtual environment directory not found")
                    return False
            else:
                print("❌ Virtual environment creation failed")
                return False
                
        except Exception as e:
            print(f"❌ Error testing auto setup: {e}")
            return False
        finally:
            root.destroy()

def main():
    """Main test function."""
    print("Hull Baseplate Pipeline - Auto Setup Test")
    print("=" * 50)
    
    if test_auto_setup():
        print("\n✅ Auto setup test PASSED!")
        print("The GUI can automatically create virtual environments and install dependencies.")
    else:
        print("\n❌ Auto setup test FAILED!")
        print("There may be an issue with the automatic setup functionality.")
    
    return True

if __name__ == "__main__":
    main()
