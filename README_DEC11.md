# STL to Hull Baseplate Pipeline - User Guide
**Date:** December 11, 2025  
**Version:** 1.1.17

---

## 🚀 Quick Start (It's Really This Easy!)

### ⭐ IMPORTANT: Create Desktop Shortcut First!

**Before you start, create a desktop shortcut for easy access:**

1. **Right-click** on `launch_gui_nov10_2025.bat`
2. **Select "Create shortcut"**
3. **Drag the shortcut to your Desktop**
4. **Rename it** to something like "STL Pipeline" (optional)

**Now you can double-click the desktop shortcut anytime to run the pipeline!**

---

### Using the Pipeline

1. **Double-click** your desktop shortcut (or `launch_gui_nov10_2025.bat`)
2. **Click "Browse Folder"** and select the folder containing your STL files
3. **Click "Run Pipeline"**
4. **Done!** Your processed files are in `{your_folder}\slicer_output`

That's it! The pipeline automatically:
- Processes all STL files in your folder
- Creates baseplates for better bed adhesion
- Saves final output files ready for printing
- Cleans up intermediate files automatically

---

## 📋 Table of Contents
1. [Quick Start](#-quick-start-its-really-this-easy) ⭐ **START HERE**
2. [What It Does](#what-it-does)
3. [Installation & Setup](#installation--setup)
4. [Usage Guide](#usage-guide)
5. [Output Files](#output-files)
6. [Essential Files](#essential-files-for-reference)
7. [Configuration Options](#configuration-options-advanced)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 What This Does

The **STL to Hull Baseplate Pipeline** automatically processes your STL files and adds custom baseplates for better 3D printing bed adhesion.

**Simple workflow:**
1. Put your STL files in a folder
2. Open the GUI and select that folder
3. Click Run
4. Get printable files with baseplates attached

**What you get:**
- Each STL file becomes a printable `.gcode.3mf` file
- Each file has a 175mm × 175mm baseplate attached (1mm thick)
- Baseplate provides excellent bed adhesion
- Ready to load into Bambu Studio and print immediately

---

## ⚙️ How It Works

**Current Configuration:**
- Baseplate type: **175mm × 175mm rectangle** (default)
- Baseplate thickness: **1.0mm**
- Alternative option: Convex hull baseplate (can be enabled in code)

### Pipeline Workflow

```
Input STL File
    ↓
[Step 1] Slice Original STL in Bambu Studio
    ↓
[Step 2] Extract G-code from .gcode.3mf file
    ↓
[Step 3] Create Baseplate
    ├─ Option A: Create 175×175mm rectangle baseplate (default)
    └─ Option B: Extract convex hull from first 15 layers
    ↓
[Step 4] Calculate Alignment Offset
    └─ (Only for convex hull method)
    ↓
[Step 5] Slice Baseplate in Bambu Studio
    └─ Import baseplate STL, align if needed, slice
    ↓
[Step 6] Combine Baseplate with Original Model
    └─ Replace bottom 5 layers of original with baseplate layers
    ↓
[Step 7] Output Final G-code File
    └─ Ready for 3D printing!
```

### Technical Details

1. **Automation Layer**
   - Uses `pyautogui` and `pydirectinput` (Windows) or AppleScript (macOS)
   - Controls Bambu Studio through keyboard shortcuts and UI automation
   - Handles file import, slicing, and export operations

2. **G-code Processing**
   - Extracts gcode from `.gcode.3mf` files (ZIP archives)
   - Parses first 15 layers to extract XY coordinates
   - Computes convex hull using computational geometry algorithms

3. **STL Generation**
   - Creates 3D STL files from 2D hull points
   - Extrudes hull vertically by 1mm (or 5mm for custom baseplates)
   - Applies 1mm buffer to hull for better coverage

4. **Layer Replacement**
   - Uses `ReplaceBaseplate` module to combine files
   - Replaces bottom 5 layers of original model with baseplate layers
   - Maintains all print settings and quality

---

## 📁 Essential Files (For Reference)

**If you're just using the GUI, you don't need to know about these files!** But here's what's important:

### Files You'll Actually Use

- **`launch_gui_nov10_2025.bat`** ⭐ **START HERE**
  - Double-click this to open the GUI
  - That's all you need!

### Core Files (Behind the Scenes)

- **`hull_baseplate_gui_nov10_2025.py`** - The GUI application
- **`full_pipeline.py`** - Main processing pipeline
- **`automation_windows.py`** - Controls Bambu Studio automatically
- **`create_rectangle_baseplate.py`** - Creates the baseplates
- **`ReplaceBaseplate/replace_baseplate_layers.py`** - Combines baseplate with model
- **`setup_windows.py`** - Run once for initial setup

---

## 🚀 Installation & Setup

### First Time Setup

1. **Download and extract** the project folder
2. **Run setup** (one time only):
   ```cmd
   python setup_windows.py
   ```
   This installs all required packages automatically.

3. **Configure Bambu Studio** (one time only):
   - Open Bambu Studio
   - Create a new project (File → New Project)
   - Set your printer and filament settings
   - Save the empty project
   - **Why:** The pipeline uses whatever settings are active in Bambu Studio

4. **Grant permissions** (if Windows asks):
   - Click "Yes" when Windows asks for permission to control other applications

5. **⚠️ IMPORTANT: Monitor First Few Runs**
   - **Bambu Studio may show popups** during the first few runs
   - Common popups: Filament sync, cloud sync, update notifications
   - **You need to handle these manually** - click through them quickly
   - After a few runs, Bambu Studio usually stops showing these popups
   - **Tip:** Keep Bambu Studio window visible during processing so you can see and handle popups

**That's it!** You're ready to use the GUI.

---

## 📖 Usage Guide

### Main Method: GUI Application (Recommended)

**The easiest way to use the pipeline:**

1. **Double-click** `launch_gui_nov10_2025.bat` to open the GUI
2. **Click "Browse Folder"** and select the folder containing your STL files
3. **Click "Run Pipeline"**
4. **Wait for processing to complete** (watch the progress log)
5. **Click "Open Output Folder"** to see your processed files

**That's it!** Your processed files will be in:
```
{your_input_folder}\slicer_output\
```

**What happens automatically:**
- ✅ Processes all STL files in your folder sequentially
- ✅ Creates baseplates for each model
- ✅ Combines baseplates with original models
- ✅ Saves final `.gcode.3mf` files ready for printing
- ✅ Cleans up intermediate files (keeps only final output)
- ✅ Deletes `.3mf` and `.gcode.3mf` files from input folder (prevents errors)

**Important Notes:**
- The pipeline will **delete** all `.3mf` and `.gcode.3mf` files from your input folder
- Only `.stl` files are preserved in the input folder
- All final output goes to `{input_folder}\slicer_output`
- Each STL file gets one final output file: `{filename}_with_hull_baseplate.gcode.3mf`

**⚠️ First Time Running?**
- **Keep Bambu Studio window visible** - you may need to handle popups
- Common popups: Filament sync, cloud sync, update notifications
- Click through popups quickly when they appear
- After a few runs, popups usually stop appearing
- See [Troubleshooting](#5-bambu-studio-popups--most-common-issue) for more details

### Alternative: Command Line (Advanced Users)

If you prefer command line:

```cmd
# Batch process a folder
python batch_process_cli.py "C:\path\to\stl\folder"

# Process single file
venv\Scripts\python.exe full_pipeline.py "C:\path\to\model.stl"
```

---

## ⚙️ Configuration Options (Advanced)

### Baseplate Type Selection

Edit `full_pipeline.py` line 722:

```python
# Configuration flag: Set to True to use convex hull baseplate, False to use full-size rectangle
USE_CONVEX_HULL = False  # Change to True for convex hull method
```

**Current Default:** `False` (uses 175×175mm rectangle baseplate)

### Baseplate Dimensions

The rectangle baseplate dimensions are set in `full_pipeline.py` line 837:

```python
create_rectangle_stl(175.0, height_mm=175.0, thickness_mm=1.0, output_path=rectangle_stl)
```

To change dimensions, modify:
- First parameter: Width in mm (currently 175.0)
- `height_mm`: Height in mm (currently 175.0)
- `thickness_mm`: Thickness in mm (currently 1.0)

### Hull Thickness

The convex hull thickness is set in `hull_to_stl.py` line 63:

```python
create_stl_from_hull(aligned_hull_points, height=1.0, output_path=output_stl_path)
```

Change `height=1.0` to desired thickness in mm.

### Layers to Replace

The number of bottom layers replaced is configured in `ReplaceBaseplate/replace_baseplate_layers.py`. Default is 5 layers.

---

## 📤 Output Files

### Output Location

**When using the GUI (recommended method):**

All output files are saved to:
```
{your_input_folder}\slicer_output\
```

**Example:**
If your input folder is `C:\Users\You\MySTLs\`, output will be:
```
C:\Users\You\MySTLs\slicer_output\
```

### What You Get

For each STL file you process, you get **one final output file:**

- **`{filename}_with_hull_baseplate.gcode.3mf`** ⭐ **READY TO PRINT**
  - This is your final file - load it into Bambu Studio and print!
  - Contains your original model with a custom baseplate for better bed adhesion
  - Baseplate is 175mm × 175mm, 1mm thick

**Example output folder:**
```
MySTLs\slicer_output\
├── Model1_with_hull_baseplate.gcode.3mf  ← Print this!
├── Model2_with_hull_baseplate.gcode.3mf  ← Print this!
└── Model3_with_hull_baseplate.gcode.3mf  ← Print this!
```

**That's it!** The pipeline automatically cleans up all intermediate files, so you only see the final printable files.

---

## 🔍 Troubleshooting

### Common Issues

#### 1. "Module not found" Errors

**Solution:**
```cmd
# Re-run setup
python setup_windows.py

# Or manually install dependencies
pip install -r requirements.txt
pip install pydirectinput
```

#### 2. "Bambu Studio not found" Error

**Solution:**
- Ensure Bambu Studio is installed
- Windows default location: `C:\Program Files\BambuStudio\bambu-studio.exe`
- Download from: https://bambulab.com/en/download/studio

#### 3. Automation Not Working

**Windows:**
- Grant permission when Windows asks to control other applications
- Ensure `pydirectinput` is installed: `pip install pydirectinput`

**macOS:**
- Grant Terminal accessibility permissions:
  - System Preferences → Security & Privacy → Privacy → Accessibility
  - Add Terminal and check the box
  - Restart Terminal

#### 4. Hull Movement Issues (10mm instead of 1mm)

**Solution:** This is fixed in current version. Ensure you have:
- `pydirectinput` installed
- Latest version of `automation_windows.py`

#### 5. Bambu Studio Popups (⚠️ Most Common Issue)

**What happens:**
- Bambu Studio may show various popups during processing:
  - Filament sync popups ("Sync Now" button)
  - Cloud sync notifications
  - Update notifications
  - Other dialog boxes

**What to do:**
- **Keep Bambu Studio window visible** during processing
- **Watch for popups** and click through them quickly
- Click "Sync Now", "OK", "Yes", or whatever button appears
- The automation will pause and wait, then continue after you handle the popup
- **This is most common during the first few runs** - after that, popups usually stop appearing

**Why this happens:**
- Bambu Studio shows popups for various reasons (sync, updates, confirmations)
- The automation can't automatically handle all popup types
- After a few runs, Bambu Studio usually remembers your preferences and stops showing popups

**Tips:**
- Run a test file first to see what popups appear
- Handle popups quickly so processing doesn't take too long
- Consider disabling cloud sync in Bambu Studio settings if possible (may reduce popups)
- The pipeline will wait for you, so don't worry about timing

**Note:** This is a known limitation. The automation handles the main workflow, but some Bambu Studio popups require manual interaction.

#### 6. Permission Errors (macOS)

**Solution:**
```bash
chmod +x *.sh
```

### Manual Steps (If Automation Fails)

If automation fails, you can complete steps manually:

1. Open Bambu Studio
2. Import your STL (Ctrl+I / Cmd+I)
3. Slice the model (Ctrl+R / Cmd+R)
4. Export as .gcode.3mf (Ctrl+G / Cmd+G)
5. Save the project (Ctrl+S / Cmd+S)

The pipeline will detect the generated files and continue automatically.

### Getting Help

1. Check the pipeline log file: `{model_name}_pipeline_log.txt`
2. Review the summary file: `pipeline_summary.txt`
3. Check that all prerequisites are installed
4. Verify Bambu Studio is configured correctly

---

## 📊 Understanding the Results

### Baseplate Metrics

When using convex hull method, the pipeline provides:
- **Area:** Total area of the convex hull baseplate
- **Perimeter:** Length of the hull boundary
- **Dimensions:** Width × Height of the hull
- **Center:** X,Y coordinates of the hull center
- **Vertices:** Number of points defining the hull shape

### Layer Replacement

- The pipeline replaces the **bottom 5 layers** of your original model
- These layers are replaced with the baseplate layers
- The baseplate provides a stable, flat foundation for printing
- All original model features above the baseplate are preserved

### Alignment Accuracy

The pipeline calculates alignment offsets to match the baseplate with the original model position. Alignment errors are reported in the log file.

---

## 🎯 Best Practices

### Input STL Requirements

- ✅ **Watertight mesh** (no holes or gaps)
- ✅ **Proper orientation** (base should be flat on build plate)
- ✅ **Reasonable size** (fits within Bambu Studio's build volume)
- ✅ **Valid STL format**

### Print Settings

- Use **100% infill** for baseplate layers (automatic)
- Standard print settings for the rest of the model
- The baseplate is designed to print easily with standard settings

### Output Usage

- **Print the final combined file** (`*_with_hull_baseplate.gcode.3mf`)
- The baseplate provides excellent bed adhesion
- Remove baseplate after printing (cut or break away)

### Workflow Tips

1. **Test with one file first** before batch processing
2. **Check the log file** if something goes wrong
3. **Keep intermediate files** during development (can disable cleanup)
4. **Use simplified GUI** for routine batch processing
5. **Use advanced GUI** when you need custom output locations

---

## 🔄 Version Information

**Current Version:** 1.1.17

**Recent Changes:**
- v1.1.17: Changed baseplate size to 175×175mm
- v1.1.16: Fixed indentation issues
- v1.1.15: Added USE_CONVEX_HULL flag, default to rectangle baseplate

**GUI Versions:**
- **Nov 10, 2025:** Simplified version (v1.0.3) - Recommended for most users
- **Nov 4, 2025:** Advanced version (v1.0.2) - Full-featured

---

## 📞 Support & Resources

### Documentation Files
- `README.md` - Main project documentation
- `README_GUI.md` - GUI-specific instructions
- `README_DEVELOPER_GUIDE.md` - Developer documentation
- `README_SHIFT_KEY_SOLUTION.md` - Technical details on movement precision

### Auto-Update System

The GUI applications include a comprehensive auto-update system that keeps your software up to date automatically.

#### How to Access

**In GUI Applications:**
- Open the GUI (Nov 10 or Nov 4 version)
- Click **Help → Check for Updates** in the menu bar
- The update check runs in the background

#### How It Works

1. **Version Checking**
   - Reads current version from `VERSION.txt`
   - Connects to GitHub API to check for latest release
   - Compares version numbers (semantic versioning: major.minor.patch)
   - Displays update information if available

2. **Update Detection**
   - Checks GitHub Releases API: `https://api.github.com/repos/{owner}/{repo}/releases/latest`
   - Compares your current version with the latest release tag
   - Shows release notes and version information

3. **Update Process** (if update available)
   - **Step 1: Backup** - Creates automatic backup of current installation
     - Backup stored in `backup_{timestamp}` folder
     - Preserves your configuration and virtual environment
   - **Step 2: Download** - Downloads update ZIP from GitHub
     - Shows download progress
     - Saves to temporary location
   - **Step 3: Install** - Extracts and installs new files
     - Preserves important files: `venv`, `config.json`, existing backups
     - Updates all Python scripts and documentation
     - Updates `VERSION.txt` with new version number
   - **Step 4: Verification** - Verifies installation success

4. **Rollback Feature**
   - If update fails, automatic rollback is available
   - Restores files from backup automatically
   - Ensures you can always return to previous working version

#### What Gets Updated

**Updated:**
- ✅ All Python scripts (`.py` files)
- ✅ Documentation files (`.md` files)
- ✅ Configuration templates
- ✅ `VERSION.txt` file

**Preserved (Not Updated):**
- ✅ Virtual environment (`venv` folder)
- ✅ Configuration file (`config.json`)
- ✅ Existing backup folders
- ✅ User-generated output files

#### Update Features

- **Automatic Backup** - Always creates backup before updating
- **Safe Installation** - Preserves your settings and environment
- **Progress Tracking** - Shows download and installation progress
- **Error Handling** - Automatic rollback if update fails
- **Version Comparison** - Smart version number comparison
- **Release Notes** - Displays what's new in the update

#### Manual Update Check

You can also check for updates programmatically:

```python
from auto_update import check_for_updates, get_current_version

# Get current version
current = get_current_version()
print(f"Current version: {current}")

# Check for updates
update_info = check_for_updates()
if update_info and update_info['available']:
    print(f"Update available: {update_info['latest_version']}")
    print(f"Release notes: {update_info['release_notes']}")
else:
    print("You're up to date!")
```

#### Update Requirements

- **Internet Connection** - Required to check GitHub API
- **GitHub Access** - Must be able to reach GitHub releases
- **Write Permissions** - Need write access to install directory
- **Backup Space** - Requires space for backup folder

#### Troubleshooting Updates

**"Failed to check for updates"**
- Check internet connection
- Verify GitHub is accessible
- Check firewall settings

**"Update installation failed"**
- Automatic rollback will restore previous version
- Check disk space availability
- Verify write permissions to installation directory

**"Version comparison error"**
- Ensure `VERSION.txt` exists and is readable
- Check version format (should be like "1.1.17")

#### Update Frequency

- Updates are checked **manually** when you click "Check for Updates"
- No automatic background checking (privacy-friendly)
- Check as often as you like - no rate limiting

#### Technical Details

**Module:** `auto_update.py`

**Key Functions:**
- `get_current_version()` - Reads version from VERSION.txt
- `check_for_updates()` - Checks GitHub for latest release
- `compare_versions()` - Compares version numbers
- `backup_current_files()` - Creates backup before update
- `download_update()` - Downloads update ZIP
- `install_update()` - Installs update files
- `rollback_update()` - Restores from backup

**GitHub Integration:**
- Uses GitHub Releases API
- Supports both release assets and source code ZIPs
- Handles GitHub's automatic source code archives

### GitHub Repository

Project repository: https://github.com/404andrewtaylor/Windows-Automated-BambuStudio-Slicing-and-Convex-Hull-Baseplate

---

## ✅ Quick Start Checklist

- [ ] Python 3.6+ installed
- [ ] Bambu Studio installed and configured
- [ ] Project downloaded and extracted
- [ ] Setup script run successfully (`setup_windows.py`)
- [ ] Bambu Studio configured with preferred settings
- [ ] Permissions granted (if prompted)
- [ ] Ready to process STL files!

---

## 🔧 TODO FOR DEVELOPER

### Immediate Todos

- [ ] **Get this working on Linux** - Port the pipeline to Linux with no added features
  - Adapt automation for Linux (replace Windows/macOS specific code)
  - Test with Linux-compatible UI automation libraries
  - Ensure all core functionality works identically

- [ ] **Implement premade/presliced baseplate selection mechanism**
  - Make the pipeline able to pick baseplates from a library (library creation can be done later)
  - Baseplates will be 6 layers thick with specific color pattern:
    - Layer 1: Same color as model
    - Layers 2-3: Color A
    - Layers 4-5: Color B
    - Layer 6: Same color as model
  - Automation should pick appropriate baseplate from library based on some sort of input (ask for more details)
  - Replace current dynamic baseplate generation with selection from presliced options
  - **Update layer replacement:** Change from replacing 5 layers to replacing 6 layers (currently defaults to 5 in `ReplaceBaseplate/replace_baseplate_layers.py` and `full_pipeline.py`)
  - **Note:** Creating the actual library of premade/presliced baseplates can be done later, but is still important

### Future Todos

#### Computer Vision & Full Automation
- [ ] **Implement computer vision for hands-free operation**
  - Take screenshots after each step
  - Read text from screenshots to determine state
  - Figure out where to point cursor based on screen content
  - Need mouse control capability (if possible)

#### Monitoring & Detection
- [ ] **Monitor for slicing completion**
  - Monitor specific pixels for indicators that slicing is done
  - Use visual cues to detect when Bambu Studio has finished processing
  - Automatically proceed to next step when ready

#### Process Selection
- [ ] **Allow user to pick which 'Process' to use**
  - Different processes for different file categories/types
  - Will involve reading screen, pointing, scrolling, clicking
  - Make process selection configurable per file type

#### Linux Accessibility Features
- [ ] **Explore Linux/Ubuntu accessibility settings**
  - Use arrow keys instead of mouse (accessibility feature)
  - May mess up other things, but could be backup if mouse control impossible
  - Test working through slicing/printing process manually to understand workflow

#### Printing Automation (Long Term)
- [ ] **Automate actual printing process**
  - After getting completed gcode with baseplate, open in Bambu Studio
  - Click print (likely has keyboard shortcut)
  - Change printer selection (no shortcut, requires mouse control)
  - Handle multiple printers scenario
  - Select correct printer for each job


---

**Created:** December 11, 2025  
**Last Updated:** December 11, 2025  
**Pipeline Version:** 1.1.17

