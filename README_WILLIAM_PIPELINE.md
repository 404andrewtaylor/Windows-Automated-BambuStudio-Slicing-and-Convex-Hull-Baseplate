# Automated Baseplate Pipeline - Documentation

**Author:** williamsikkema  
**Version:** 1.2.0  
**Date:** January 2026  
**Status:** ✅ Tested on Mac OS only (Windows support not yet implemented)

---

## Overview

This automated pipeline processes `.3mf` project files by:
1. Slicing them to create `.gcode.3mf` files
2. Extracting bottom layers from the G-code
3. Creating convex hull baseplates from those layers
4. Slicing the baseplates
5. Fusing the baseplates onto the original sliced models

The pipeline automatically finds and processes the 4 most recent `.3mf` files in your Downloads folder.

---

## Quick Start

### Prerequisites
- **Mac OS** (currently only tested on Mac)
- **Bambu Studio** installed
- **Python 3.6+** with required dependencies

### Installation
```bash
pip install numpy trimesh pathlib
```

### Run the Pipeline
```bash
python slice_and_fuse_baseplates.py
```

The script will:
- Find the 4 most recent `.3mf` files in `~/Downloads`
- Process each one through the full pipeline
- Save all outputs in the Downloads folder

---

## Inputs and Outputs

### Inputs

