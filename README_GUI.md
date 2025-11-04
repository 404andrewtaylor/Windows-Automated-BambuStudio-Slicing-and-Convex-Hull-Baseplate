# Hull Baseplate Pipeline - Desktop GUI

A user-friendly desktop application for the STL to Hull Baseplate Pipeline. This GUI makes it easy for anyone to create custom baseplates for their 3D prints without needing to use the command line.

## 📋 Available GUI Versions

### Original GUI Version
- **File:** `hull_baseplate_gui.py`
- **Launcher:** `launch_gui.bat` or `run_gui.py`
- **Features:** Single STL file processing with manual output folder selection

### Enhanced GUI Version (Nov 4, 2025) - **RECOMMENDED**
- **File:** `hull_baseplate_gui_nov4_2025.py`
- **Launcher:** `launch_gui_nov4_2025.bat` or `run_gui_nov4_2025.py`
- **Features:** 
  - Single STL file OR folder batch processing
  - Automatic output folder generation
  - Flexible file organization options
  - Sequential batch processing with progress tracking

## 🚀 Quick Start

### Original GUI Version

#### Option 1: Double-Click Launcher (Recommended)
1. **Double-click `launch_gui.bat`**
2. The application will automatically set up everything and launch
3. Follow the on-screen instructions

#### Option 2: Python Command
1. **Open Command Prompt or PowerShell**
2. **Navigate to the pipeline folder:**
   ```cmd
   cd "C:\path\to\pipeline\folder"
   ```
3. **Run the GUI:**
   ```cmd
   python run_gui.py
   ```

### Enhanced GUI Version (Nov 4, 2025)

#### Option 1: Double-Click Launcher (Recommended)
1. **Double-click `launch_gui_nov4_2025.bat`**
2. The application will automatically set up everything and launch
3. Follow the on-screen instructions

#### Option 2: Python Command
1. **Open Command Prompt or PowerShell**
2. **Navigate to the pipeline folder:**
   ```cmd
   cd "C:\path\to\pipeline\folder"
   ```
3. **Run the GUI:**
   ```cmd
   python run_gui_nov4_2025.py
   ```

## 📋 Prerequisites

