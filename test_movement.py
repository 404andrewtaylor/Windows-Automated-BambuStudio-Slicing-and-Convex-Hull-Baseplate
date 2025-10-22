#!/usr/bin/env python3
"""
Simple test script to test hull movement in Bambu Studio
"""

import os
import sys
import time
import subprocess
import pyautogui
from automation_windows import BambuStudioAutomation

def test_movement():
    """Test hull movement in Bambu Studio"""
    
    # Path to hull STL
    hull_stl = r"C:\path\to\your\model_pipeline\your_model_hull.stl"
    
    if not os.path.exists(hull_stl):
        print(f"ERROR: Hull STL not found: {hull_stl}")
        return False
    
    print(f"Testing movement with hull: {hull_stl}")
    
    # Configure pyautogui
    pyautogui.FAILSAFE = True
    pyautogui.PAUSE = 0.1
    
    try:
        # Start Bambu Studio
        bambu_path = r"C:\Program Files\Bambu Studio\bambu-studio.exe"
        print("Starting Bambu Studio...")
        process = subprocess.Popen([bambu_path])
        print(f"Bambu Studio process started with PID: {process.pid}")
        
        # Wait for Bambu Studio to start
        print("Waiting 15 seconds for Bambu Studio to start...")
        time.sleep(15)
        
        # New project (Ctrl+N)
        print("Creating new project...")
        pyautogui.hotkey('ctrl', 'n')
        time.sleep(4)
        
        # Import STL (Ctrl+I)
        print("Importing hull STL...")
        pyautogui.hotkey('ctrl', 'i')
        time.sleep(4)
        
        # Type file path
        print(f"Typing file path: {hull_stl}")
        pyautogui.write(hull_stl)
        time.sleep(2)
        
        # Press Enter to confirm import
        print("Pressing Enter to confirm import...")
        pyautogui.press('enter')
        time.sleep(10)
        
        print("Hull imported. Now testing movement...")
        print("Press Ctrl+C to stop the test")
        
        # Create automation instance
        automation = BambuStudioAutomation()
        
        # Test movement - move 1 step right
        print("Moving 1 step RIGHT (SHIFT+Right Arrow)...")
        automation._press_arrow_key('right', 1, with_shift=True)
        time.sleep(2)
        
        print("Moving 1 step LEFT (SHIFT+Left Arrow)...")
        automation._press_arrow_key('left', 1, with_shift=True)
        time.sleep(2)
        
        print("Moving 1 step UP (SHIFT+Up Arrow)...")
        automation._press_arrow_key('up', 1, with_shift=True)
        time.sleep(2)
        
        print("Moving 1 step DOWN (SHIFT+Down Arrow)...")
        automation._press_arrow_key('down', 1, with_shift=True)
        time.sleep(2)
        
        print("Movement test completed!")
        print("Check if the hull moved by 1mm for each direction")
        
        # Keep Bambu Studio open for manual inspection
        print("Bambu Studio will stay open for manual inspection...")
        print("Close it manually when done")
        
        return True
        
    except KeyboardInterrupt:
        print("\nTest interrupted by user")
        return False
    except Exception as e:
        print(f"ERROR: {e}")
        return False

if __name__ == "__main__":
    test_movement()
