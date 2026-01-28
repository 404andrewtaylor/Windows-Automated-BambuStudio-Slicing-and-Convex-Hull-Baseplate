# Linux Automated Baseplate Pipeline

**Status:** ✅ Fully functional on Ubuntu 24.04 ARM64 (and compatible with x86_64 Linux)

This Linux-specific pipeline automatically processes `.3mf` project files by slicing them, creating convex hull baseplates, and fusing the baseplates onto the original models. It's inspired by williamsikkema's Mac pipeline but uses Linux-specific automation.

---

## Overview

The pipeline automatically finds and processes the **4 most recent `.3mf` files** in your `~/Downloads` folder:

1. **Slices** each `.3mf` file to create `.gcode.3mf` files
2. **Extracts** bottom 10 layers from the G-code
3. **Creates** convex hull baseplates from those layers (with 4mm buffer)
4. **Slices** the baseplates
5. **Fuses** the baseplates onto the original sliced models

**Final Output:** `{filename}_with_baseplate.gcode.3mf` files ready for 3D printing

---

## Prerequisites

### Operating System
- **Ubuntu 24.04** (tested on ARM64, compatible with x86_64)
- Other modern Linux distributions should work (may need minor adjustments)

### Required Software

#### 1. Bambu Studio (Flatpak)
Install Bambu Studio via Flatpak:

```bash
# Install Flatpak if not already installed
sudo apt update
sudo apt install -y flatpak

# Add Flathub repository
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Bambu Studio
sudo flatpak install -y flathub com.bambulab.BambuStudio
```

**Verify installation:**
```bash
flatpak list | grep com.bambulab.BambuStudio
```

#### 2. Python 3.6+
Check if Python 3 is installed:
```bash
python3 --version
```

If not installed:
```bash
sudo apt install -y python3 python3-pip python3-venv
```

#### 3. System Dependencies (for pyautogui)
```bash
sudo apt install -y scrot python3-tk python3-dev
```

---

## Installation

### Step 1: Clone or Download the Repository
```bash
cd ~/Andrew/BambuSlicer
```

### Step 2: Create Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate
```

### Step 3: Install Python Dependencies
```bash
# Install core scientific libraries
pip install numpy scipy matplotlib

# Install automation library
pip install pyautogui

