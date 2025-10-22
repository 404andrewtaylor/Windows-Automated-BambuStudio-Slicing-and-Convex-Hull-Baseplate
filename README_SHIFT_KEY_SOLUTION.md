# SHIFT Key Solution for Bambu Studio Automation

## Problem
Bambu Studio's SHIFT + arrow key movement (1mm precision) was not working with standard automation libraries. All attempts with `pyautogui`, `keyboard`, and even hardware-level `SendInput` resulted in 10mm movement instead of the expected 1mm.

## Root Cause
Bambu Studio uses Qt's `QGuiApplication::keyboardModifiers()` which reads **physical keyboard state** at the hardware level. This function ignores simulated input from any standard automation library, including:
- `pyautogui.keyDown('shift')` + `pyautogui.press('arrow')`
- `keyboard.send('shift+arrow')`
- Hardware-level `SendInput` with scan codes
- `pyautogui.hotkey('shift', 'arrow')`

## Solution: pydirectinput
The solution is to use `pydirectinput` specifically for SHIFT + arrow key combinations while keeping `pyautogui` for all other operations.

### Installation
```bash
pip install pydirectinput
```

### Implementation
```python
import pydirectinput
import pyautogui

# Use pyautogui for normal operations
pyautogui.hotkey('ctrl', 'n')  # New project
pyautogui.hotkey('ctrl', 'i')  # Import
pyautogui.write(file_path)     # Type file path
pyautogui.press('enter')       # Confirm

# Use pydirectinput ONLY for SHIFT + arrow keys
pydirectinput.keyDown('shift')
pydirectinput.press('right')   # or 'left', 'up', 'down'
pydirectinput.keyUp('shift')
```

### Why This Works
`pydirectinput` uses DirectInput API which bypasses the standard Windows input system that Qt's modifier detection relies on. This allows the SHIFT modifier to be properly recognized by Bambu Studio.

## Updated Automation Code
The `_press_arrow_key` function in `automation_windows.py` should be updated to:

```python
def _press_arrow_key(self, direction, count=1, with_shift=False):
    """Press arrow keys with optional shift modifier."""
    try:
        if with_shift:
            # Use pydirectinput for SHIFT + arrow combinations
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
```

## Testing
The solution was tested with `test_pydirectinput.py` which:
1. Opens Bambu Studio
2. Creates new project
3. Imports hull STL
4. Tests SHIFT + arrow movement in all 4 directions
5. Confirms 1mm movement per press (not 10mm)

## Key Points
- **Only use `pydirectinput` for SHIFT + arrow combinations**
- **Keep `pyautogui` for all other operations** (hotkeys, typing, etc.)
- **No need to run as Administrator** - works with normal privileges
- **No hardware or driver installation required**
- **Reliable and deterministic** - works consistently

## Files Modified
- `automation_windows.py` - Updated `_press_arrow_key` function
- `test_pydirectinput.py` - Test script demonstrating the solution

## Future Reference
If similar issues arise with other applications that filter synthetic input, `pydirectinput` should be considered as the first solution for modifier key combinations.

---
*Solution discovered and documented on [Date] - Successfully resolves Bambu Studio SHIFT + arrow key automation issues.*
