#!/usr/bin/env python3
"""
Test SHIFT key behavior as administrator
"""

import keyboard
import time

def test_shift_admin():
    """Test SHIFT key behavior with keyboard library"""
    
    print("Testing SHIFT key behavior as administrator...")
    print("This will open Notepad and test SHIFT + arrow keys")
    print("Starting test in 3 seconds...")
    time.sleep(3)
    
    try:
        # Open Notepad
        print("Opening Notepad...")
        keyboard.send('win+r')
        time.sleep(1)
        keyboard.write('notepad')
        time.sleep(1)
        keyboard.send('enter')
        time.sleep(2)
        
        print("Testing SHIFT + 'a' (should type 'A')...")
        
        # Test SHIFT + letter
        keyboard.send('shift+a')
        time.sleep(1)
        
        print("Testing SHIFT + arrow keys...")
        
        # Test SHIFT + arrow (this won't work in Notepad, but tests the key combination)
        keyboard.send('shift+right')
        time.sleep(0.5)
        keyboard.send('shift+left')
        time.sleep(0.5)
        keyboard.send('shift+up')
        time.sleep(0.5)
        keyboard.send('shift+down')
        time.sleep(0.5)
        
        print("Test completed!")
        print("Check Notepad:")
        print("- Did it type 'A' (uppercase)?")
        print("- Did the cursor move at all with arrow keys?")
        print("Close Notepad when done checking")
        
        return True
        
    except Exception as e:
        print(f"ERROR: {e}")
        return False

if __name__ == "__main__":
    test_shift_admin()