# Install 3D mesh processing library
pip install trimesh
```

**Or install all at once:**
```bash
pip install numpy scipy matplotlib pyautogui trimesh
```

### Step 4: Verify Installation
```bash
python -c "import numpy, scipy, matplotlib, pyautogui, trimesh; print('✅ All dependencies installed')"
```

---

## Usage

### Basic Usage

1. **Place `.3mf` files in `~/Downloads`**
   - The script will automatically find the 4 most recent `.3mf` files
   - Files ending in `.gcode.3mf` or containing `_baseplate` are excluded

2. **Run the pipeline:**
```bash
cd ~/Andrew/BambuSlicer
source venv/bin/activate
python slice_and_fuse_baseplates_linux.py
```

### Cleanup Mode (Recommended)

To delete intermediate files and keep only the original `.3mf` and final `_with_baseplate.gcode.3mf` files:

```bash
python slice_and_fuse_baseplates_linux.py --cleanup
```

**What gets deleted:**
- `{name}.gcode.3mf` (sliced original)
- `{name}_baseplate.3mf` (baseplate project)
- `{name}_baseplate.gcode.3mf` (sliced baseplate)

**What stays:**
- `{name}.3mf` (original input)
- `{name}_with_baseplate.gcode.3mf` (final output ready to print)

---

## How It Works

### Pipeline Steps

For each of the 4 most recent `.3mf` files:

#### Step 1: Slice Original Model
- Opens Bambu Studio via Flatpak
- Imports the `.3mf` file (Ctrl+I → Ctrl+L → type path)
- Slices it (Ctrl+R)
- Exports as `.gcode.3mf` (Ctrl+G)
- **Output:** `{name}.gcode.3mf`

#### Step 2: Create Convex Hull Baseplate
- Extracts G-code from `.gcode.3mf`
- Parses bottom 10 layers
- Computes convex hull from XY coordinates
- Applies 4mm buffer
- Clips to 180mm build plate boundaries
- Creates 1mm tall STL mesh
- Converts to `.3mf` project file
- **Output:** `{name}_baseplate.3mf`

#### Step 3: Slice Baseplate
- Opens Bambu Studio
- Imports and slices the baseplate `.3mf`
- Exports as `.gcode.3mf`
- **Output:** `{name}_baseplate.gcode.3mf`

#### Step 4: Fuse Baseplate onto Model
- Counts actual layers in baseplate (typically 6 layers for 1mm height)
- Uses minimum of baseplate layers and requested layers (10)
- Replaces bottom layers of original model with baseplate layers
- **Output:** `{name}_with_baseplate.gcode.3mf` ⭐ **READY TO PRINT**

---

## Files Created

### Input Location
`~/Downloads/`

### Generated Files (per input file)

1. **`{filename}.gcode.3mf`**
   - Sliced version of the original `.3mf` file
   - Contains G-code for the model

2. **`{filename}_baseplate.3mf`**
   - Convex hull baseplate as a `.3mf` project file
   - Created from bottom 10 layers of the sliced model
   - Has 4mm buffer around the convex hull

3. **`{filename}_baseplate.gcode.3mf`**
   - Sliced version of the baseplate
   - Contains G-code for just the baseplate

4. **`{filename}_with_baseplate.gcode.3mf`** ⭐ **FINAL OUTPUT**
   - Fused model with baseplate
   - Bottom layers replaced with baseplate layers
   - **This is the file you send to the printer**

---

## Technical Details

### Automation Method

The Linux automation (`automation_linux.py`) uses:
- **Flatpak** to launch Bambu Studio: `flatpak run com.bambulab.BambuStudio`
- **pyautogui** for keyboard/mouse automation
- **Timing-based approach** (similar to Windows automation)
- **Screen center click** to ensure Bambu Studio window has focus before sending shortcuts

### Keyboard Sequence

1. Start Bambu Studio (via Flatpak)
2. **Ctrl+I** → Open import dialog
3. **Ctrl+L** → Focus path entry field
4. Type full path to `.3mf` file, press **Enter**
5. Wait for file to load
6. Click screen center to ensure focus
7. **Ctrl+R** → Slice
8. Wait for slicing to complete
9. **Ctrl+G** → Export gcode
10. **Ctrl+A** → Select path field
11. Type output path, press **Enter** twice
12. Optionally **Alt+F4** to close Bambu Studio

### Layer Replacement Logic

The pipeline automatically detects how many layers the baseplate actually has and uses the minimum:
- If baseplate has 6 layers and you request 10 → uses 6
- If baseplate has 10+ layers and you request 10 → uses 10

This prevents errors when the baseplate height doesn't produce enough layers.

---

## Troubleshooting

### Issue: "ModuleNotFoundError: No module named 'pyautogui'"
**Solution:** Install dependencies:
```bash
source venv/bin/activate
pip install pyautogui
sudo apt install -y scrot python3-tk python3-dev
```

### Issue: "trimesh is required"
**Solution:** Install trimesh:
```bash
source venv/bin/activate
pip install trimesh
```

### Issue: "Bambu Studio not found"
**Solution:** Install Bambu Studio via Flatpak (see Prerequisites section)

### Issue: Keyboard shortcuts not working
**Solution:** 
- Ensure Bambu Studio window has focus (the script clicks screen center automatically)
- Don't interact with keyboard/mouse while automation is running
- Check that you're running under X11 (not Wayland) - pyautogui works best with X11

### Issue: "Baseplate only has 6 layers, but trying to replace 10"
**Solution:** This is now handled automatically! The script detects the actual layer count and uses the minimum. If you still see this error, it means the layer counting failed - check that the baseplate `.gcode.3mf` file was created successfully.

### Issue: Files not found in Downloads
**Solution:** 
- Ensure `.3mf` files are in `~/Downloads` (not subdirectories)
- Files must NOT end with `.gcode.3mf`
- Files must NOT contain `_baseplate` in the filename

### Issue: Automation timing issues
**Solution:** The script uses conservative delays. If Bambu Studio is slow to respond, you may need to increase delays in `automation_linux.py`:
- `file_load_delay` (default: 8 seconds)
- `slice_delay` (default: 15 seconds for original, 5 seconds for baseplate)

---

## Architecture

### Key Files

- **`slice_and_fuse_baseplates_linux.py`** - Main pipeline script (Linux-specific)
- **`automation_linux.py`** - Linux automation module for Bambu Studio control
- **`gcode_to_convex_hull_3mf.py`** - Baseplate generation (OS-agnostic)
- **`ReplaceBaseplate/replace_baseplate_layers.py`** - Layer fusion tool (OS-agnostic)

### Platform Support

- ✅ **Linux** (Ubuntu 24.04 ARM64/x86_64) - This script
- ✅ **macOS** - See `slice_and_fuse_baseplates.py` (original Mac script)
- ❌ **Windows** - Not yet implemented for this pipeline

---

## Example Output

```
============================================================
AUTOMATED BASEPLATE PIPELINE (Linux)
============================================================
Started at: 2026-01-28 13:01:59
🧹 Cleanup mode: Will delete intermediate files after successful fusion

