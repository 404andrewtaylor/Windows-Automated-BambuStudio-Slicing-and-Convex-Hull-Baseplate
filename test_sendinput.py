#!/usr/bin/env python3
"""
Test hardware-level SendInput for SHIFT + arrow keys in Bambu Studio
"""

import ctypes
import time
import subprocess
import pyautogui

# Windows API constants
user32 = ctypes.WinDLL('user32', use_last_error=True)

INPUT_KEYBOARD = 1
KEYEVENTF_KEYUP   = 0x0002
KEYEVENTF_SCANCODE = 0x0008
MAPVK_VK_TO_VSC = 0

# Virtual key codes
VK_SHIFT = 0x10
VK_RIGHT = 0x27
VK_LEFT  = 0x25
VK_UP    = 0x26
VK_DOWN  = 0x28

class KEYBDINPUT(ctypes.Structure):
    _fields_ = [
        ("wVk", ctypes.c_ushort),
        ("wScan", ctypes.c_ushort),
        ("dwFlags", ctypes.c_ulong),
        ("time", ctypes.c_ulong),
        ("dwExtraInfo", ctypes.POINTER(ctypes.c_ulong)),
    ]

class INPUT(ctypes.Structure):
    _fields_ = [("type", ctypes.c_ulong), ("ki", KEYBDINPUT)]

def map_vk_to_sc(vk): 
    return user32.MapVirtualKeyW(vk, MAPVK_VK_TO_VSC)

def send_key_combo(vk_arrow):
    """Send SHIFT + arrow key combination using hardware-level SendInput"""
    sc_shift = map_vk_to_sc(VK_SHIFT)
    sc_arrow = map_vk_to_sc(vk_arrow)
    
    def ev(sc, flags=0): 
        return INPUT(INPUT_KEYBOARD, KEYBDINPUT(0, sc, flags | KEYEVENTF_SCANCODE, 0, None))

    # Press and release sequence
    seq = [
        ev(sc_shift),                        # Shift down
        ev(sc_arrow),                        # Arrow down
        ev(sc_arrow, KEYEVENTF_KEYUP),       # Arrow up
        ev(sc_shift, KEYEVENTF_KEYUP)        # Shift up
    ]
    arr = (INPUT * len(seq))(*seq)
    user32.SendInput(len(arr), arr, ctypes.sizeof(INPUT))

def test_bambu_sendinput():
    """Test SendInput approach in Bambu Studio"""
    
    hull_stl = r"C:\path\to\your\model_pipeline\your_model_hull.stl"
    bambu_path = r"C:\Program Files\Bambu Studio\bambu-studio.exe"

    print("Testing hardware-level SendInput for SHIFT + arrow keys...")
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
    pyautogui.typewrite(hull_stl)
    time.sleep(2)
    
    print("Pressing Enter to confirm import...")
    pyautogui.press('enter')
    time.sleep(10)

    print("Hull imported. Now testing hardware-level SHIFT + arrow simulation...")
    print("Make sure Bambu Studio's 3D viewport is in focus!")
    time.sleep(2)

    print("→ Testing Shift+Right...")
    send_key_combo(VK_RIGHT)
    time.sleep(2)

    print("← Testing Shift+Left...")
    send_key_combo(VK_LEFT)
    time.sleep(2)

    print("↑ Testing Shift+Up...")
    send_key_combo(VK_UP)
    time.sleep(2)

    print("↓ Testing Shift+Down...")
    send_key_combo(VK_DOWN)
    time.sleep(2)

    print("Hardware-level SendInput test completed!")
    print("Check if the hull moved by 1mm for each direction")
    print("Bambu Studio will stay open for manual inspection...")
    print("Close it manually when done")

if __name__ == "__main__":
    test_bambu_sendinput()
