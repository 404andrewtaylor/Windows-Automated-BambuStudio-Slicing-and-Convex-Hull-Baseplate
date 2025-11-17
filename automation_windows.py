"""
Windows automation module for Bambu Studio control using pyautogui.

This module provides Windows-specific automation for the STL to Hull Baseplate Pipeline.
"""

import os
import sys
import time
import subprocess
import pyautogui
import pydirectinput
from pathlib import Path


def wait_for_file(file_path, timeout=120):
    """Wait for a file to be created with timeout."""
    start_time = time.time()
    while time.time() - start_time < timeout:
        if os.path.exists(file_path):
            return True
        time.sleep(1)
    raise TimeoutError(f"File not found after {timeout}s: {file_path}")




class BambuStudioAutomation:
    """Windows automation class for Bambu Studio operations."""
    
    def __init__(self, bambu_studio_path=None):
        """
        Initialize the automation class.
        
        Args:
            bambu_studio_path (str, optional): Path to Bambu Studio executable
        """
        self.bambu_studio_path = bambu_studio_path or self._find_bambu_studio()
        
        # Configure pyautogui
        pyautogui.FAILSAFE = True
        pyautogui.PAUSE = 0.1
        
    def _find_bambu_studio(self):
        """Find Bambu Studio installation on Windows."""
        possible_paths = [
            r"C:\Program Files\BambuStudio\bambu-studio.exe",
            r"C:\Program Files (x86)\BambuStudio\bambu-studio.exe",
            r"C:\Users\{}\AppData\Local\Programs\BambuStudio\bambu-studio.exe".format(os.getenv('USERNAME', '')),
            r"C:\Users\{}\AppData\Local\BambuStudio\bambu-studio.exe".format(os.getenv('USERNAME', '')),
            r"C:\Program Files\Bambu Lab\BambuStudio\bambu-studio.exe",
            r"C:\Program Files (x86)\Bambu Lab\BambuStudio\bambu-studio.exe",
            r"C:\Users\{}\AppData\Local\Bambu Lab\BambuStudio\bambu-studio.exe".format(os.getenv('USERNAME', '')),
        ]
        
        # Try to find in PATH first
        import shutil
        bambu_path = shutil.which("bambu-studio")
        if bambu_path:
            return bambu_path
        
        # Try to find by checking Start Menu shortcut
        start_menu_path = r"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Bambu Studio"
        if os.path.exists(start_menu_path):
            # Look for .lnk files in the Start Menu folder
            for file in os.listdir(start_menu_path):
                if file.endswith('.lnk'):
                    # Try to resolve the shortcut to find the actual executable
                    try:
                        import win32com.client
                        shell = win32com.client.Dispatch("WScript.Shell")
                        shortcut = shell.CreateShortCut(os.path.join(start_menu_path, file))
                        target_path = shortcut.TargetPath
                        if os.path.exists(target_path) and target_path.endswith('.exe'):
                            return target_path
                    except:
                        pass
        
        # Check common installation paths
        for path in possible_paths:
            if os.path.exists(path):
                return path
        
        # Try to find by searching for bambu-studio.exe in common locations
        search_paths = [
            r"C:\Program Files",
            r"C:\Program Files (x86)",
            os.path.expanduser(r"~\AppData\Local\Programs"),
            os.path.expanduser(r"~\AppData\Local"),
        ]
        
        for search_path in search_paths:
            if os.path.exists(search_path):
                for root, dirs, files in os.walk(search_path):
                    if "bambu-studio.exe" in files:
                        exe_path = os.path.join(root, "bambu-studio.exe")
                        if os.path.exists(exe_path):
                            return exe_path
                    # Stop searching if we've gone too deep
                    if root.count(os.sep) - search_path.count(os.sep) > 3:
                        dirs[:] = []
                
        raise FileNotFoundError("Bambu Studio not found. Please install Bambu Studio first.")
    
    
    
    def _click_at_position(self, x, y, clicks=1):
        """Click at a specific position on screen."""
        try:
            # Click at absolute position
            pyautogui.click(x, y, clicks=clicks)
            time.sleep(0.5)
            return True
        except Exception as e:
            print(f"ERROR: Error clicking at position: {e}")
            return False
    
    def _type_text(self, text, delay=0.05):
        """Type text with optional delay between characters."""
        try:
            # Simple approach - just type without complex window focus
            pyautogui.typewrite(text, interval=delay)
            time.sleep(0.5)
            return True
        except Exception as e:
            print(f"ERROR: Error typing text: {e}")
            return False
    
    def _press_key_combination(self, *keys):
        """Press a key combination (e.g., Ctrl+N)."""
        try:
            # Simple approach - just send the keys without complex window focus
            pyautogui.hotkey(*keys)
            time.sleep(0.5)
            return True
        except Exception as e:
            print(f"ERROR: Error pressing key combination: {e}")
            return False
    
    def _press_arrow_key(self, direction, count=1, with_shift=False):
        """Press arrow keys with optional shift modifier."""
        try:
            if with_shift:
                # Use pydirectinput for SHIFT + arrow combinations (bypasses Qt input filtering)
                for _ in range(count):
                    pydirectinput.keyDown('shift')
                    pydirectinput.press(direction)
                    pydirectinput.keyUp('shift')
                    time.sleep(0.1)
            else:
                # Use pyautogui for regular arrow keys
                for _ in range(count):
                    pyautogui.press(direction)
                    time.sleep(0.1)
            return True
        except Exception as e:
            print(f"ERROR: Error pressing arrow keys: {e}")
            return False
    
    def start_bambu_studio(self):
        """Start Bambu Studio application."""
        if not self.bambu_studio_path:
            print("ERROR: Bambu Studio path not found")
            return False
        
        print(f"Starting Bambu Studio: {self.bambu_studio_path}")
        try:
            # Start Bambu Studio
            process = subprocess.Popen([self.bambu_studio_path])
            print(f"Bambu Studio process started with PID: {process.pid}")
            
            # Wait for application to fully start - no window detection
            time.sleep(15)  # Just wait longer for Bambu Studio to start
            print("SUCCESS: Bambu Studio started")
            return True
                
        except Exception as e:
            print(f"ERROR: Error starting Bambu Studio: {e}")
            return False
    
    def slice_stl(self, stl_path, output_dir=None):
        """
        Slice an STL file using Bambu Studio.
        
        Args:
            stl_path (str): Path to the STL file
            output_dir (str, optional): Directory to save output files
        
        Returns:
            bool: True if successful, False otherwise
        """
        print(f"Slicing STL file: {stl_path}")
        
        try:
            # Start Bambu Studio
            print("Starting Bambu Studio...")
            if not self.start_bambu_studio():
                print("ERROR: Failed to start Bambu Studio")
                return False
            time.sleep(10)  # Doubled from 5 to 10 - Give Bambu Studio time to start
        
            # New project (Ctrl+N)
            print("Creating new project...")
            if not self._press_key_combination('ctrl', 'n'):
                print("ERROR: Failed to create new project")
                return False
            time.sleep(4)  # Doubled from 2 to 4
            
            # Import STL (Ctrl+I)
            print("Importing STL file...")
            if not self._press_key_combination('ctrl', 'i'):
                print("ERROR: Failed to open import dialog")
                return False
            time.sleep(6)  # Increased delay to ensure dialog is fully open and ready for input
            
            # Copy file path to clipboard and paste
            print(f"Copying and pasting file path: {stl_path}")
            pyautogui.write(stl_path)  # Type the file path directly
            time.sleep(2)  # Doubled from 1 to 2
            
            # Press Enter to confirm import
            print("Pressing Enter to confirm import...")
            pyautogui.press('enter')
            time.sleep(10)  # Doubled from 5 to 10
            
            # Slice (Ctrl+R)
            print("Slicing model...")
            if not self._press_key_combination('ctrl', 'r'):
                print("ERROR: Failed to start slicing")
                return False
            
            # Wait 90 seconds for slicing to complete (extra time for slower computers)
            print("Waiting 90 seconds for slicing to complete...")
            time.sleep(90)
            
            # Calculate expected output file path (convert to absolute path)
            stl_path_abs = os.path.abspath(stl_path)
            stl_dir = os.path.dirname(stl_path_abs)
            stl_name = os.path.splitext(os.path.basename(stl_path_abs))[0]
            output_gcode_3mf = os.path.join(stl_dir, f"{stl_name}.gcode.3mf")
            
            # Export gcode (Ctrl+G)
            print("Exporting gcode...")
            if not self._press_key_combination('ctrl', 'g'):
                print("ERROR: Failed to export gcode")
                return False
            time.sleep(6)  # Increased delay to ensure dialog is fully open and ready for input
            
            # Type the desired output path
            print(f"Typing output path: {output_gcode_3mf}")
            pyautogui.write(output_gcode_3mf)
            time.sleep(1)
            
            # Press Enter to confirm export
            print("Pressing Enter to confirm export...")
            pyautogui.press('enter')
            time.sleep(4)
            
            # Save project (Ctrl+S)
            print("Saving project...")
            if not self._press_key_combination('ctrl', 's'):
                print("ERROR: Failed to save project")
                return False
            time.sleep(6)  # Increased delay to ensure dialog is fully open and ready for input
            
            # Calculate 3MF output path (convert to absolute path)
            stl_path_abs = os.path.abspath(stl_path)
            stl_dir = os.path.dirname(stl_path_abs)
            stl_name = os.path.splitext(os.path.basename(stl_path_abs))[0]
            output_3mf = os.path.join(stl_dir, f"{stl_name}.3mf")
            
            # Type the desired 3MF output path
            print(f"Typing 3MF output path: {output_3mf}")
            pyautogui.write(output_3mf)
            time.sleep(1)
            
            # Press Enter to confirm save
            print("Pressing Enter to confirm save...")
            pyautogui.press('enter')
            time.sleep(4)
            
            # Save to output directory
            if output_dir:
                output_path = os.path.join(output_dir, os.path.basename(stl_path).replace('.stl', '.gcode.3mf'))
            else:
                output_path = stl_path.replace('.stl', '.gcode.3mf')
            
            print(f"Saving to: {output_path}")
            if not self._type_text(output_path):
                print("ERROR: Failed to type output path")
                return False
            
            pyautogui.press('enter')
            time.sleep(2)
            pyautogui.press('enter')
            time.sleep(5)
            
            # Save project (Ctrl+S)
            print("Saving project...")
            if not self._press_key_combination('ctrl', 's'):
                print("ERROR: Failed to save project")
                return False
            time.sleep(6)  # Increased delay to ensure dialog is fully open and ready for input
            
            project_path = stl_path.replace('.stl', '.3mf')
            print(f"Saving project to: {project_path}")
            if not self._type_text(project_path):
                print("ERROR: Failed to type project path")
                return False
            
            pyautogui.press('enter')
            time.sleep(2)
            pyautogui.press('enter')
            time.sleep(5)
            
            # Quit (Alt+F4)
            print("Closing Bambu Studio...")
            if not self._press_key_combination('alt', 'f4'):
                print("ERROR: Failed to close Bambu Studio")
                return False
            time.sleep(2)
            
            print("SUCCESS: STL slicing completed successfully")
            return True
            
        except Exception as e:
            print(f"ERROR during slicing: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    def import_move_slice(self, stl_path, x_moves, y_moves, output_gcode_3mf, output_3mf):
        """
        Import an STL file, move it, slice it, and export the results.
        
        Args:
            stl_path (str): Path to the STL file
            x_moves (int): Number of 1mm moves in X direction
            y_moves (int): Number of 1mm moves in Y direction
            output_gcode_3mf (str): Path for output gcode.3mf file
            output_3mf (str): Path for output .3mf file
        
        Returns:
            bool: True if successful, False otherwise
        """
        print(f"[IMPORT] Importing, moving, and slicing STL: {stl_path}")
        print(f"[MOVE] X moves: {x_moves}, Y moves: {y_moves}")
        
        # Start Bambu Studio
        if not self.start_bambu_studio():
            return False
        time.sleep(10)  # Doubled from 5 to 10 - Give Bambu Studio time to start
        
        try:
            # New project (Ctrl+N)
            print("Creating new project...")
            if not self._press_key_combination('ctrl', 'n'):
                return False
            time.sleep(4)  # Doubled from 2 to 4
            
            # Import STL (Ctrl+I)
            print("Importing STL file...")
            if not self._press_key_combination('ctrl', 'i'):
                return False
            time.sleep(6)  # Increased delay to ensure dialog is fully open and ready for input
            
            # Type file path directly
            print(f"Typing file path: {stl_path}")
            pyautogui.write(stl_path)
            time.sleep(2)  # Doubled from 1 to 2
            
            # Press Enter to confirm import
            pyautogui.press('enter')
            time.sleep(10)  # Doubled from 5 to 10
            
            # Object should be automatically selected after import
            print("Object should be automatically selected after import")
            time.sleep(1)
            
            # Move in X direction
            if x_moves != 0:
                print(f"Moving {x_moves} steps in X direction...")
                direction = 'right' if x_moves > 0 else 'left'
                if not self._press_arrow_key(direction, abs(x_moves), with_shift=True):
                    return False
            
            # Move in Y direction
            if y_moves != 0:
                print(f"Moving {y_moves} steps in Y direction...")
                direction = 'up' if y_moves > 0 else 'down'
                if not self._press_arrow_key(direction, abs(y_moves), with_shift=True):
                    return False
            
            # Wait for moves to complete
            time.sleep(1)
            
            # Slice (Ctrl+R)
            print("Slicing model...")
            if not self._press_key_combination('ctrl', 'r'):
                return False
            
            # Wait for slicing to complete - just wait 30 seconds
            print("Waiting 30 seconds for slicing to complete...")
            time.sleep(30)
            print("SUCCESS: Slicing completed")
            
            # Export gcode (Ctrl+G)
            print("Exporting gcode...")
            if not self._press_key_combination('ctrl', 'g'):
                return False
            time.sleep(6)  # Increased delay to ensure dialog is fully open and ready for input
            
            # Save gcode file
            print(f"Saving gcode to: {output_gcode_3mf}")
            if not self._type_text(output_gcode_3mf):
                return False
            
            pyautogui.press('enter')
            time.sleep(2)
            pyautogui.press('enter')
            time.sleep(5)
            
            # Save project (Ctrl+S)
            print("Saving project...")
            if not self._press_key_combination('ctrl', 's'):
                return False
            time.sleep(6)  # Increased delay to ensure dialog is fully open and ready for input
            
            print(f"Saving project to: {output_3mf}")
            if not self._type_text(output_3mf):
                return False
            
            pyautogui.press('enter')
            time.sleep(2)
            pyautogui.press('enter')
            time.sleep(5)
            
            # Quit (Alt+F4)
            print("Closing Bambu Studio...")
            if not self._press_key_combination('alt', 'f4'):
                return False
            time.sleep(2)
            
            print("SUCCESS: Import, move, slice completed successfully")
            return True
            
        except Exception as e:
            print(f"ERROR during import/move/slice: {e}")
            return False


# Convenience functions
def slice_stl_file(stl_path, output_dir=None):
    """
    Slice an STL file using Bambu Studio on Windows.
    
    Args:
        stl_path (str): Path to the STL file
        output_dir (str, optional): Directory to save output files
    
    Returns:
        bool: True if successful, False otherwise
    """
    automation = BambuStudioAutomation()
    return automation.slice_stl(stl_path, output_dir)


def import_move_slice_file(stl_path, x_moves, y_moves, output_gcode_3mf, output_3mf):
    """
    Import an STL file, move it, slice it, and export the results on Windows.
    
    Args:
        stl_path (str): Path to the STL file
        x_moves (int): Number of 1mm moves in X direction
        y_moves (int): Number of 1mm moves in Y direction
        output_gcode_3mf (str): Path for output gcode.3mf file
        output_3mf (str): Path for output .3mf file
    
    Returns:
        bool: True if successful, False otherwise
    """
    automation = BambuStudioAutomation()
    return automation.import_move_slice(stl_path, x_moves, y_moves, output_gcode_3mf, output_3mf)
