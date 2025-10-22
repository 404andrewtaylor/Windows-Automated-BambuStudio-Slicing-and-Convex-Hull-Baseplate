#!/usr/bin/env python3
"""
Test script for the Hull Baseplate Pipeline GUI.
This script tests the GUI components without running the full pipeline.
"""

import tkinter as tk
from tkinter import messagebox
import sys
import os

def test_gui_imports():
    """Test if GUI can be imported and basic components work."""
    try:
        from hull_baseplate_gui import HullBaseplateApp
        print("✅ GUI module imported successfully")
        return True
    except ImportError as e:
        print(f"❌ Failed to import GUI module: {e}")
        return False

def test_gui_creation():
    """Test if GUI can be created without errors."""
    try:
        root = tk.Tk()
        root.withdraw()  # Hide the window
        
        app = HullBaseplateApp(root)
        print("✅ GUI created successfully")
        
        # Test basic functionality
        app.stl_path_var.set("test.stl")
        app.output_path_var.set("C:\\test")
        
        # Test navigation
        app.go_to_file_selection()
        app.go_to_progress()
        app.go_to_setup()
        
        root.destroy()
        print("✅ GUI navigation works")
        return True
    except Exception as e:
        print(f"❌ Failed to create GUI: {e}")
        return False

def test_dependencies():
    """Test if required dependencies are available."""
    dependencies = [
        'tkinter',
        'numpy',
        'scipy',
        'matplotlib',
        'pyautogui',
        'pydirectinput'
    ]
    
    missing = []
    for dep in dependencies:
        try:
            if dep == 'tkinter':
                import tkinter
            else:
                __import__(dep)
            print(f"✅ {dep} available")
        except ImportError:
            print(f"❌ {dep} missing")
            missing.append(dep)
    
    return len(missing) == 0, missing

def main():
    """Run all tests."""
    print("Hull Baseplate Pipeline GUI - Test Suite")
    print("=" * 40)
    
    # Test 1: Dependencies
    print("\n1. Testing dependencies...")
    deps_ok, missing = test_dependencies()
    
    if not deps_ok:
        print(f"\n❌ Missing dependencies: {', '.join(missing)}")
        print("Install with: pip install " + " ".join(missing))
        return False
    
    # Test 2: GUI imports
    print("\n2. Testing GUI imports...")
    if not test_gui_imports():
        return False
    
    # Test 3: GUI creation
    print("\n3. Testing GUI creation...")
    if not test_gui_creation():
        return False
    
    print("\n✅ All tests passed!")
    print("The GUI should work correctly.")
    return True

if __name__ == "__main__":
    success = main()
    if not success:
        sys.exit(1)
