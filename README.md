# STL to Hull Baseplate Pipeline

## 🖥️ Desktop GUI Application (Recommended)

**NEW!** For the easiest experience, use our desktop GUI application:

### 🎯 GUI Features
- **User-friendly interface** - No command line needed!
- **Step-by-step wizard** guides you through the process
- **Automatic dependency checking** and installation
- **Real-time progress tracking** with detailed logs
- **File picker dialogs** for easy file selection
- **One-click output folder access**

### 🚀 Quick GUI Start

**Original GUI Version:**
1. **Double-click `launch_gui.bat`** (Windows)
2. **Follow the on-screen instructions**
3. **Complete Bambu Studio setup** as guided
4. **Select your STL file and output folder**
5. **Click "Run Pipeline" and wait for completion**

**New GUI Version (Nov 4, 2025) - Enhanced Features:**
1. **Double-click `launch_gui_nov4_2025.bat`** (Windows)
2. **Follow the on-screen instructions**
3. **Complete Bambu Studio setup** as guided
4. **Choose input mode:**
   - **Single STL File**: Process one file at a time
   - **Input Folder**: Process all STL files in a folder sequentially
5. **Configure output options:**
   - **Auto-generate output folder**: Creates `{input_folder}\slicer_output` automatically
   - **Manual output folder**: Choose your own output location
   - **Create subfolders**: Option to organize files in subfolders or place directly in output
6. **Click "Run Pipeline" and wait for completion**

### 🆕 New GUI Version Features (Nov 4, 2025)

The new GUI version includes enhanced capabilities:

- **📁 Batch Processing**: Process entire folders of STL files sequentially
- **🔧 Auto Output Folder**: Automatically creates output folder at `{input_folder}\slicer_output`
- **📂 Flexible Organization**: Option to create subfolders for each file or place all files directly in output folder
- **⚡ Sequential Processing**: Processes files one at a time, ensuring each completes before starting the next
- **📊 Progress Tracking**: Shows current file number (e.g., "Processing file 2/5") during batch operations

**See [README_GUI.md](README_GUI.md) for detailed GUI instructions.**

---

## 🚀 Command Line Usage

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

## 📥 Installation & Setup

### Step 1: Download and Extract
1. **Download the ZIP file** from GitHub: https://github.com/404andrewtaylor/Windows-Automated-BambuStudio-Slicing-and-Convex-Hull-Baseplate
2. **Extract the ZIP file** to your desired location (e.g., `C:\Users\YourName\Documents\`)

### Step 2: Open Terminal
1. **Open Command Prompt or PowerShell**
2. **Navigate to the extracted folder:**
   ```cmd
   cd "C:\path\to\extracted\folder"
   ```

### Step 3: Run Setup
1. **Run the Windows setup script:**
   ```cmd
   python setup_windows.py
   ```
   
   **What this does:**
   - Creates a virtual environment (`venv`)
   - Installs all Python dependencies (numpy, scipy, pyautogui, pydirectinput, etc.)
   - Finds and configures Bambu Studio path
   - Sets up the complete environment

2. **Grant automation permissions (if prompted):**
   - Windows may ask for permission to control other applications
   - Click "Yes" or "Allow" when prompted
   - This is required for pyautogui to control Bambu Studio

**Setup complete! You're ready to use the pipeline.**

## 🚀 Running the Pipeline

### Basic Usage
1. **Open Command Prompt or PowerShell**
2. **Navigate to the pipeline folder:**
   ```cmd
   cd "C:\path\to\extracted\folder"
   ```
3. **Run the pipeline with your STL file:**
   ```cmd
   venv\Scripts\python.exe full_pipeline.py "C:\path\to\your\model.stl"
   ```

### Complete Example
```cmd
# Navigate to the pipeline folder
cd "C:\Users\YourName\Documents\Windows-Automated-BambuStudio-Slicing-and-Convex-Hull-Baseplate-master"

# Run the pipeline on your STL file
venv\Scripts\python.exe full_pipeline.py "C:\Users\YourName\Documents\MyModel.stl"
```

### Output Location
The pipeline will create a folder named `{model_name}_pipeline` in the same directory as your input STL file.

**Example Output:**
```
C:\Users\YourName\Documents\MyModel_pipeline\
├── MyModel_with_hull_baseplate.gcode.3mf  ← FINAL OUTPUT (ready to print)
├── MyModel.gcode.3mf                      ← Original sliced model
├── MyModel_hull.stl                       ← Hull STL
├── MyModel_hull.gcode.3mf                 ← Sliced hull
├── MyModel_hull.3mf                       ← Hull project
├── hull_points.txt                        ← Hull vertices
├── first_layer_analysis.png               ← Visualization
└── pipeline_summary.txt                   ← Complete report
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

If the automation fails, you can complete the pipeline manually:

1. **Open Bambu Studio**
2. **Import your STL** (Ctrl+I)
3. **Slice the model** (Ctrl+R)
4. **Export as .gcode.3mf** (Ctrl+G)
5. **Save the project** (Ctrl+S)

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
Create a batch file to process multiple STL files:
```cmd
@echo off
for %%f in (C:\path\to\stl\files\*.stl) do (
    venv\Scripts\python.exe full_pipeline.py "%%f"
)
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
**GUI Version (Nov 4, 2025):** Enhanced with batch processing and auto output folder  
**Tested on:** Windows with Bambu Studio