============================================================
STEP 1: Finding 4 most recent .3mf files in Downloads
============================================================
Found 4 .3mf file(s):
  1. Cube4.3mf (modified: 2026-01-28 12:17:17)
  2. Cube3.3mf (modified: 2026-01-27 13:30:23)
  3. Cube2.3mf (modified: 2026-01-27 13:30:19)
  4. Cube1.3mf (modified: 2026-01-27 13:30:13)

############################################################
PROCESSING FILE 1/4: Cube4.3mf
############################################################

[STEP 1/4] Slicing original .3mf file...
✅ Successfully sliced: Cube4.gcode.3mf

[STEP 2/4] Creating convex hull baseplate...
✅ Successfully created baseplate: Cube4_baseplate.3mf

[STEP 3/4] Slicing baseplate...
✅ Successfully sliced baseplate: Cube4_baseplate.gcode.3mf

[STEP 4/4] Fusing baseplate onto model...
   Baseplate has 6 layers, using 6 for fusion
✅ Successfully fused: Cube4_with_baseplate.gcode.3mf

🧹 Cleaning up intermediate files...
   ✅ Deleted sliced original: Cube4.gcode.3mf
   ✅ Deleted baseplate project: Cube4_baseplate.3mf
   ✅ Deleted sliced baseplate: Cube4_baseplate.gcode.3mf
   📁 Kept original: Cube4.3mf
   📁 Kept final output: Cube4_with_baseplate.gcode.3mf

============================================================
PIPELINE SUMMARY (Linux)
============================================================
Successfully processed: 4/4 files
```

---

## Notes

- The pipeline processes files **sequentially** (one at a time)
- There's a **5-second delay** between files to avoid overwhelming Bambu Studio
- The script **skips files** if output already exists (idempotent)
- All files are saved in the **Downloads folder** (same as input)
- Coordinate system is **preserved** from G-code (no transformations applied)
- The baseplate is created from the **bottom 10 layers** of the original model
- Baseplate has a **4mm buffer** around the convex hull for better adhesion

---

## Related Documentation

- **`README.md`** - Main project documentation
- **`README_WILLIAM_PIPELINE.md`** - Original Mac pipeline documentation
- **`ReplaceBaseplate/README.md`** - Baseplate replacement tool documentation

---

**Last Updated:** January 2026  
**Maintainer:** Linux automation implementation  
**Status:** ✅ Fully functional on Ubuntu 24.04 ARM64 and x86_64
