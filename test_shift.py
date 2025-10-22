#!/usr/bin/env python3
"""
Quick diagnostic to test if SHIFT can be held down properly
"""

import pyautogui
import time

def test_shift_holding():
    """Test if pyautogui can hold SHIFT down properly"""
    
    print("Testing SHIFT key holding...")
    print("This will open Notepad and test if SHIFT works")
    print("You should see 'A' typed (uppercase) if SHIFT is working")
    print("Starting test in 3 seconds...")
    time.sleep(3)
    
    # Configure pyautogui
    pyautogui.FAILSAFE = True
    pyautogui.PAUSE = 0.1
    
    try:
        # Open Notepad
        print("Opening Notepad...")
        pyautogui.hotkey('win', 'r')
        time.sleep(1)
        pyautogui.write('notepad')
        time.sleep(1)
        pyautogui.press('enter')
        time.sleep(2)
        
        print("Testing SHIFT + 'a' (should type 'A')...")
        
        # Test SHIFT holding
        pyautogui.keyDown('shift')
        time.sleep(0.1)
        pyautogui.typewrite('a')   # should send "A"
        pyautogui.keyUp('shift')
        
        time.sleep(1)
        
        print("Testing SHIFT + arrow keys...")
        
        # Test SHIFT + arrow
        pyautogui.keyDown('shift')
        time.sleep(0.06)  # Small delay as suggested
        pyautogui.keyDown('right')
        pyautogui.keyUp('right')
        time.sleep(0.1)
        pyautogui.keyUp('shift')
        
        print("Test completed!")
        print("Check Notepad:")
        print("- Did it type 'A' (uppercase) or 'a' (lowercase)?")
        print("- Did the cursor move right by 1mm or 10mm?")
        print("Close Notepad when done checking")
        
        return True
        
    except Exception as e:
        print(f"ERROR: {e}")
        return False

if __name__ == "__main__":
    test_shift_holding()
