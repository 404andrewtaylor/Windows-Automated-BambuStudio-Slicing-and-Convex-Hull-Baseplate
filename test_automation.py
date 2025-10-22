#!/usr/bin/env python3
"""
Test script to debug Windows automation issues.
"""

import os
import sys
from pathlib import Path

def test_bambu_detection():
    """Test if Bambu Studio can be found."""
    print("🔍 Testing Bambu Studio detection...")
    
    try:
        from automation_windows import BambuStudioAutomation
        automation = BambuStudioAutomation()
        print(f"✅ Bambu Studio found at: {automation.bambu_studio_path}")
        return True
    except Exception as e:
        print(f"❌ Error finding Bambu Studio: {e}")
        return False

def test_imports():
    """Test if all required modules can be imported."""
    print("🔍 Testing module imports...")
    
    try:
        import pyautogui
        print("✅ pyautogui imported successfully")
    except ImportError as e:
        print(f"❌ pyautogui import failed: {e}")
        return False
    
    try:
        import pygetwindow
        print("✅ pygetwindow imported successfully")
    except ImportError as e:
        print(f"❌ pygetwindow import failed: {e}")
        return False
    
    try:
        from automation_windows import slice_stl_file
        print("✅ automation_windows imported successfully")
    except ImportError as e:
        print(f"❌ automation_windows import failed: {e}")
        return False
    
    return True

def test_simple_automation():
    """Test a simple automation operation."""
    print("🔍 Testing simple automation...")
    
    try:
        from automation_windows import BambuStudioAutomation
        automation = BambuStudioAutomation()
        
        print("🚀 Starting Bambu Studio...")
        if automation.start_bambu_studio():
            print("✅ Bambu Studio started successfully")
            print("⏳ Waiting 5 seconds...")
            import time
            time.sleep(5)
            
            print("🚪 Closing Bambu Studio...")
            # Try to close Bambu Studio
            try:
                import pyautogui
                pyautogui.hotkey('alt', 'f4')
                time.sleep(2)
                print("✅ Bambu Studio closed")
            except Exception as e:
                print(f"⚠️  Could not close Bambu Studio: {e}")
            
            return True
        else:
            print("❌ Failed to start Bambu Studio")
            return False
    except Exception as e:
        print(f"❌ Automation test failed: {e}")
        return False

def main():
    """Run all tests."""
    print("🧪 Running Windows Automation Tests")
    print("=" * 50)
    
    # Check if we're in a virtual environment
    if not hasattr(sys, 'real_prefix') and not (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix):
        print("⚠️  Warning: Not running in virtual environment.")
        print("   The test script should be run using the virtual environment Python.")
        print("   Try: venv\\Scripts\\python test_automation.py")
        print("")
    
    # Test 1: Module imports
    if not test_imports():
        print("\n❌ Module import test failed.")
        print("   Try running: venv\\Scripts\\python test_automation.py")
        return
    
    # Test 2: Bambu Studio detection
    if not test_bambu_detection():
        print("\n❌ Bambu Studio detection failed.")
        return
    
    # Test 3: Simple automation
    print("\n" + "=" * 50)
    if test_simple_automation():
        print("\n✅ All tests passed! Automation should work.")
    else:
        print("\n❌ Automation test failed. Check the error messages above.")

if __name__ == "__main__":
    main()
