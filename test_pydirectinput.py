#!/usr/bin/env python3
"""
Test pydirectinput for SHIFT + arrow keys in Bambu Studio
"""

import pydirectinput
import pyautogui
import time
import subprocess

def test_bambu_pydirectinput():
    """Test pydirectinput approach in Bambu Studio"""
    
    hull_stl = r"C:\path\to\your\model_pipeline\your_model_hull.stl"
    bambu_path = r"C:\Program Files\Bambu Studio\bambu-studio.exe"

    print("Testing pydirectinput for SHIFT + arrow keys...")
    print("Starting test in 3 seconds...")
    time.sleep(3)

    print("Launching Bambu Studio...")
    subprocess.Popen([bambu_path])
    time.sleep(15)

    print("Creating new project...")
    pyautogui.hotkey('ctrl', 'n')
    time.sleep(4)
    
    print("Importing hull STL...")
    pyautogui.hotkey('ctrl', 'i')
    time.sleep(4)
    
    print(f"Typing file path: {hull_stl}")
    pyautogui.write(hull_stl)
    time.sleep(2)
    
    print("Pressing Enter to confirm import...")
    pyautogui.press('enter')
    time.sleep(10)

    print("Hull imported. Now testing pydirectinput SHIFT + arrow simulation...")
    print("Make sure Bambu Studio's 3D viewport is in focus!")
    time.sleep(2)

    print("Testing Shift+Right...")
    pydirectinput.keyDown('shift')
    pydirectinput.press('right')
    pydirectinput.keyUp('shift')
    time.sleep(2)

    print("Testing Shift+Left...")
    pydirectinput.keyDown('shift')
    pydirectinput.press('left')
    pydirectinput.keyUp('shift')
    time.sleep(2)

    print("Testing Shift+Up...")
    pydirectinput.keyDown('shift')
    pydirectinput.press('up')
    pydirectinput.keyUp('shift')
    time.sleep(2)

    print("Testing Shift+Down...")
    pydirectinput.keyDown('shift')
    pydirectinput.press('down')
    pydirectinput.keyUp('shift')
    time.sleep(2)

    print("pydirectinput test completed!")
    print("Check if the hull moved by 1mm for each direction")
    print("Bambu Studio will stay open for manual inspection...")
    print("Close it manually when done")

if __name__ == "__main__":
    test_bambu_pydirectinput()
