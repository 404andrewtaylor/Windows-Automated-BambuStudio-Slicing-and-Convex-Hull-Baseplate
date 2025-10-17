# STL to Hull Baseplate Pipeline - How to Use Guide

## 🚀 Quick Start

### Prerequisites

#### For Windows Users
- **Windows 10/11** (required for pyautogui automation)
- **Bambu Studio** installed (auto-detected)
- **Python 3.6+** installed
- **Command Prompt or PowerShell** access

#### For macOS Users
- **macOS** (required for AppleScript automation)
- **Bambu Studio** installed in `/Applications/BambuStudio.app`
- **Python 3.6+** installed
- **Terminal access** with proper permissions

### ⚠️ IMPORTANT: Bambu Studio Setup (Required Before Running)

**You MUST complete this setup before running the pipeline:**

1. **Open Bambu Studio**
2. **Create a new project** (File → New Project)
3. **Configure your preferred settings:**
   - Select your printer model
   - Choose your filament type and color
   - Set all your preferred print settings (layer height, infill, supports, etc.)
   - Configure any other settings you want to use
4. **Save this empty project** (File → Save As)
   - Save it anywhere (the location doesn't matter)
   - This ensures Bambu Studio opens with your preferred settings

**Why this is critical:** The automation will open Bambu Studio and use whatever settings are currently active. Without this setup, it will use default settings that may not be suitable for your printer/filament.

### One-Time Setup

#### For Windows Users

**Prerequisites (Install these first):**
- **Windows 10/11**
- **Python 3.6+** from https://python.org
- **Bambu Studio** from https://bambulab.com/en/download/studio

**Setup Steps:**

1. **Navigate to the pipeline directory:**
   ```cmd
   cd C:\path\to\pipeline_scripts
   ```

2. **Run the Windows setup (installs everything needed):**
   ```cmd
   python setup_windows.py
   ```
   Or double-click `setup.bat`

   **What this installs:**
   - Creates virtual environment (`venv`)
   - Installs all Python dependencies (numpy, scipy, pyautogui, pydirectinput, etc.)
   - Finds and configures Bambu Studio path
   - Sets up the complete environment

3. **Grant automation permissions (if prompted):**
   - Windows may ask for permission to control other applications
   - Click "Yes" or "Allow" when prompted
   - This is required for pyautogui to control Bambu Studio

**After setup, you're ready to use the pipeline!**

#### Quick Reference for Existing Users

**If you've already run the setup script, you can skip directly to running the pipeline:**

```cmd
cd "C:\path\to\pipeline_scripts"
.\venv\Scripts\Activate.ps1
python full_pipeline.py "C:\path\to\your\model.stl"
```

#### For macOS Users

1. **Navigate to the pipeline directory:**
   ```bash
   cd /path/to/pipeline_scripts
   ```

2. **Run the setup script:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Grant Terminal accessibility permissions:**
   - Open **System Preferences** → **Security & Privacy** → **Privacy** → **Accessibility**
   - Add **Terminal** to the list and check the box
   - Restart Terminal if needed

### Running the Pipeline

#### For Windows Users

**Prerequisites (if you haven't run setup yet):**
- Run the one-time setup: `python setup_windows.py`
- This installs all dependencies including `pydirectinput`

**Basic Usage (Recommended - Use Absolute Paths):**
```cmd
cd "C:\Users\Vitacore\Documents\Andrew_automationTesting\Windows-Automated-BambuStudio-Slicing-and-Convex-Hull-Baseplate-master"
.\venv\Scripts\Activate.ps1
python full_pipeline.py "C:\path\to\your\model.stl"
```

**Example with Absolute Paths:**
```cmd
cd "C:\Users\Vitacore\Documents\Andrew_automationTesting\Windows-Automated-BambuStudio-Slicing-and-Convex-Hull-Baseplate-master"
.\venv\Scripts\Activate.ps1
python full_pipeline.py "C:\Users\Vitacore\Documents\Andrew_automationTesting\mask_test3\ultra_simplified_m1.stl"
```

**Output Location:**
The pipeline will create a folder named `{model_name}_pipeline` in the same directory as your input STL file.

**Example Output:**
```
C:\Users\Vitacore\Documents\Andrew_automationTesting\mask_test3\ultra_simplified_m1_pipeline\
├── ultra_simplified_m1_with_hull_baseplate.gcode.3mf  ← FINAL OUTPUT (ready to print)
├── ultra_simplified_m1.gcode.3mf                      ← Original sliced model
├── ultra_simplified_m1_hull.stl                       ← Hull STL
├── ultra_simplified_m1_hull.gcode.3mf                 ← Sliced hull
├── ultra_simplified_m1_hull.3mf                       ← Hull project
├── hull_points.txt                                    ← Hull vertices
├── first_layer_analysis.png                           ← Visualization
└── pipeline_summary.txt                               ← Complete report
```

#### For macOS Users

**Basic Usage:**
```bash
./full_pipeline.sh "/path/to/your/model.stl"
```

**Example:**
```bash
./full_pipeline.sh "/path/to/your/model.stl"
```

## 📋 What the Pipeline Does

The pipeline automatically performs these steps:

1. **Slices the original STL** in Bambu Studio
2. **Extracts the convex hull** from the first layer
3. **Creates a 1mm extruded hull STL**
4. **Calculates alignment offset** and moves the hull to match the original position
5. **Slices the aligned hull** in Bambu Studio
6. **Combines the hull baseplate** with the original model using ReplaceBaseplate
7. **Organizes all output files** and creates analysis reports

## 📁 Output Files

The pipeline creates a folder named `{model_name}_pipeline` containing:

### Main Output Files
- **`{model_name}_with_hull_baseplate.gcode.3mf`** - **Final combined model ready for 3D printing**
- `{model_name}.gcode.3mf` - Original sliced model
- `{model_name}_hull.stl` - Extruded convex hull STL
- `{model_name}_hull.gcode.3mf` - Sliced and aligned hull
- `{model_name}_hull.3mf` - Hull project file

### Analysis Files
- `hull_points.txt` - Hull vertices for reference
- `first_layer_analysis.png` - Visualization of first layer
- `pipeline_summary.txt` - Complete pipeline report

## 🔧 Troubleshooting

### Common Issues

**1. "Module not found: pydirectinput" Error**
- **Solution:** Install the required package
  ```cmd
  pip install pydirectinput
  ```

**2. "Bambu Studio not found" Error**
- **Solution:** Install Bambu Studio at the correct location
- Windows: `C:\Program Files\Bambu Studio\bambu-studio.exe`
- Download from: https://bambulab.com/en/download/studio

**3. Hull moves too far (10mm instead of 1mm)**
- **Solution:** This is fixed! The pipeline now uses `pydirectinput` for precise 1mm movement
- If you still see this issue, ensure `pydirectinput` is installed and the automation code is up to date

**4. "osascript is not allowed to send keystrokes" Error (macOS)**
- **Solution:** Grant Terminal accessibility permissions in System Preferences
- Go to Security & Privacy → Privacy → Accessibility
- Add Terminal and check the box
- Restart Terminal

**5. Permission Errors**
- **Solution:** Make scripts executable (macOS)
  ```bash
  chmod +x *.sh
  ```

**6. Python Dependencies Missing**
- **Solution:** Install required packages
  ```cmd
  pip install -r requirements.txt
  pip install pydirectinput
  ```

### ✅ SHIFT Key Solution (Fixed!)

**Problem:** Bambu Studio's SHIFT + arrow key movement was not working with standard automation libraries, causing 10mm movement instead of 1mm.

**Solution:** The pipeline now uses `pydirectinput` specifically for SHIFT + arrow key combinations, which bypasses Qt's input filtering and provides precise 1mm movement.

**Technical Details:** See `README_SHIFT_KEY_SOLUTION.md` for complete documentation of the solution.

### Manual Steps (If Automation Fails)

If the AppleScript automation fails, you can complete the pipeline manually:

1. **Open Bambu Studio**
2. **Import your STL** (Cmd+I)
3. **Slice the model** (Cmd+R)
4. **Export as .gcode.3mf** (Cmd+G)
5. **Save the project** (Cmd+S)

The pipeline will detect the generated files and continue automatically.

### ⚠️ Known Issue: Filament Sync Popup

**Sometimes Bambu Studio will show a popup asking to sync filament settings between importing and slicing.**

**What to do:**
- **Be ready to act quickly** - you have only a few seconds
- **Click "Sync Now"** as soon as the popup appears
- **You may need to click it multiple times** if there are multiple prompts
- **The automation will continue** once you handle the popup

**Why this happens:** Bambu Studio sometimes detects that the filament settings need to be synchronized with the cloud or printer.

**Future improvement:** This is a known limitation that may be addressed in future versions of the pipeline.

## 📊 Understanding the Results

### Hull Metrics
- **Area:** Total area of the convex hull baseplate
- **Perimeter:** Length of the hull boundary
- **Dimensions:** Width x Height of the hull
- **Center:** X,Y coordinates of the hull center
- **Vertices:** Number of points defining the hull shape

### Layer Replacement
- The pipeline replaces the bottom 5 layers of your original model
- These layers are replaced with the convex hull baseplate
- The hull provides a stable, flat foundation for printing

## 🎯 Best Practices

### Input STL Requirements
- **Watertight mesh** (no holes or gaps)
- **Proper orientation** (base should be flat on build plate)
- **Reasonable size** (fits within Bambu Studio's build volume)

### Output Usage
- **Print the final combined model** (`*_with_hull_baseplate.gcode.3mf`)
- **Use standard print settings** (the hull is designed to print easily)
- **The hull baseplate provides excellent bed adhesion**

## 🔍 Advanced Usage

### Customizing Hull Height
Edit `hull_to_stl.py` and change the `extrusion_height` variable:
```python
extrusion_height = 1.0  # Change this value (in mm)
```

### Adjusting Layer Replacement
Edit `ReplaceBaseplate/replace_baseplate_layers.py` and modify:
```python
layers_to_replace = 5  # Change number of layers to replace
```

### Batch Processing
Create a script to process multiple STL files:
```bash
#!/bin/bash
for stl_file in /path/to/stl/files/*.stl; do
    ./full_pipeline.sh "$stl_file"
done
```

## 📞 Support

If you encounter issues:

1. **Check the pipeline summary** in the output directory
2. **Verify all prerequisites** are installed
3. **Check Terminal permissions** in System Preferences
4. **Review the generated analysis files** for insights

## 🎉 Success!

When the pipeline completes successfully, you'll see:
```
🎉 Full Pipeline Completed Successfully!
📁 All files saved to: {output_directory}
🚀 Ready for 3D printing both the original and hull models!
```

Your final printable file is `{model_name}_with_hull_baseplate.gcode.3mf` - load this into Bambu Studio and print!

---

**Created:** October 14, 2025  
**Pipeline Version:** 1.0  
**Tested on:** macOS with Bambu Studio