**Location:** `~/Downloads/` (user's Downloads directory)

**File Types:**
- `.3mf` files (Bambu Studio project files)
  - Must NOT end with `.gcode.3mf`
  - Must NOT contain `_baseplate` in filename
  - Example: `my_model.3mf`

**Selection:**
- Automatically selects the 4 most recent `.3mf` files (by modification time)
- Skips files that are already processed (if output files exist)

### Outputs

**Location:** Same directory as input files (`~/Downloads/`)

**Generated Files (per input file):**

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
   - First 10 layers replaced with baseplate layers
   - This is the file you send to the printer

**Example:**
- Input: `testSphere.3mf`
- Outputs:
  - `testSphere.gcode.3mf`
  - `testSphere_baseplate.3mf`
  - `testSphere_baseplate.gcode.3mf`
  - `testSphere_with_baseplate.gcode.3mf` ← **Use this one**

---

## Pipeline Workflow

### Step-by-Step Process

For each of the 4 most recent `.3mf` files:

#### Step 1: Slice Original Model
- **Function:** `slice_3mf_file()`
- **Input:** `model.3mf`
- **Output:** `model.gcode.3mf`
- **Method:** Uses Bambu Studio automation (AppleScript on Mac)
- **Retry Logic:** Up to 3 retries with increasing delays (8s → 12s → 18s for file load, 15s → 22.5s → 33.75s for slice)

#### Step 2: Create Convex Hull Baseplate
- **Function:** `create_baseplate()`
- **Input:** `model.gcode.3mf`
- **Output:** `model_baseplate.3mf`
- **Process:**
  1. Extracts G-code from `.gcode.3mf` file
  2. Parses bottom 10 layers
  3. Extracts XY coordinates from extrusion moves
  4. Computes convex hull
  5. Applies 4mm buffer
  6. Clips to 180mm build plate boundaries
  7. Extrudes to 1mm height
  8. Converts to `.3mf` using blank template

#### Step 3: Slice Baseplate
- **Function:** `slice_baseplate()`
- **Input:** `model_baseplate.3mf`
- **Output:** `model_baseplate.gcode.3mf`
- **Method:** Same as Step 1, but with shorter delays (5s slice delay)

#### Step 4: Fuse Baseplate onto Model
- **Function:** `fuse_baseplate()`
- **Inputs:**
  - `model_baseplate.gcode.3mf` (baseplate)
  - `model.gcode.3mf` (original model)
- **Output:** `model_with_baseplate.gcode.3mf`
- **Process:** Replaces first 10 layers of model with baseplate layers
- **Tool Used:** `ReplaceBaseplate/replace_baseplate_layers.py`

---

## Files and Functions

### Main Entry Point

**File:** `slice_and_fuse_baseplates.py`

**Main Function:** `main()`
- Orchestrates the entire pipeline
- Finds files, processes each one, prints summary

**Key Functions:**

1. **`find_recent_3mf_files(downloads_dir, count=4)`**
   - Finds N most recent `.3mf` files
   - Excludes `.gcode.3mf` and `_baseplate` files
   - Returns: List of Path objects

2. **`slice_3mf_file(automation, three_mf_path, output_gcode_3mf=None, max_retries=3)`**
   - Slices a `.3mf` file using Bambu Studio
   - Retries with increasing delays if file not created
   - Returns: Path to `.gcode.3mf` file or None

3. **`create_baseplate(gcode_3mf_path, output_baseplate_3mf=None, n_layers=10, buffer_mm=4.0)`**
   - Creates convex hull baseplate from `.gcode.3mf`
   - Calls `gcode_to_convex_hull_3mf()` function
   - Returns: Path to baseplate `.3mf` file or None

4. **`slice_baseplate(automation, baseplate_3mf_path, output_baseplate_gcode_3mf=None, max_retries=3)`**
   - Slices the baseplate `.3mf` file
   - Similar to `slice_3mf_file()` but with shorter delays
   - Returns: Path to baseplate `.gcode.3mf` file or None

5. **`count_layers_in_gcode_3mf(gcode_3mf_path)`**
   - Counts layers in a `.gcode.3mf` file
   - Parses G-code and counts layer markers
   - Returns: Number of layers or None

6. **`fuse_baseplate(baseplate_gcode_3mf, model_gcode_3mf, output_fused_3mf, layers=10)`**
   - Fuses baseplate onto model
   - Calls `ReplaceBaseplate/replace_baseplate_layers.py` as subprocess
   - Returns: Path to fused `.gcode.3mf` file or None

---

### Core Baseplate Generation

**File:** `gcode_to_convex_hull_3mf.py`

**Main Function:** `gcode_to_convex_hull_3mf()`

**Parameters:**
- `input_gcode_3mf` (str): Path to input `.gcode.3mf` file
- `output_3mf` (str): Path to output `.3mf` file
- `n_layers` (int, default=10): Number of bottom layers to analyze
- `buffer_mm` (float, default=4.0): Buffer distance in mm
- `plate_size` (float, default=180.0): Build plate size in mm
- `hull_height` (float, default=1.0): Height of extruded hull in mm
- `blank_template_path` (str, optional): Path to `blank_template.3mf`

**Key Functions:**

1. **`extract_gcode_from_3mf(input_3mf, output_gcode)`**
   - Extracts G-code from `.gcode.3mf` ZIP file
   - Reads `Metadata/plate_1.gcode`

2. **`parse_gcode_bottom_layers(gcode_content, n_layers=10)`**
   - Parses G-code and extracts XY coordinates from bottom N layers
   - Looks for layer markers: `; layer num/total_layer_count:`
   - Collects extrusion points (moves with E increments)
   - Returns: numpy array of (x, y) points

3. **`compute_convex_hull(points)`**
   - Computes convex hull using Graham scan algorithm
   - Returns: numpy array of hull vertices

4. **`offset_hull(hull_points, buffer_mm=2.0)`**
   - Applies buffer by scaling hull outward from center
   - Ensures edge is at least `buffer_mm` away from original

5. **`clip_to_build_plate(hull_points, plate_size=180.0, gcode_bounds=None)`**
   - Clips hull to build plate boundaries
   - Safe zone: [0.5, 179.5] mm for both X and Y
   - Recomputes convex hull after clipping

6. **`create_stl_from_hull(hull_points, height=1.0)`**
   - Creates STL mesh by extruding hull vertically
   - Uses trimesh library
   - Returns: trimesh.Trimesh object

7. **`stl_to_3mf(mesh_obj, output_path, blank_template_path=None)`**
   - Converts trimesh object to `.3mf` file
   - Uses `blank_template.3mf` as base
   - Replaces mesh geometry in template
   - Sets transform to identity (preserves G-code coordinates)
   - Returns: Path to created `.3mf` file

---

### Automation Module

**File:** `automation_mac.py`

**Class:** `BambuStudioAutomation`

**Key Method:** `slice_3mf(three_mf_path, output_gcode_3mf=None, slice_delay=15, file_load_delay=8)`
- Opens `.3mf` file in Bambu Studio
- Slices it (Cmd+R)
- Exports as `.gcode.3mf` (Cmd+G)
- Uses AppleScript for automation
- Returns: bool (success/failure)

**Note:** Windows version (`automation_windows.py`) does NOT have `slice_3mf()` method yet.

---

### Baseplate Fusion Tool

**File:** `ReplaceBaseplate/replace_baseplate_layers.py`

**Usage:** Called as subprocess from `fuse_baseplate()`

**Command:**
```bash
python replace_baseplate_layers.py \
    baseplate.gcode.3mf \
    model.gcode.3mf \
    output_with_baseplate.gcode.3mf \
    --layers 10
```

**Function:** Replaces first N layers of model with baseplate layers

---

## Configuration

### Default Parameters (in `main()`)

```python
downloads_dir = Path.home() / "Downloads"  # Input location
n_layers = 10                                # Bottom layers to analyze
buffer_mm = 4.0                              # Buffer around convex hull
layers_to_replace = 10                       # Layers to replace in fusion
```

### Retry Logic

**Slicing Operations:**
- Initial delays: 8s (file load), 15s (slice)
- Retry 1: 12s, 22.5s (50% increase)
- Retry 2: 18s, 33.75s (50% increase)
- Max retries: 3 attempts

**Baseplate Slicing:**
- Initial delays: 8s (file load), 5s (slice)
- Same retry logic applies

---

## Missing Files

### ⚠️ Critical Missing File

**`blank_template.3mf`**

**Location Expected:** Root directory of the project (same folder as `slice_and_fuse_baseplates.py`)

**Purpose:** Template `.3mf` file used to create new baseplate `.3mf` files. The script extracts this template, replaces the mesh geometry with the convex hull, and saves it as a new `.3mf` file.

**What It Should Contain:**
- Valid `.3mf` file structure (ZIP archive)
- Empty or minimal mesh geometry
- Proper XML structure with namespaces
- Build plate settings for 180mm x 180mm
- Metadata files (model_settings.config, etc.)

**How to Create:**
1. Open Bambu Studio
2. Create a new project
3. Don't add any models (or add a tiny cube and delete it)
4. Save as `blank_template.3mf`
5. Place in project root directory

**Error Message if Missing:**
```
FileNotFoundError: blank_template.3mf not found at: /path/to/blank_template.3mf
```

---

## Dependencies

### Python Packages

**Required:**
- `numpy` - Numerical computing for point arrays
- `trimesh` - 3D mesh creation and manipulation
- `pathlib` - Path handling (usually included in Python 3.6+)

**Standard Library:**
- `os`, `sys`, `subprocess`, `time`
- `zipfile` - Extract G-code from `.gcode.3mf` files
- `xml.etree.ElementTree` - Parse and modify `.3mf` XML
- `tempfile` - Temporary file handling
- `datetime` - Timestamp generation

**Install:**
```bash
pip install numpy trimesh
```

---

## Platform Support

### ✅ Mac OS (Tested)
- Uses `automation_mac.py`
- AppleScript for Bambu Studio control
- Fully functional

### ❌ Windows (Not Implemented)
- `automation_windows.py` exists but lacks `slice_3mf()` method
- Would need to implement Windows version of `slice_3mf()`
- Would need to update `slice_and_fuse_baseplates.py` to detect platform

### 🔧 To Add Windows Support:

1. **Add `slice_3mf()` to `automation_windows.py`:**
   ```python
   def slice_3mf(self, three_mf_path, output_gcode_3mf=None, 
                 slice_delay=15, file_load_delay=8):
       # Open .3mf file
       # Slice (Ctrl+R or equivalent)
       # Export (Ctrl+G or equivalent)
       # Type file path
       # Save
   ```

2. **Update `slice_and_fuse_baseplates.py`:**
   ```python
   import platform
   if platform.system() == "Windows":
       from automation_windows import BambuStudioAutomation
   elif platform.system() == "Darwin":
       from automation_mac import BambuStudioAutomation
   ```

---

## File Structure

```
project_root/
├── slice_and_fuse_baseplates.py      # Main pipeline script
├── gcode_to_convex_hull_3mf.py       # Baseplate generation
├── automation_mac.py                 # Mac automation (has slice_3mf)
├── automation_windows.py             # Windows automation (missing slice_3mf)
├── blank_template.3mf                 # ⚠️ MISSING - needs to be created
├── ReplaceBaseplate/
│   └── replace_baseplate_layers.py  # Baseplate fusion tool
└── 3MF_COORDINATE_SYSTEM.md          # Coordinate system documentation
```

---

## Error Handling

### File Not Found Errors
- **Missing `.3mf` files:** Script exits with error message
- **Missing `blank_template.3mf`:** Raises `FileNotFoundError` during baseplate creation
- **Missing `replace_baseplate_layers.py`:** Prints error, skips fusion step

### Slicing Failures
- Retries up to 3 times with increasing delays
- If all retries fail, skips that file and continues with next
- Prints warning message for each failed file

### Partial Processing
- If a step fails, the pipeline continues to next file
- Summary at end shows which files succeeded/failed
- Already-processed files are skipped (if output exists)

---

## Example Output

```
============================================================
AUTOMATED BASEPLATE PIPELINE
============================================================
Started at: 2026-01-25 16:23:51

============================================================
STEP 1: Finding 4 most recent .3mf files in Downloads
============================================================
Found 4 .3mf file(s):
  1. model1.3mf (modified: 2026-01-25 15:30:00)
  2. model2.3mf (modified: 2026-01-25 14:20:00)
  3. model3.3mf (modified: 2026-01-25 13:10:00)
  4. model4.3mf (modified: 2026-01-25 12:00:00)

############################################################
PROCESSING FILE 1/4: model1.3mf
############################################################

[STEP 1/1] Slicing original .3mf file...
============================================================
SLICING: model1.3mf
============================================================
✅ Successfully sliced: model1.gcode.3mf

[STEP 2/1] Creating convex hull baseplate...
============================================================
CREATING BASEPLATE: model1.gcode.3mf
============================================================
✅ Successfully created baseplate: model1_baseplate.3mf

[STEP 3/1] Slicing baseplate...
============================================================
SLICING BASEPLATE: model1_baseplate.3mf
============================================================
✅ Successfully sliced baseplate: model1_baseplate.gcode.3mf

[STEP 4/1] Fusing baseplate onto model...
============================================================
FUSING BASEPLATE: model1_baseplate.gcode.3mf + model1.gcode.3mf
============================================================
✅ Successfully fused: model1_with_baseplate.gcode.3mf

...

============================================================
PIPELINE SUMMARY
============================================================
Successfully processed: 4/4 files

File 1: model1.3mf
  ✅ Sliced: model1.gcode.3mf
  ✅ Baseplate: model1_baseplate.3mf
  ✅ Baseplate sliced: model1_baseplate.gcode.3mf
  ✅ Fused: model1_with_baseplate.gcode.3mf

...

============================================================
Completed at: 2026-01-25 16:45:30
============================================================
```

---

## Troubleshooting

### Issue: "blank_template.3mf not found"
**Solution:** Create a blank `.3mf` file in Bambu Studio and save it as `blank_template.3mf` in the project root.

### Issue: Slicing fails repeatedly
**Solution:** 
- Increase delays in `slice_3mf_file()` function
- Check that Bambu Studio is responding to keyboard shortcuts
- Ensure no dialogs are blocking automation

### Issue: Baseplate creation fails
**Solution:**
- Check that input `.gcode.3mf` file is valid
- Verify G-code contains layer markers
- Ensure at least 10 layers exist in the file

### Issue: Fusion fails
**Solution:**
- Verify `ReplaceBaseplate/replace_baseplate_layers.py` exists
- Check that both input files have valid G-code
- Ensure baseplate has enough layers (at least 10)

---

## Related Documentation

- **`3MF_COORDINATE_SYSTEM.md`** - Detailed explanation of `.3mf` coordinate system and printable zones
- **`README.md`** - Main project documentation
- **`ReplaceBaseplate/README.md`** - Baseplate replacement tool documentation

---

## Version History

- **v1.2.0** (Jan 2026) - Initial automated pipeline by williamsikkema
  - Automated processing of 4 most recent `.3mf` files
  - Retry logic with increasing delays
  - Comprehensive error handling
  - Mac OS support only

---

## Notes

- The pipeline processes files sequentially (one at a time)
- 5-second delay between files to avoid overwhelming Bambu Studio
- All files are saved in the Downloads folder (same as input)
- The script skips files if output already exists (idempotent)
- Coordinate system is preserved from G-code (no transformations applied)

---

**Last Updated:** January 2026  
**Maintainer:** williamsikkema  
**Status:** ✅ Functional on Mac OS, ⚠️ Windows support pending
