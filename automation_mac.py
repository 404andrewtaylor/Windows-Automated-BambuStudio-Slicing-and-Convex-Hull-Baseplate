"""
Mac automation module for Bambu Studio control using AppleScript.

This module provides Mac-specific automation for the STL to Hull Baseplate Pipeline,
wrapping the existing AppleScript functionality.
"""

import os
import sys
import subprocess
import time
from pathlib import Path


class BambuStudioAutomation:
    """Mac automation class for Bambu Studio operations using AppleScript."""
    
    def __init__(self, bambu_studio_path="/Applications/BambuStudio.app"):
        """
        Initialize the automation class.
        
        Args:
            bambu_studio_path (str): Path to Bambu Studio application
        """
        self.bambu_studio_path = bambu_studio_path
        
        if not os.path.exists(self.bambu_studio_path):
            raise FileNotFoundError(f"Bambu Studio not found at: {self.bambu_studio_path}")
    
    def _run_applescript(self, script):
        """
        Run an AppleScript command.
        
        Args:
            script (str): AppleScript code to execute
        
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            result = subprocess.run(
                ["osascript", "-e", script],
                capture_output=True,
                text=True,
                check=True
            )
            return True
        except subprocess.CalledProcessError as e:
            print(f"❌ AppleScript error: {e}")
            print(f"   stderr: {e.stderr}")
            return False
        except Exception as e:
            print(f"❌ Error running AppleScript: {e}")
            return False
    
    def start_bambu_studio(self):
        """Start Bambu Studio application."""
        print(f"🚀 Starting Bambu Studio: {self.bambu_studio_path}")
        try:
            subprocess.Popen(["open", "-a", "BambuStudio"])
            time.sleep(3)  # Wait for application to start
            return True
        except Exception as e:
            print(f"❌ Error starting Bambu Studio: {e}")
            return False
    
    def quit_bambu_studio(self):
        """Quit Bambu Studio application."""
        print("🔒 Closing Bambu Studio...")
        script = '''
        tell application "BambuStudio" to quit
        delay 1
        '''
        return self._run_applescript(script)
    
    def slice_stl(self, stl_path, output_dir=None):
        """
        Slice an STL file using Bambu Studio.
        
        Args:
            stl_path (str): Path to the STL file
            output_dir (str, optional): Directory to save output files
        
        Returns:
            bool: True if successful, False otherwise
        """
        print(f"🔧 Slicing STL file: {stl_path}")
        
        # Start Bambu Studio
        if not self.start_bambu_studio():
            return False
        
        # Create AppleScript for slicing
        script = f'''
        on run argv
            tell application "BambuStudio" to activate
            delay 3
            tell application "System Events"
                tell process "BambuStudio"
                    keystroke "n" using command down
                    delay 0.05
                    delay 2
                    keystroke "i" using command down
                    delay 0.05
                    delay 2
                    keystroke "G" using {{shift down, command down}}
                    delay 0.05
                    delay 1
                    keystroke "{stl_path}"
                    delay 0.05
                    delay 1
                    keystroke return
                    delay 0.05
                    delay 2
                    keystroke return
                    delay 0.05
                    delay 5
                    keystroke "r" using command down
                    delay 0.05
                    delay 30
                    keystroke "g" using command down
                    delay 0.05
                    delay 4
                    -- Save exported file to same directory as STL
                    set stlDir to do shell script "dirname " & quoted form of "{stl_path}"
                    repeat with i from 1 to count of characters of stlDir
                        keystroke character i of stlDir
                        delay 0.05
                    end repeat
                    delay 2
                    keystroke return
                    delay 0.05
                    delay 2
                    keystroke return
                    delay 0.05
                    delay 5
                    -- Save project file
                    keystroke "s" using command down
                    delay 0.05
                    delay 4
                    repeat with i from 1 to count of characters of stlDir
                        keystroke character i of stlDir
                        delay 0.05
                    end repeat
                    delay 2
                    keystroke return
                    delay 0.05
                    delay 2
                    keystroke return
                    delay 0.05
                    delay 5
                    keystroke "q" using command down
                    delay 0.05
                end tell
            end tell
        end run
        '''
        
        return self._run_applescript(script)
    
    def slice_3mf(self, three_mf_path, output_gcode_3mf=None, slice_delay=15, file_load_delay=8, quit_after=False):
        """
        Open a 3MF project file, slice it, and export as G-code 3MF.
        
        Args:
            three_mf_path (str): Path to the .3mf file
            output_gcode_3mf (str, optional): Path for output .gcode.3mf file.
                If None, uses same directory as input with .gcode.3mf extension.
            slice_delay (int): Delay in seconds after starting slice (default: 15)
            file_load_delay (int): Delay in seconds after opening file (default: 8)
            quit_after (bool): Whether to quit Bambu Studio after slicing (default: False)
        
        Returns:
            bool: True if successful, False otherwise
        """
        three_mf_path = os.path.abspath(three_mf_path)
        if output_gcode_3mf is None:
            base = os.path.splitext(os.path.basename(three_mf_path))[0]
            if base.endswith('.gcode'):
                base = base[:-6]
            output_gcode_3mf = os.path.join(os.path.dirname(three_mf_path), f"{base}.gcode.3mf")
        else:
            output_gcode_3mf = os.path.abspath(output_gcode_3mf)
        
        print(f"🔧 Slicing 3MF file: {three_mf_path}")
        print(f"   Output: {output_gcode_3mf}")
        
        # Ensure Bambu Studio is running before opening file
        # Check if it's running, if not start it
        check_script = '''
        tell application "System Events"
            set isRunning to (name of processes) contains "BambuStudio"
        end tell
        return isRunning
        '''
        try:
            result = subprocess.run(
                ["osascript", "-e", check_script],
                capture_output=True,
                text=True,
                check=True
            )
            is_running = "true" in result.stdout.lower()
        except:
            is_running = False
        
        if not is_running:
            print("🚀 Bambu Studio not running, starting it...")
            if not self.start_bambu_studio():
                print("❌ Failed to start Bambu Studio")
                return False
            time.sleep(2)  # Give it a moment to fully start
        
        # Open the 3MF file in Bambu Studio via `open -a` (avoids Open dialog)
        try:
            subprocess.run(["open", "-a", "BambuStudio", three_mf_path], check=True)
            time.sleep(file_load_delay)  # Wait for file to load
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to open 3MF in Bambu Studio: {e}")
            return False
        
        # Escape for AppleScript: backslashes and quotes
        path_out_esc = output_gcode_3mf.replace("\\", "\\\\").replace('"', '\\"')
        
        # Build script - conditionally include quit command
        quit_command = ""
        if quit_after:
            quit_command = '''
                keystroke "q" using command down
                delay 1'''
        
        script = f'''
        tell application "BambuStudio" to activate
        delay 1
        tell application "System Events"
            tell process "BambuStudio"
                -- Slice (Cmd+R)
                keystroke "r" using command down
                delay {slice_delay}
                -- Export gcode (Cmd+G)
                keystroke "g" using command down
                delay 4
                -- Type full path character by character (more reliable)
                -- Type first character, wait 1 second for dialog to be ready, then type rest
                set savePath to "{path_out_esc}"
                if count of characters of savePath > 0 then
                    keystroke character 1 of savePath
                    delay 1
                    repeat with i from 2 to count of characters of savePath
                        keystroke character i of savePath
                        delay 0.05
                    end repeat
                end if
                delay 1
                keystroke return
                delay 0.5
                keystroke return
                delay 5{quit_command}
            end tell
        end tell
        '''
        
        return self._run_applescript(script)
    
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
        print(f"🎯 Importing, moving, and slicing STL: {stl_path}")
        print(f"📊 X moves: {x_moves}, Y moves: {y_moves}")
        
        # Start Bambu Studio
        if not self.start_bambu_studio():
            return False
        
        # Create AppleScript for import/move/slice
        script = f'''
        on run argv
            tell application "BambuStudio" to activate
            delay 3
            tell application "System Events"
                tell process "BambuStudio"
                    -- New project
                    keystroke "n" using command down
                    delay 0.05
                    delay 2
                    
                    -- Import STL
                    keystroke "i" using command down
                    delay 0.05
                    delay 2
                    keystroke "G" using {{shift down, command down}}
                    delay 0.05
                    delay 1
                    keystroke "{stl_path}"
                    delay 0.05
                    delay 1
                    keystroke return
                    delay 0.05
                    delay 2
                    keystroke return
                    delay 0.05
                    delay 5
                    
                    -- Select the object
                    click at {{500, 300}}
                    delay 0.5
                    
                    -- Move in X direction
                    set xMoves to {x_moves}
                    if xMoves > 0 then
                        repeat xMoves times
                            key code 124 using {{shift down}}  -- Right arrow with Shift
                            delay 0.1
                        end repeat
                    else if xMoves < 0 then
                        repeat (-xMoves) times
                            key code 123 using {{shift down}}  -- Left arrow with Shift
                            delay 0.1
                        end repeat
                    end if
                    
                    -- Move in Y direction (corrected - positive Y goes up)
                    set yMoves to {y_moves}
                    if yMoves > 0 then
                        repeat yMoves times
                            key code 126 using {{shift down}}  -- Up arrow with Shift
                            delay 0.1
                        end repeat
                    else if yMoves < 0 then
                        repeat (-yMoves) times
                            key code 125 using {{shift down}}  -- Down arrow with Shift
                            delay 0.1
                        end repeat
                    end if
                    
                    -- Wait for moves to complete
                    delay 1
                    
                    -- Slice
                    keystroke "r" using command down
                    delay 0.05
                    delay 30
                    
                    -- Export gcode
                    keystroke "g" using command down
                    delay 0.05
                    delay 4
                    -- Save exported file
                    set gcodePath to "{output_gcode_3mf}"
                    repeat with i from 1 to count of characters of gcodePath
                        keystroke character i of gcodePath
                        delay 0.05
                    end repeat
                    delay 2
                    keystroke return
                    delay 0.05
                    delay 2
                    keystroke return
                    delay 0.05
                    delay 5
                    
                    -- Save project file
                    keystroke "s" using command down
                    delay 0.05
                    delay 4
                    set projectPath to "{output_3mf}"
                    repeat with i from 1 to count of characters of projectPath
                        keystroke character i of projectPath
                        delay 0.05
                    end repeat
                    delay 2
                    keystroke return
                    delay 0.05
                    delay 2
                    keystroke return
                    delay 0.05
                    delay 5
                    
                    -- Quit
                    keystroke "q" using command down
                    delay 0.05
                end tell
            end tell
        end run
        '''
        
        return self._run_applescript(script)


# Convenience functions
def slice_3mf_file(three_mf_path, output_gcode_3mf=None):
    """
    Slice a 3MF file using Bambu Studio on Mac.
    
    Args:
        three_mf_path (str): Path to the .3mf file
        output_gcode_3mf (str, optional): Path for output .gcode.3mf file
    
    Returns:
        bool: True if successful, False otherwise
    """
    automation = BambuStudioAutomation()
    return automation.slice_3mf(three_mf_path, output_gcode_3mf)


def slice_stl_file(stl_path, output_dir=None):
    """
    Slice an STL file using Bambu Studio on Mac.
    
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
    Import an STL file, move it, slice it, and export the results on Mac.
    
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
