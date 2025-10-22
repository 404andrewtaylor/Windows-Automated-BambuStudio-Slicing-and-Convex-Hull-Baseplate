# STL to Hull Baseplate Pipeline - Current Status

## Overview
This pipeline automates the process of creating a convex hull baseplate for 3D printing using Bambu Studio. It takes an STL file, slices it, extracts the convex hull from the first layer, creates a hull STL, aligns it with the original model, and combines them for printing.

## How to Run the Pipeline

### Prerequisites
1. **Bambu Studio installed** at: `C:\Program Files\Bambu Studio\bambu-studio.exe`
2. **Python virtual environment** set up in the project directory
3. **All dependencies installed** (see requirements.txt)

### Running the Pipeline
```bash
# Navigate to project directory
cd "C:\path\to\Windows-Automated-BambuStudio-Slicing-and-Convex-Hull-Baseplate-master"

# Activate virtual environment
.\venv\Scripts\Activate.ps1

# Run the pipeline
python full_pipeline.py "C:\path\to\your\model.stl"
```

### Pipeline Steps
1. **Step 1**: Slice original STL in Bambu Studio
2. **Step 2**: Locate and copy generated files
3. **Step 3**: Extract convex hull and create hull STL
4. **Step 4**: Calculate offset and move/slice hull
5. **Step 5**: Run ReplaceBaseplate to combine files
6. **Step 6**: Organize output files
7. **Step 7**: Create analysis files

## Current Status: ✅ MOSTLY WORKING

### What's Working
- ✅ **STL slicing**: Original STL slices successfully
- ✅ **Hull creation**: Convex hull STL is created correctly
- ✅ **Offset calculation**: Correctly calculates alignment offset
  - Original model center: (101.03, 88.13)
  - Default hull center: (90.00, 90.00) for A1 mini
  - Calculated offset: X=11.03mm, Y=-1.87mm
- ✅ **Hull import and slicing**: Hull imports and slices successfully
- ✅ **ReplaceBaseplate**: Windows compatibility fixed (no more Unix command errors)

### Current Issue: SHIFT Key Not Being Held Properly

**Problem**: The hull movement is still moving too far (110mm instead of 11mm), indicating that SHIFT is not being held down properly during arrow key presses.

**Expected Behavior**: 
- SHIFT + Right Arrow = 1mm movement per press
- 11 presses should = 11mm total movement

**Actual Behavior**:
- 11 presses = 110mm movement (10x too much)
- This suggests SHIFT is not being held, so it's using regular arrow keys (10mm per press)

**Code Location**: `automation_windows.py` lines 139-156
```python
def _press_arrow_key(self, direction, count=1, with_shift=False):
    if with_shift:
        # Hold shift down for the entire sequence
        pyautogui.keyDown('shift')
        for _ in range(count):
            pyautogui.press(direction)
            time.sleep(0.1)
        pyautogui.keyUp('shift')
```

**Debugging Steps Needed**:
1. Test if `pyautogui.keyDown('shift')` and `pyautogui.keyUp('shift')` are working correctly
2. Add debug output to verify SHIFT is being held
3. Consider alternative methods for holding SHIFT (e.g., using `pyautogui.hotkey()` differently)
4. Test with a simple movement script to isolate the issue

## Files Created
The pipeline creates these files in the output directory:
- `ultra_simplified_m1.gcode.3mf` (original sliced)
- `ultra_simplified_m1_hull.stl` (convex hull STL)
- `ultra_simplified_m1_hull.gcode.3mf` (hull sliced)
- `ultra_simplified_m1_hull.3mf` (hull project)
- `ultra_simplified_m1_with_hull_baseplate.gcode.3mf` (final combined - when working)

## Configuration
- **Printer**: Bambu A1 mini
- **Default hull position**: (90.0, 90.0) - center of A1 mini build plate
- **Movement increment**: 1mm per SHIFT+Arrow press (when working correctly)
- **Hull height**: 1.0mm extrusion

## Next Steps
1. Fix the SHIFT key holding issue in `_press_arrow_key()`
2. Test with simple movement script
3. Verify hull positioning is correct
4. Complete the full pipeline end-to-end

## Test Scripts
- `test_movement.py`: Simple script to test hull movement in Bambu Studio
- Use this to verify SHIFT+Arrow behavior independently

## Notes
- The pipeline uses absolute paths throughout
- No window detection (removed to prevent Chrome autofocus issues)
- Hull positioning calculation is correct, just the movement execution needs fixing
