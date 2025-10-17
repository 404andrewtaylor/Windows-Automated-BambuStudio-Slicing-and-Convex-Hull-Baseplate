#!/usr/bin/env python3
"""
Debug script to see what windows are available and test window focus.
"""

import pyautogui
import pygetwindow as gw
import time

def list_all_windows():
    """List all available windows."""
    print("All available windows:")
    for i, window in enumerate(gw.getAllWindows()):
        if window.title:
            print(f"  {i}: '{window.title}' - Visible: {window.visible}")

def list_bambu_windows():
    """List Bambu Studio related windows."""
    print("\nBambu Studio related windows:")
    for window in gw.getAllWindows():
        if window.title and ("Bambu" in window.title or "Import" in window.title or "Open" in window.title):
            print(f"  - '{window.title}' - Visible: {window.visible}")

def test_import_dialog():
    """Test opening import dialog and see what happens."""
    print("Starting Bambu Studio...")
    
    # Start Bambu Studio
    import subprocess
    bambu_path = r"C:\Program Files\Bambu Studio\bambu-studio.exe"
    process = subprocess.Popen([bambu_path])
    time.sleep(5)
    
    print("Bambu Studio started, listing windows...")
    list_bambu_windows()
    
    print("\nPressing Ctrl+N to create new project...")
    pyautogui.hotkey('ctrl', 'n')
    time.sleep(2)
    
    print("After new project:")
    list_bambu_windows()
    
    print("\nPressing Ctrl+I to open import dialog...")
    pyautogui.hotkey('ctrl', 'i')
    time.sleep(3)
    
    print("After import dialog:")
    list_bambu_windows()
    
    print("\nAll windows after import dialog:")
    list_all_windows()

if __name__ == "__main__":
    test_import_dialog()