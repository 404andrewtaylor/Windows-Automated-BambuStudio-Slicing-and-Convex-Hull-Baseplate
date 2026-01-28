# Linux (Ubuntu) Migration Guide - Automated Baseplate Pipeline

## Overview

This guide explains how to port `slice_and_fuse_baseplates.py` to work on Linux (Ubuntu). The core baseplate generation (`gcode_to_convex_hull_3mf.py`) is already OS-agnostic, but the automation layer needs to be implemented for Linux.

---

## Current Status

### ✅ OS-Agnostic Components (Already Work on Linux)
- `gcode_to_convex_hull_3mf.py` - Core baseplate generation
- `ReplaceBaseplate/replace_baseplate_layers.py` - Baseplate fusion tool
- All Python dependencies (numpy, trimesh, etc.)

### ❌ Linux-Specific Components (Need Implementation)
- `automation_linux.py` - Linux automation module (does not exist yet)
- `slice_and_fuse_baseplates.py` - Currently Mac-only (needs Linux support)

---

## Prerequisites

### System Requirements
- **Ubuntu 20.04+** (or similar Debian-based Linux distribution)
- **Bambu Studio** installed for Linux
- **Python 3.6+**
- **X11 display server** (for GUI automation)
- **Window manager** (GNOME, KDE, XFCE, etc.)

### Required System Packages
```bash
# Install X11 automation tools
sudo apt-get update
sudo apt-get install -y \
    xdotool \
    wmctrl \
    xclip \
    python3-pip \
    python3-dev

# Install Python dependencies
pip3 install numpy trimesh pyautogui pygetwindow
```

---

## Implementation Plan

### Step 1: Create `automation_linux.py`

Create a new file `automation_linux.py` that provides the same interface as `automation_mac.py` but uses Linux automation tools.

#### Required Methods

The `BambuStudioAutomation` class needs these methods:

1. **`__init__(bambu_studio_path=None)`**
   - Find Bambu Studio installation on Linux
   - Common locations:
     - `/usr/bin/bambu-studio`
     - `/usr/local/bin/bambu-studio`
     - `~/AppImage/bambu-studio.AppImage`
     - `~/.local/share/bambu-studio/bambu-studio`
     - Check `which bambu-studio`

2. **`start_bambu_studio()`**
   - Launch Bambu Studio using subprocess
   - Wait for window to appear
   - Return True/False

3. **`quit_bambu_studio()`**
   - Close Bambu Studio gracefully
   - Use `wmctrl` or `xdotool` to send quit command

4. **`slice_3mf(three_mf_path, output_gcode_3mf=None, slice_delay=15, file_load_delay=8, quit_after=False)`**
   - Open .3mf file in Bambu Studio
   - Send keyboard shortcuts (Ctrl+R to slice, Ctrl+G to export)
   - Type file path into save dialog
   - Handle file dialogs and window focus

---

## Linux Automation Tools

### Option 1: xdotool (Recommended)

**xdotool** is the most common Linux automation tool, similar to AppleScript on Mac.

#### Installation
```bash
sudo apt-get install xdotool
```

#### Key Features
- Window management (find, focus, activate)
- Keyboard input (type, key combinations)
- Mouse control (click, move)
- Window property queries

#### Example Usage
```bash
# Find window by name
xdotool search --name "Bambu Studio"

# Activate window
xdotool windowactivate $(xdotool search --name "Bambu Studio" | head -1)

# Send keyboard shortcut (Ctrl+R)
xdotool key ctrl+r

# Type text
xdotool type "Hello World"

# Wait for window
xdotool search --sync --name "Bambu Studio"
```

### Option 2: pyautogui (Cross-Platform)

**pyautogui** works on Linux but requires additional setup.

#### Installation
```bash
pip3 install pyautogui
```

#### Linux Dependencies
```bash
# For screenshot functionality (optional)
sudo apt-get install python3-tk python3-dev
sudo apt-get install scrot  # or use ImageMagick: sudo apt-get install imagemagick
```

#### Example Usage
```python
import pyautogui
import time

# Activate window (requires window manager support)
pyautogui.hotkey('ctrl', 'r')  # Slice
time.sleep(15)
pyautogui.hotkey('ctrl', 'g')  # Export
time.sleep(4)
pyautogui.write('/path/to/file.gcode.3mf')
pyautogui.press('enter')
```

### Option 3: wmctrl (Window Management)

**wmctrl** is useful for window management but doesn't handle keyboard input.

#### Installation
```bash
sudo apt-get install wmctrl
```

#### Example Usage
```bash
# List windows
wmctrl -l

# Activate window by name
wmctrl -a "Bambu Studio"

# Close window
wmctrl -c "Bambu Studio"
```

---

## Implementation Details

