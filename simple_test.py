#!/usr/bin/env python3
"""
Simple test script to verify everything works.
"""

import os
import sys
from pathlib import Path

def test_basic_imports():
    """Test basic Python functionality."""
    print("🔍 Testing basic Python functionality...")
    try:
        import os
        import sys
        import time
        import subprocess
        from pathlib import Path
        print("✅ Basic Python modules imported successfully")
        return True
    except Exception as e:
        print(f"❌ Basic import failed: {e}")
        return False

def test_automation_imports():
    """Test automation module imports."""
    print("🔍 Testing automation module imports...")
    try:
        # Add current directory to path
        current_dir = Path(__file__).parent
        if str(current_dir) not in sys.path:
            sys.path.insert(0, str(current_dir))
        
        from automation_windows import BambuStudioAutomation, slice_stl_file, import_move_slice_file
        print("✅ Automation modules imported successfully")
        return True
    except Exception as e:
        print(f"❌ Automation import failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_bambu_detection():
    """Test Bambu Studio detection."""
    print("🔍 Testing Bambu Studio detection...")
    try:
        from automation_windows import BambuStudioAutomation
        automation = BambuStudioAutomation()
        print(f"✅ Bambu Studio found at: {automation.bambu_studio_path}")
        return True
    except Exception as e:
        print(f"❌ Bambu Studio detection failed: {e}")
        return False

def test_pyautogui():
    """Test pyautogui functionality."""
    print("🔍 Testing pyautogui functionality...")
    try:
        import pyautogui
        print("✅ pyautogui imported successfully")
        
        # Test basic pyautogui functionality
        screen_size = pyautogui.size()
        print(f"✅ Screen size detected: {screen_size}")
        
        # Test window detection
        import pygetwindow as gw
        windows = gw.getAllWindows()
        print(f"✅ Found {len(windows)} windows")
        
        return True
    except Exception as e:
        print(f"❌ pyautogui test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Run all tests."""
    print("🧪 Simple Windows Automation Test")
    print("=" * 50)
    
    tests = [
        ("Basic Python", test_basic_imports),
        ("Automation Imports", test_automation_imports),
        ("Bambu Studio Detection", test_bambu_detection),
        ("PyAutoGUI", test_pyautogui),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n--- {test_name} ---")
        if test_func():
            passed += 1
            print(f"✅ {test_name} PASSED")
        else:
            print(f"❌ {test_name} FAILED")
    
    print("\n" + "=" * 50)
    print(f"Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! The automation should work.")
        return True
    else:
        print("❌ Some tests failed. Check the error messages above.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