- **Windows 10/11**
- **Python 3.6+** (automatically checked by launcher)
- **Bambu Studio** (download from https://bambulab.com/en/download/studio)

**That's it!** The GUI will automatically:
- Create a virtual environment
- Install all required dependencies
- Set up everything needed to run the pipeline

## 🎯 How to Use

### Original GUI Version

#### Step 1: Setup
1. **Open the GUI application**
2. **Read the Bambu Studio setup instructions**
3. **Complete the Bambu Studio setup** as described
4. **Check the "I have completed..." checkbox**
5. **Click "Next"**

#### Step 2: File Selection
1. **Select your STL file** using the "Browse..." button
2. **Choose output folder** where the final file will be saved
3. **Choose whether to keep intermediate files:**
   - ✅ **Checked**: Keep all files (STL, hull files, analysis files)
   - ❌ **Unchecked**: Keep only the final combined model
4. **Click "Run Pipeline"**

#### Step 3: Progress
1. **Watch the progress bar** and status updates
2. **Monitor the log output** for detailed information
3. **Wait for completion** (usually 2-5 minutes)
4. **Click "Open Output Folder"** to see your files

### Enhanced GUI Version (Nov 4, 2025)

#### Step 1: Setup
1. **Open the GUI application**
2. **Read the Bambu Studio setup instructions**
3. **Complete the Bambu Studio setup** as described
4. **Check the "I have completed..." checkbox**
5. **Click "Next"**

#### Step 2: File Selection

**Choose Input Mode:**
- **Single STL File**: Process one file at a time (traditional mode)
- **Input Folder**: Process all STL files in a folder sequentially (batch mode)

**Configure Output Options:**
- **Automatically generate output folder**: 
  - ✅ **Checked**: Creates output folder at `{input_folder}\slicer_output` automatically
  - ❌ **Unchecked**: Choose output folder manually

**Select Files:**
- **Single File Mode**: Select your STL file using the "Browse..." button
- **Folder Mode**: Select input folder containing STL files

**Configure Options:**
- **Keep intermediate files**:
  - ✅ **Checked**: Keep all files (STL, hull files, analysis files)
  - ❌ **Unchecked**: Keep only the final combined model
- **Create subfolder for each file**:
  - ✅ **Checked**: Each file gets its own subfolder in output directory
  - ❌ **Unchecked**: All files placed directly in output folder (useful for batch processing)

**Click "Run Pipeline"**

#### Step 3: Progress
1. **Watch the progress bar** and status updates
2. **Monitor the log output** for detailed information
3. **For batch processing**: Watch progress for each file (e.g., "Processing file 2/5")
4. **Wait for completion** (usually 2-5 minutes per file)
5. **Click "Open Output Folder"** to see your files

## 📁 Output Files

### Original GUI Version

The application creates a final file in your chosen output folder:

- **`{model_name}_with_hull_baseplate.gcode.3mf`** - **Ready to print!**

If you chose to keep intermediate files, you'll also get:
- `{model_name}.gcode.3mf` - Original sliced model
- `{model_name}.3mf` - Original project
- `{model_name}_hull.stl` - Hull STL file
- `{model_name}_hull.gcode.3mf` - Sliced hull
- `{model_name}_hull.3mf` - Hull project
- `hull_points.txt` - Hull vertices
- `first_layer_analysis.png` - Visualization
- `pipeline_summary.txt` - Complete report

### Enhanced GUI Version (Nov 4, 2025)

**Output Organization:**

The application creates files based on your selected options:

**With Subfolders (Default):**
```
output_folder/
├── model1/
│   └── model1_with_hull_baseplate.gcode.3mf
├── model2/
│   └── model2_with_hull_baseplate.gcode.3mf
└── ...
```

**Without Subfolders (Batch Mode):**
```
output_folder/
├── model1_with_hull_baseplate.gcode.3mf
├── model2_with_hull_baseplate.gcode.3mf
└── ...
```

**Auto Output Folder:**
When "Automatically generate output folder" is enabled:
- **Single File Mode**: Creates `{stl_directory}\slicer_output`
- **Folder Mode**: Creates `{input_folder}\slicer_output`

**File Conflicts:**
If files with the same name exist (when not using subfolders), the application automatically renames them with a number suffix (e.g., `model1_1.gcode.3mf`, `model1_2.gcode.3mf`).

**Main Output File:**
- **`{model_name}_with_hull_baseplate.gcode.3mf`** - **Ready to print!**

**Intermediate Files (if enabled):**
- `{model_name}.gcode.3mf` - Original sliced model
- `{model_name}.3mf` - Original project
- `{model_name}_hull.stl` - Hull STL file
- `{model_name}_hull.gcode.3mf` - Sliced hull
- `{model_name}_hull.3mf` - Hull project
- `hull_points.txt` - Hull vertices
- `first_layer_analysis.png` - Visualization
- `pipeline_summary.txt` - Complete report

## 🔧 Troubleshooting

### "Python is not installed"
- **Solution**: Install Python 3.6+ from https://python.org
- Make sure to check "Add Python to PATH" during installation

### "Dependencies missing"
- **Solution**: The GUI will automatically create a virtual environment and install all dependencies
- If this fails, try running as Administrator

### "Bambu Studio not found"
- **Solution**: Install Bambu Studio from https://bambulab.com/en/download/studio
- Make sure it's installed in the default location

### "Pipeline failed"
- **Check the log output** for specific error messages
- **Verify Bambu Studio setup** was completed correctly
- **Make sure the STL file is valid** and not corrupted
- **Check that output folder is writable**

### GUI doesn't start
- **Original Version - Try running from Command Prompt:**
  ```cmd
  python run_gui.py
  ```
- **Enhanced Version (Nov 4, 2025) - Try running from Command Prompt:**
  ```cmd
  python run_gui_nov4_2025.py
  ```
- **Check Python installation:**
  ```cmd
  python --version
  ```

### Batch Processing Issues
- **No STL files found in folder**: Make sure the folder contains `.stl` or `.STL` files
- **Files not processing sequentially**: This is normal - each file must complete before the next starts
- **Output folder conflicts**: When not using subfolders, files are automatically renamed if conflicts occur

## 🎨 Features

### User-Friendly Interface
- **Step-by-step wizard** guides you through the process
- **Clear instructions** for Bambu Studio setup
- **File picker dialogs** for easy file selection
- **Progress tracking** with real-time updates
- **Detailed logging** for troubleshooting

### Smart Automation
- **Automatic dependency checking** and installation
- **Bambu Studio automation** handles slicing and exporting
- **Intelligent file management** organizes output files
- **Error handling** with helpful messages

### Flexible Options
- **Choose output location** for final files
- **Keep or clean up** intermediate files
- **Real-time progress** and status updates
- **One-click folder access** to results

### Enhanced Features (Nov 4, 2025 Version)
- **Batch Processing**: Process entire folders of STL files sequentially
- **Auto Output Folder**: Automatically creates `{input_folder}\slicer_output`
- **Flexible Organization**: Option to use subfolders or place files directly
- **Sequential Processing**: Each file completes before the next starts
- **Progress Tracking**: Shows current file number during batch operations
- **Smart File Management**: Automatic conflict resolution with file renaming

## 🔍 What the Pipeline Does

1. **Slices your STL** in Bambu Studio with your settings
2. **Analyzes the first layer** to find all print areas
3. **Creates a convex hull** that encompasses the print area
4. **Generates a 1mm thick baseplate** from the hull
5. **Positions the baseplate** to match your model
6. **Slices the baseplate** in Bambu Studio
7. **Combines the baseplate** with your original model
8. **Creates the final file** ready for printing

## 💡 Tips for Best Results

### STL File Requirements
- **Watertight mesh** (no holes or gaps)
- **Proper orientation** (base should be flat)
- **Reasonable size** (fits in printer build volume)

### Bambu Studio Setup
- **Use your actual printer settings** for best results
- **Set appropriate layer height** (e.g., 0.2mm)
- **Choose correct filament type** and color
- **Configure support settings** if needed

### Output Usage
- **Load the final .gcode.3mf file** into Bambu Studio
- **Use standard print settings** (baseplate prints easily)
- **The baseplate provides excellent bed adhesion**

## 🆘 Support

If you encounter issues:

1. **Check the log output** in the Progress tab
2. **Verify all prerequisites** are installed
3. **Complete Bambu Studio setup** as instructed
4. **Try with a simple STL file** first
5. **Check file permissions** on output folder

## 🎉 Success!

When everything works correctly, you'll have a custom baseplate that:
- **Improves print adhesion** to the build plate
- **Reduces warping** and lifting
- **Provides a solid foundation** for your model
- **Maintains perfect alignment** with your original design

Your final file `{model_name}_with_hull_baseplate.gcode.3mf` is ready to print in Bambu Studio!

---

**Original Version Created**: December 2024  
**Original Version**: 1.0  
**Enhanced Version (Nov 4, 2025)**: 1.1  
**Compatible with**: Windows 10/11, Bambu Studio

## 🆕 What's New in Version 1.1 (Nov 4, 2025)

### Major Features
- **Batch Processing**: Process entire folders of STL files sequentially
- **Auto Output Folder**: Automatically creates output folder at `{input_folder}\slicer_output`
- **Flexible File Organization**: Option to create subfolders or place files directly in output

### Improvements
- **Better Progress Tracking**: Shows current file number during batch operations
- **Smart Conflict Resolution**: Automatically renames files to prevent overwrites
- **Enhanced User Experience**: More intuitive file selection and organization options

### Use Cases
- **Single File Processing**: Use when processing individual models
- **Batch Processing**: Use when processing multiple models at once
- **Organized Output**: Use subfolders when you want organized file structure
- **Flat Output**: Disable subfolders when you want all files in one location