### Finding Bambu Studio Window

```python
import subprocess

def find_bambu_studio_window():
    """Find Bambu Studio window using xdotool."""
    try:
        result = subprocess.run(
            ['xdotool', 'search', '--name', 'Bambu Studio'],
            capture_output=True,
            text=True,
            check=True
        )
        window_ids = result.stdout.strip().split('\n')
        if window_ids and window_ids[0]:
            return int(window_ids[0])
    except:
        pass
    return None
```

### Activating Window

```python
def activate_window(window_id):
    """Activate a window by ID."""
    subprocess.run(['xdotool', 'windowactivate', str(window_id)])
    time.sleep(0.5)  # Wait for focus
```

### Sending Keyboard Shortcuts

```python
def send_key_combination(*keys):
    """Send key combination (e.g., Ctrl+R)."""
    # xdotool format: 'ctrl+r' or 'ctrl+shift+g'
    key_string = '+'.join(keys)
    subprocess.run(['xdotool', 'key', key_string])
    time.sleep(0.5)
```

### Typing File Paths

```python
def type_text(text, delay=0.05):
    """Type text character by character."""
    # Type first character, wait, then type rest
    if len(text) > 0:
        subprocess.run(['xdotool', 'type', text[0]])
        time.sleep(1)  # Wait for dialog to be ready
        if len(text) > 1:
            subprocess.run(['xdotool', 'type', '--delay', str(int(delay * 1000)), text[1:]])
```

### Opening Files

```python
def open_file(file_path):
    """Open file in Bambu Studio."""
    # Method 1: Use xdg-open (Linux equivalent of 'open -a' on Mac)
    subprocess.run(['xdg-open', file_path])
    
    # Method 2: Launch Bambu Studio with file as argument
    subprocess.Popen(['bambu-studio', file_path])
```

---

## Complete `automation_linux.py` Structure

```python
"""
Linux automation module for Bambu Studio control using xdotool.

This module provides Linux-specific automation for the STL to Hull Baseplate Pipeline.
"""

import os
import sys
import time
import subprocess
from pathlib import Path


class BambuStudioAutomation:
    """Linux automation class for Bambu Studio operations."""
    
    def __init__(self, bambu_studio_path=None):
        """Initialize the automation class."""
        self.bambu_studio_path = bambu_studio_path or self._find_bambu_studio()
        
        # Check if xdotool is available
        if not self._check_xdotool():
            raise RuntimeError("xdotool is required. Install with: sudo apt-get install xdotool")
    
    def _find_bambu_studio(self):
        """Find Bambu Studio installation on Linux."""
        # Check common locations
        possible_paths = [
            '/usr/bin/bambu-studio',
            '/usr/local/bin/bambu-studio',
            os.path.expanduser('~/AppImage/bambu-studio.AppImage'),
            os.path.expanduser('~/.local/share/bambu-studio/bambu-studio'),
            os.path.expanduser('~/bambu-studio/bambu-studio'),
        ]
        
        # Check PATH
        import shutil
        bambu_path = shutil.which('bambu-studio')
        if bambu_path:
            return bambu_path
        
        # Check common paths
        for path in possible_paths:
            if os.path.exists(path):
                return path
        
        raise FileNotFoundError("Bambu Studio not found. Please install Bambu Studio for Linux.")
    
    def _check_xdotool(self):
        """Check if xdotool is installed."""
        try:
            subprocess.run(['xdotool', '--version'], 
                         capture_output=True, check=True)
            return True
        except:
            return False
    
    def _find_window(self, window_name="Bambu Studio"):
        """Find window by name."""
        try:
            result = subprocess.run(
                ['xdotool', 'search', '--name', window_name],
                capture_output=True,
                text=True,
                check=True
            )
            window_ids = result.stdout.strip().split('\n')
            if window_ids and window_ids[0]:
                return int(window_ids[0])
        except:
            pass
        return None
    
    def _activate_window(self, window_id=None):
        """Activate Bambu Studio window."""
        if window_id is None:
            window_id = self._find_window()
        if window_id:
            subprocess.run(['xdotool', 'windowactivate', str(window_id)])
            time.sleep(0.5)
            return True
        return False
    
    def start_bambu_studio(self):
        """Start Bambu Studio application."""
        print(f"🚀 Starting Bambu Studio: {self.bambu_studio_path}")
        try:
            subprocess.Popen([self.bambu_studio_path])
            time.sleep(3)  # Wait for application to start
            # Wait for window to appear
            for _ in range(10):
                if self._find_window():
                    return True
                time.sleep(1)
            return False
        except Exception as e:
            print(f"❌ Error starting Bambu Studio: {e}")
            return False
    
    def quit_bambu_studio(self):
        """Quit Bambu Studio application."""
        print("🔒 Closing Bambu Studio...")
        window_id = self._find_window()
        if window_id:
            # Send Ctrl+Q to quit gracefully
            self._activate_window(window_id)
            subprocess.run(['xdotool', 'key', 'ctrl+q'])
            time.sleep(2)
            return True
        return False
    
    def slice_3mf(self, three_mf_path, output_gcode_3mf=None, 
                  slice_delay=15, file_load_delay=8, quit_after=False):
        """
        Open a 3MF project file, slice it, and export as G-code 3MF.
        
        Args:
            three_mf_path (str): Path to the .3mf file
            output_gcode_3mf (str, optional): Path for output .gcode.3mf file
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
            output_gcode_3mf = os.path.join(os.path.dirname(three_mf_path), 
                                          f"{base}.gcode.3mf")
        else:
            output_gcode_3mf = os.path.abspath(output_gcode_3mf)
        
        print(f"🔧 Slicing 3MF file: {three_mf_path}")
        print(f"   Output: {output_gcode_3mf}")
        
        # Check if Bambu Studio is running
        window_id = self._find_window()
        if not window_id:
            print("🚀 Bambu Studio not running, starting it...")
            if not self.start_bambu_studio():
                print("❌ Failed to start Bambu Studio")
                return False
            window_id = self._find_window()
        
        # Open the 3MF file
        try:
            # Use xdg-open or launch with file argument
            subprocess.run(['xdg-open', three_mf_path], check=True)
            time.sleep(file_load_delay)  # Wait for file to load
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to open 3MF in Bambu Studio: {e}")
            return False
        
        # Activate window
        if not self._activate_window(window_id):
            print("❌ Could not activate Bambu Studio window")
            return False
        
        # Slice (Ctrl+R)
        subprocess.run(['xdotool', 'key', 'ctrl+r'])
        time.sleep(slice_delay)
        
        # Export gcode (Ctrl+G)
        subprocess.run(['xdotool', 'key', 'ctrl+g'])
        time.sleep(4)
        
        # Type file path
        # Type first character, wait 1 second, then type rest
        if len(output_gcode_3mf) > 0:
            subprocess.run(['xdotool', 'type', output_gcode_3mf[0]])
            time.sleep(1)  # Wait for dialog to be ready
            if len(output_gcode_3mf) > 1:
                subprocess.run(['xdotool', 'type', '--delay', '50', 
                              output_gcode_3mf[1:]])
        
        time.sleep(1)
        subprocess.run(['xdotool', 'key', 'Return'])
        time.sleep(0.5)
        subprocess.run(['xdotool', 'key', 'Return'])
        time.sleep(5)
        
        # Quit if requested
        if quit_after:
            subprocess.run(['xdotool', 'key', 'ctrl+q'])
            time.sleep(1)
        
        return True
```

