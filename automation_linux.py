"""
Linux automation module for Bambu Studio control using Flatpak and pyautogui.

This module is designed to mirror the public interface of the existing
Windows and macOS automation modules, so the rest of the pipeline can
remain unchanged.

Notes:
- Target environment is Ubuntu 24.04 (and other modern Linux distros)
  with Bambu Studio installed as the Flatpak app `com.bambulab.BambuStudio`.
- This implementation uses simple timing-based automation similar to
  `automation_windows.py` (no deep window inspection).
- For best results, run under an X11 session and avoid interacting with
  the mouse/keyboard while automation is running.
"""

import os
import time
import subprocess
from pathlib import Path

import pyautogui


class BambuStudioAutomation:
    """Linux automation class for Bambu Studio operations."""

    def __init__(self, bambu_studio_cmd=None):
        """
        Initialize the automation class.

        Args:
            bambu_studio_cmd (list[str] | None): Command to start Bambu Studio.
                Defaults to ['flatpak', 'run', 'com.bambulab.BambuStudio'].
        """
        self.bambu_studio_cmd = bambu_studio_cmd or self._default_flatpak_command()

        # Configure pyautogui to behave similarly across platforms
        pyautogui.FAILSAFE = True
        pyautogui.PAUSE = 0.1

    def _default_flatpak_command(self):
        """
        Return the default Flatpak command for Bambu Studio.

        This does not validate installation; failures will surface when
        `start_bambu_studio` runs.
        """
        return ["flatpak", "run", "com.bambulab.BambuStudio"]

    def _type_text(self, text, delay=0.05):
        """Type text with an optional delay between characters."""
        try:
            pyautogui.typewrite(text, interval=delay)
            time.sleep(0.5)
            return True
        except Exception as e:
            print(f"[LINUX][ERROR] Error typing text: {e}")
            return False

    def _press_key_combination(self, *keys):
        """Press a key combination (e.g., Ctrl+N)."""
        try:
            pyautogui.hotkey(*keys)
            time.sleep(0.5)
            return True
        except Exception as e:
            print(f"[LINUX][ERROR] Error pressing key combination {keys}: {e}")
            return False

    def _press_arrow_key(self, direction, count=1, with_shift=False):
        """
        Press arrow keys with optional Shift modifier for 1mm moves.

        direction: 'left', 'right', 'up', or 'down'
        """
        try:
            for _ in range(count):
                if with_shift:
                    pyautogui.keyDown("shift")
                    pyautogui.press(direction)
                    pyautogui.keyUp("shift")
                else:
                    pyautogui.press(direction)
                time.sleep(0.1)
            return True
        except Exception as e:
            print(f"[LINUX][ERROR] Error pressing arrow key '{direction}': {e}")
            return False

    def _click_center(self):
        """
        Click roughly the center of the primary screen to ensure Bambu Studio
        has focus before sending keyboard shortcuts.
        """
        try:
            width, height = pyautogui.size()
            x = int(width / 2)
            y = int(height / 2)
            print(f"[LINUX] Clicking screen center at ({x}, {y}) to focus Bambu Studio...")
            pyautogui.click(x, y)
            time.sleep(0.5)
            return True
        except Exception as e:
            print(f"[LINUX][ERROR] Error clicking screen center: {e}")
            return False

    def start_bambu_studio(self):
        """Start Bambu Studio via Flatpak and wait for it to be ready."""
        print(f"[LINUX] Starting Bambu Studio with command: {' '.join(self.bambu_studio_cmd)}")
        try:
            proc = subprocess.Popen(self.bambu_studio_cmd)
            print(f"[LINUX] Bambu Studio process started with PID: {proc.pid}")

            # Give Bambu Studio time to open and grab focus.
            # This mirrors the conservative timing used on Windows.
            time.sleep(20)
            print("[LINUX] Bambu Studio startup delay complete")
            return True
        except FileNotFoundError:
            print(
                "[LINUX][ERROR] Failed to start Bambu Studio. "
                "Is Flatpak installed and is com.bambulab.BambuStudio installed?"
            )
            return False
        except Exception as e:
            print(f"[LINUX][ERROR] Unexpected error starting Bambu Studio: {e}")
            return False

    def quit_bambu_studio(self):
        """Close Bambu Studio safely using Flatpak kill (safer than Alt+F4)."""
        print("[LINUX] Closing Bambu Studio...")
        try:
            # Check if Bambu Studio is actually running first
            try:
                result = subprocess.run(
                    ["flatpak", "ps", "--columns=application"],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                if "com.bambulab.BambuStudio" not in result.stdout:
                    print("[LINUX] Bambu Studio is not running, nothing to close")
                    return True
            except:
                # If we can't check, proceed anyway - better safe than sorry
                pass
            
            # Use Flatpak kill - this is safer than Alt+F4 which can trigger logout
            print("[LINUX] Using Flatpak kill to close Bambu Studio...")
            try:
                result = subprocess.run(
                    ["flatpak", "kill", "com.bambulab.BambuStudio"],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                # flatpak kill returns 0 if successful, or non-zero if app wasn't running
                # Both are fine - we just want to ensure it's closed
                time.sleep(2)
                print("[LINUX] Bambu Studio closed")
                return True
            except subprocess.TimeoutExpired:
                print("[LINUX] Flatpak kill timed out, but continuing...")
                return True
            except FileNotFoundError:
                print("[LINUX] Flatpak command not found, trying Ctrl+Q as fallback...")
                # Fallback to Ctrl+Q if Flatpak isn't available
                self._click_center()
                time.sleep(0.5)
                self._press_key_combination("ctrl", "q")
                time.sleep(3)
                return True
            except Exception as e:
                print(f"[LINUX] Flatpak kill had issue (may be fine if already closed): {e}")
                return True
                
        except Exception as e:
            print(f"[LINUX][ERROR] Error closing Bambu Studio: {e}")
            # Try Flatpak kill as last resort
            try:
                subprocess.run(
                    ["flatpak", "kill", "com.bambulab.BambuStudio"],
                    capture_output=True,
                    timeout=5
                )
            except:
                pass
            return False

    # ------------------------------------------------------------------
    # Public high-level operations (mirror other platforms)
    # ------------------------------------------------------------------

    def slice_3mf(self, three_mf_path, output_gcode_3mf=None,
                  slice_delay=15, file_load_delay=8, quit_after=False, new_project=False):
        """
        Open a 3MF project file, slice it, and export as G-code 3MF on Linux.

        Keyboard sequence (as requested):
        1. Start Bambu Studio
        2. Ctrl+N to create new project (if new_project=True)
        3. Ctrl+I to open 3MF import dialog
        4. Ctrl+L to focus path entry
        5. Type input 3MF path, Enter
        6. Ctrl+R to slice
        7. Ctrl+G to save
        8. Ctrl+A to select path field, type output path, Enter (twice)
        9. Alt+F4 to close (if quit_after is True)

        Args:
            new_project (bool): If True, create a new project (Ctrl+N) before importing.
                Useful when Bambu Studio already has a project open.
        """
        three_mf_path = os.path.abspath(three_mf_path)
        if output_gcode_3mf is None:
            base = os.path.splitext(os.path.basename(three_mf_path))[0]
            if base.endswith(".gcode"):
                base = base[:-6]
            output_gcode_3mf = os.path.join(
                os.path.dirname(three_mf_path),
                f"{base}.gcode.3mf",
            )
        else:
            output_gcode_3mf = os.path.abspath(output_gcode_3mf)

        print(f"[LINUX] Slicing 3MF file: {three_mf_path}")
        print(f"[LINUX] Output gcode.3mf: {output_gcode_3mf}")

        if not os.path.exists(three_mf_path):
            print(f"[LINUX][ERROR] 3MF file not found: {three_mf_path}")
            return False

        # Ensure Bambu Studio is running and ready
        print("[LINUX] Starting Bambu Studio (for 3MF slice)...")
        if not self.start_bambu_studio():
            print("[LINUX][ERROR] Failed to start Bambu Studio")
            return False

        try:
            # 0) Create new project if requested (useful when previous project is still open)
            if new_project:
                print("[LINUX] Creating new project (Ctrl+N)...")
                if not self._press_key_combination("ctrl", "n"):
                    return False
                time.sleep(4)

            # 1) Import 3MF: Ctrl+I, then Ctrl+L to focus path entry
            print("[LINUX] Opening import dialog (Ctrl+I)...")
            if not self._press_key_combination("ctrl", "i"):
                return False
            time.sleep(file_load_delay)

            print("[LINUX] Focusing path entry (Ctrl+L)...")
            if not self._press_key_combination("ctrl", "l"):
                return False
            time.sleep(1)

            print(f"[LINUX] Typing 3MF path: {three_mf_path}")
            if not self._type_text(three_mf_path):
                return False
            time.sleep(1)
            pyautogui.press("enter")
            time.sleep(file_load_delay)

            # Ensure Bambu Studio window is focused before slicing
            self._click_center()

            # 2) Slice: Ctrl+R
            print("[LINUX] Slicing model (Ctrl+R)... (waiting a bit after import)")
            # Extra wait after import so Bambu Studio can fully parse the project
            time.sleep(5)
            if not self._press_key_combination("ctrl", "r"):
                return False
            print(f"[LINUX] Waiting {slice_delay}s for slicing to complete...")
            time.sleep(slice_delay)

            # 3) Export gcode: Ctrl+G
            print("[LINUX] Exporting gcode.3mf (Ctrl+G)...")
            if not self._press_key_combination("ctrl", "g"):
                return False
            time.sleep(4)

            # 4) Ctrl+A to select entire path field, then type output path
            print("[LINUX] Selecting path field (Ctrl+A) and typing output path...")
            if not self._press_key_combination("ctrl", "a"):
                return False
            time.sleep(0.5)

            if not self._type_text(output_gcode_3mf):
                return False
            time.sleep(1)
            pyautogui.press("enter")
            time.sleep(0.5)
            pyautogui.press("enter")
            time.sleep(5)

            # 5) Optionally close Bambu Studio
            if quit_after:
                self.quit_bambu_studio()

            print("[LINUX] 3MF slicing completed successfully")
            return True

        except Exception as e:
            print(f"[LINUX][ERROR] Exception during 3MF slicing: {e}")
            return False

    def slice_stl(self, stl_path, output_dir=None):
        """
        Slice an STL file using Bambu Studio on Linux.

        Args:
            stl_path (str): Path to the STL file.
            output_dir (str | None): Optional directory to save output files.

        Returns:
            bool: True if successful, False otherwise.
        """
        stl_path = os.path.abspath(stl_path)
        print(f"[LINUX] Slicing STL file: {stl_path}")

        if not os.path.exists(stl_path):
            print(f"[LINUX][ERROR] STL file not found: {stl_path}")
            return False

        # Start Bambu Studio
        print("[LINUX] Starting Bambu Studio...")
        if not self.start_bambu_studio():
            print("[LINUX][ERROR] Failed to start Bambu Studio")
            return False

        try:
            # New project (Ctrl+N)
            print("[LINUX] Creating new project (Ctrl+N)...")
            if not self._press_key_combination("ctrl", "n"):
                return False
            time.sleep(4)

            # Import STL (Ctrl+I)
            print("[LINUX] Importing STL (Ctrl+I)...")
            if not self._press_key_combination("ctrl", "i"):
                return False
            time.sleep(6)

            # Type full STL path and confirm
            print(f"[LINUX] Typing STL path: {stl_path}")
            if not self._type_text(stl_path):
                return False
            time.sleep(2)
            pyautogui.press("enter")
            time.sleep(10)

            # Slice (Ctrl+R)
            print("[LINUX] Slicing model (Ctrl+R)...")
            if not self._press_key_combination("ctrl", "r"):
                return False

            # Conservative wait for slicing (depends on model and hardware)
            print("[LINUX] Waiting 90 seconds for slicing to complete...")
            time.sleep(90)

            # Compute expected output paths (same folder as STL)
            stl_dir = os.path.dirname(stl_path)
            stl_name = os.path.splitext(os.path.basename(stl_path))[0]
            output_gcode_3mf = os.path.join(stl_dir, f"{stl_name}.gcode.3mf")
            output_3mf = os.path.join(stl_dir, f"{stl_name}.3mf")

            # Export gcode (Ctrl+G)
            print("[LINUX] Exporting gcode (Ctrl+G)...")
            if not self._press_key_combination("ctrl", "g"):
                return False
            time.sleep(6)

            print(f"[LINUX] Typing gcode output path: {output_gcode_3mf}")
            if not self._type_text(output_gcode_3mf):
                return False
            time.sleep(1)
            pyautogui.press("enter")
            time.sleep(4)

            # Save project (Ctrl+S)
            print("[LINUX] Saving project (Ctrl+S)...")
            if not self._press_key_combination("ctrl", "s"):
                return False
            time.sleep(6)

            print(f"[LINUX] Typing project output path: {output_3mf}")
            if not self._type_text(output_3mf):
                return False
            time.sleep(1)
            pyautogui.press("enter")
            time.sleep(4)

            # Close Bambu Studio (Alt+F4)
            print("[LINUX] Closing Bambu Studio (Alt+F4)...")
            if not self._press_key_combination("alt", "f4"):
                return False
            time.sleep(2)

            print("[LINUX] STL slicing completed successfully")
            return True

        except Exception as e:
            print(f"[LINUX][ERROR] Exception during STL slicing: {e}")
            return False

    def import_move_slice(self, stl_path, x_moves, y_moves, output_gcode_3mf, output_3mf):
        """
        Import an STL file, move it, slice it, and export the results on Linux.

        Args:
            stl_path (str): Path to the STL file.
            x_moves (int): Number of 1mm moves in X direction (right positive).
            y_moves (int): Number of 1mm moves in Y direction (up positive).
            output_gcode_3mf (str): Path for output gcode.3mf file.
            output_3mf (str): Path for output .3mf file.

        Returns:
            bool: True if successful, False otherwise.
        """
        stl_path = os.path.abspath(stl_path)
        output_gcode_3mf = os.path.abspath(output_gcode_3mf)
        output_3mf = os.path.abspath(output_3mf)

        print(f"[LINUX] Import/move/slice STL: {stl_path}")
        print(f"[LINUX] X moves: {x_moves}, Y moves: {y_moves}")
        print(f"[LINUX] G-code output: {output_gcode_3mf}")
        print(f"[LINUX] Project output: {output_3mf}")

        if not os.path.exists(stl_path):
            print(f"[LINUX][ERROR] STL file not found: {stl_path}")
            return False

        # Start Bambu Studio
        print("[LINUX] Starting Bambu Studio...")
        if not self.start_bambu_studio():
            print("[LINUX][ERROR] Failed to start Bambu Studio")
            return False

        try:
            # New project (Ctrl+N)
            print("[LINUX] Creating new project (Ctrl+N)...")
            if not self._press_key_combination("ctrl", "n"):
                return False
            time.sleep(4)

            # Import STL (Ctrl+I)
            print("[LINUX] Importing STL (Ctrl+I)...")
            if not self._press_key_combination("ctrl", "i"):
                return False
            time.sleep(6)

            print(f"[LINUX] Typing STL path: {stl_path}")
            if not self._type_text(stl_path):
                return False
            time.sleep(2)
            pyautogui.press("enter")
            time.sleep(10)

            # Assume object is selected; move using Shift+arrow keys
            if x_moves != 0:
                direction = "right" if x_moves > 0 else "left"
                print(f"[LINUX] Moving in X: {x_moves} steps ({direction})...")
                if not self._press_arrow_key(direction, abs(x_moves), with_shift=True):
                    return False

            if y_moves != 0:
                # Convention: positive Y = up, negative Y = down
                direction = "up" if y_moves > 0 else "down"
                print(f"[LINUX] Moving in Y: {y_moves} steps ({direction})...")
                if not self._press_arrow_key(direction, abs(y_moves), with_shift=True):
                    return False

            time.sleep(1)

            # Slice (Ctrl+R)
            print("[LINUX] Slicing model (Ctrl+R)...")
            if not self._press_key_combination("ctrl", "r"):
                return False

            print("[LINUX] Waiting 30 seconds for slicing to complete...")
            time.sleep(30)

            # Export gcode (Ctrl+G)
            print("[LINUX] Exporting gcode (Ctrl+G)...")
            if not self._press_key_combination("ctrl", "g"):
                return False
            time.sleep(6)

            print(f"[LINUX] Typing gcode output path: {output_gcode_3mf}")
            if not self._type_text(output_gcode_3mf):
                return False
            time.sleep(1)
            pyautogui.press("enter")
            time.sleep(2)
            pyautogui.press("enter")
            time.sleep(5)

            # Save project (Ctrl+S)
            print("[LINUX] Saving project (Ctrl+S)...")
            if not self._press_key_combination("ctrl", "s"):
                return False
            time.sleep(6)

            print(f"[LINUX] Typing project output path: {output_3mf}")
            if not self._type_text(output_3mf):
                return False
            time.sleep(1)
            pyautogui.press("enter")
            time.sleep(2)
            pyautogui.press("enter")
            time.sleep(5)

            # Close Bambu Studio (Alt+F4)
            print("[LINUX] Closing Bambu Studio (Alt+F4)...")
            if not self._press_key_combination("alt", "f4"):
                return False
            time.sleep(2)

            print("[LINUX] Import/move/slice completed successfully")
            return True

        except Exception as e:
            print(f"[LINUX][ERROR] Exception during import/move/slice: {e}")
            return False


# Convenience functions (match other automation modules)

def slice_stl_file(stl_path, output_dir=None):
    """
    Slice an STL file using Bambu Studio on Linux.

    Signature matches the Windows/macOS helpers so callers don't change.
    """
    automation = BambuStudioAutomation()
    return automation.slice_stl(stl_path, output_dir)


def import_move_slice_file(stl_path, x_moves, y_moves, output_gcode_3mf, output_3mf):
    """
    Import an STL file, move it, slice it, and export the results on Linux.
    """
    automation = BambuStudioAutomation()
    return automation.import_move_slice(stl_path, x_moves, y_moves, output_gcode_3mf, output_3mf)

