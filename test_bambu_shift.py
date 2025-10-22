#!/usr/bin/env python3
"""
Test SHIFT + arrow keys specifically in Bambu Studio
"""

import keyboard
import time
import subprocess
import pyautogui

def test_bambu_shift():
    """Test SHIFT + arrow keys in Bambu Studio"""
    
    # Path to hull STL
    hull_stl = r"C:\path\to\your\model_pipeline\your_model_hull.stl"
    
    print("Testing SHIFT + arrow keys in Bambu Studio...")
    print("Starting test in 3 seconds...")
    time.sleep(3)
    
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
        keyboard.send('ctrl+n')
        time.sleep(4)
        
        # Import STL (Ctrl+I)
        print("Importing hull STL...")
        keyboard.send('ctrl+i')
        time.sleep(4)
        
        # Type file path
        print(f"Typing file path: {hull_stl}")
        keyboard.write(hull_stl)
        time.sleep(2)
        
        # Press Enter to confirm import
        print("Pressing Enter to confirm import...")
        keyboard.send('enter')
        time.sleep(10)
        
        print("Hull imported. Now testing SHIFT + arrow movement...")
        print("Testing 1 step in each direction...")
        
        # Test SHIFT + arrow movements
        print("Moving 1 step RIGHT (SHIFT+Right Arrow)...")
        keyboard.send('shift+right')
        time.sleep(2)
        
        print("Moving 1 step LEFT (SHIFT+Left Arrow)...")
        keyboard.send('shift+left')
        time.sleep(2)
        
        print("Moving 1 step UP (SHIFT+Up Arrow)...")
        keyboard.send('shift+up')
        time.sleep(2)
        
        print("Moving 1 step DOWN (SHIFT+Down Arrow)...")
        keyboard.send('shift+down')
        time.sleep(2)
        
        print("Movement test completed!")
        print("Check if the hull moved by 1mm for each direction")
        print("Bambu Studio will stay open for manual inspection...")
        print("Close it manually when done")
        
        return True
        
    except Exception as e:
        print(f"ERROR: {e}")
        return False

if __name__ == "__main__":
    test_bambu_shift()