---

## Updating `slice_and_fuse_baseplates.py`

### Add Linux Support

Modify the imports and OS detection:

```python
import platform

# Check OS and import appropriate automation
if platform.system() == "Darwin":
    from automation_mac import BambuStudioAutomation
elif platform.system() == "Linux":
    from automation_linux import BambuStudioAutomation
elif platform.system() == "Windows":
    # Windows support not yet implemented
    print("❌ Windows support not yet implemented")
    sys.exit(1)
else:
    print(f"❌ Unsupported OS: {platform.system()}")
    sys.exit(1)
```

### Remove Mac-Only Check

Remove or modify the OS check at the top:

```python
# Check OS - this script supports Mac and Linux
if platform.system() not in ["Darwin", "Linux"]:
    print("="*60)
    print("❌ ERROR: This script requires Mac OS or Linux")
    print("="*60)
    print(f"Detected OS: {platform.system()}")
    print("\nWindows support: Not yet implemented")
    sys.exit(1)
```

---

## Linux-Specific Considerations

### 1. Display Server

The automation requires an X11 display server. For headless servers or remote sessions:

```bash
# Start Xvfb (virtual framebuffer) for headless operation
sudo apt-get install xvfb
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x24 &
```

### 2. Window Manager

Different window managers may require different approaches:

- **GNOME**: Works well with xdotool
- **KDE**: May need `wmctrl` for some operations
- **XFCE**: Generally compatible
- **i3/tiling WMs**: May need special handling

### 3. File Path Handling

Linux uses forward slashes, but dialogs may need special handling:
- Escape special characters in paths
- Handle spaces in file names
- Use absolute paths

### 4. Keyboard Layout

Ensure correct keyboard layout is set:
```bash
# Check current layout
setxkbmap -query

# Set layout if needed
setxkbmap us  # or your preferred layout
```

### 5. Permissions

Some operations may require permissions:
```bash
# Allow X11 access (if needed)
xhost +local:
```

---

## Testing

### Test xdotool Installation
```bash
# Test window search
xdotool search --name "Bambu Studio"

# Test keyboard input
xdotool type "test"
```

### Test Basic Automation
```python
# Test script
from automation_linux import BambuStudioAutomation

automation = BambuStudioAutomation()
automation.start_bambu_studio()
time.sleep(5)
automation.quit_bambu_studio()
```

### Test File Opening
```bash
# Test opening a file
xdg-open test.3mf
```

---

## Troubleshooting

### Issue: "xdotool: command not found"
**Solution**: Install xdotool
```bash
sudo apt-get install xdotool
```

### Issue: "Cannot find Bambu Studio window"
**Solution**: 
- Check window name: `wmctrl -l | grep -i bambu`
- Adjust window name search in `_find_window()`
- Ensure Bambu Studio is actually running

### Issue: "Keyboard input not working"
**Solution**:
- Ensure window is focused: `xdotool windowactivate <window_id>`
- Check keyboard layout: `setxkbmap -query`
- Try increasing delays between keystrokes

### Issue: "File dialog not responding"
**Solution**:
- Increase delay after Ctrl+G (export command)
- Ensure dialog is fully loaded before typing
- Try clicking in the dialog first: `xdotool click 1`

### Issue: "Bambu Studio not found"
**Solution**:
- Install Bambu Studio for Linux
- Add to PATH: `export PATH=$PATH:/path/to/bambu-studio`
- Or specify path: `automation = BambuStudioAutomation(bambu_studio_path="/path/to/bambu-studio")`

---

## Alternative Approaches

### Option 1: Use pyautogui (Simpler, Less Reliable)

```python
import pyautogui
import time

# Activate window (requires window manager support)
pyautogui.hotkey('alt', 'tab')  # Switch to Bambu Studio
time.sleep(1)

# Send shortcuts
pyautogui.hotkey('ctrl', 'r')  # Slice
time.sleep(15)
pyautogui.hotkey('ctrl', 'g')  # Export
time.sleep(4)
pyautogui.write('/path/to/file.gcode.3mf')
pyautogui.press('enter')
```

**Pros**: Simpler, cross-platform  
**Cons**: Less reliable, requires window to be visible

### Option 2: Use DBus (GNOME/KDE)

For GNOME/KDE environments, DBus can be used for some operations:

```python
import dbus

# Get window manager interface
bus = dbus.SessionBus()
wm = bus.get_object('org.gnome.Shell', '/org/gnome/Shell')
```

**Pros**: Native integration  
**Cons**: Desktop environment specific

### Option 3: Use Wayland (Future)

Wayland is replacing X11, but automation tools are still developing:

```bash
# Check if using Wayland
echo $XDG_SESSION_TYPE

# Wayland automation tools (experimental)
# - ydotool (similar to xdotool for Wayland)
# - wtype (keyboard input)
```

---

## Implementation Checklist

- [ ] Install system dependencies (xdotool, wmctrl)
- [ ] Install Python dependencies (numpy, trimesh, pyautogui)
- [ ] Create `automation_linux.py` with all required methods
- [ ] Test window finding and activation
- [ ] Test keyboard shortcuts (Ctrl+R, Ctrl+G)
- [ ] Test file path typing in dialogs
- [ ] Test file opening (xdg-open)
- [ ] Update `slice_and_fuse_baseplates.py` to support Linux
- [ ] Test full pipeline with one file
- [ ] Test cleanup and window closing
- [ ] Document any Linux-specific issues

---

## Example: Complete `automation_linux.py`

See the implementation structure above. The key differences from Mac version:

1. **Window Finding**: Uses `xdotool search` instead of AppleScript
2. **Keyboard Input**: Uses `xdotool key` and `xdotool type` instead of AppleScript keystroke
3. **File Opening**: Uses `xdg-open` instead of `open -a`
4. **Process Check**: Uses `xdotool search` or `pgrep` instead of AppleScript

---

## Next Steps

1. **Create `automation_linux.py`** following the structure above
2. **Test each method individually** before integrating
3. **Update `slice_and_fuse_baseplates.py`** to detect Linux and import Linux module
4. **Test with a single file** before running full pipeline
5. **Handle edge cases** (window not found, dialog timing, etc.)

---

## Resources

- **xdotool documentation**: https://www.semicomplete.com/projects/xdotool/
- **wmctrl documentation**: http://tripie.sweb.cz/utils/wmctrl/
- **pyautogui documentation**: https://pyautogui.readthedocs.io/
- **Bambu Studio Linux**: Check Bambu Lab website for Linux installation

---

**Last Updated**: January 2026  
**Status**: Implementation guide - actual code needs to be written and tested
