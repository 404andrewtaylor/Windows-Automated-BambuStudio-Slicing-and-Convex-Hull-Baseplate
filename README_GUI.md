# Hull Baseplate Pipeline - Desktop GUI

A user-friendly desktop application for the STL to Hull Baseplate Pipeline. This GUI makes it easy for anyone to create custom baseplates for their 3D prints without needing to use the command line.

**💻 Prefer Command Line?** Check out the **Batch Processing CLI** (`batch_process_cli.py`) - it provides the same simplified functionality as the Nov 10 GUI version but runs from the terminal. See the main [README.md](README.md) for CLI usage.

## 📋 Available GUI Versions

### ⚠️ Version Comparison

| Version | Status | Best For | Complexity |
|---------|--------|----------|------------|
| **Nov 10, 2025** | **RECOMMENDED** | Most users, batch processing | ⭐ Simple |
| **Nov 4, 2025** | **MOST ADVANCED** | Power users, full control | ⭐⭐⭐ Advanced |
| **Original** | **OBSOLETE** | Legacy compatibility only | ⭐⭐ Basic |

### 🎯 Simplified GUI Version (Nov 10, 2025) - **RECOMMENDED FOR MOST USERS**

**File:** `hull_baseplate_gui_nov10_2025.py`  
**Launcher:** `launch_gui_nov10_2025.bat` or `run_gui_nov10_2025.py`

**Features:**
- ✅ **Simplified interface** - Only asks for input folder
- ✅ **Automatic batch processing** - Processes all STL files in folder
- ✅ **Automatic output folder** - Creates `{input_folder}\slicer_output`
- ✅ **Automatic cleanup** - Deletes .3mf and .gcode.3mf files to prevent errors
- ✅ **No configuration** - Everything is automatic
- ✅ **User-friendly** - Minimal steps, maximum simplicity

**Perfect for:** Users who want the easiest possible experience for batch processing STL files.

### 🔧 Advanced GUI Version (Nov 4, 2025) - **MOST ADVANCED**

**File:** `hull_baseplate_gui_nov4_2025.py`  
**Launcher:** `launch_gui_nov4_2025.bat` or `run_gui_nov4_2025.py`

**Features:**
- ✅ **Full flexibility** - Single file or batch processing
- ✅ **Customizable output** - Choose output location and organization
- ✅ **Intermediate files** - Option to keep or discard intermediate files
- ✅ **Subfolder organization** - Option to create subfolders for each file
- ✅ **Manual or auto output** - Choose your own output folder or use auto-generation
- ✅ **Progress tracking** - Detailed progress for each file

**Perfect for:** Power users who need full control over processing options and file organization.

### 📜 Original GUI Version - **OBSOLETE**

**File:** `hull_baseplate_gui.py`  
**Launcher:** `launch_gui.bat` or `run_gui.py`

**Status:** Kept for compatibility, but **not recommended** for new users. Use Nov 4 or Nov 10 versions instead.

**Features:** Single STL file processing with manual output folder selection (basic functionality)

## 🚀 Quick Start

### 🎯 Simplified GUI Version (Nov 10, 2025) - **RECOMMENDED FOR MOST USERS**

#### Option 1: Double-Click Launcher (Recommended)
1. **Double-click `launch_gui_nov10_2025.bat`**
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
   python run_gui_nov10_2025.py
   ```

### 🔧 Advanced GUI Version (Nov 4, 2025) - **MOST ADVANCED**

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

### Simplified GUI Version (Nov 10, 2025) - **RECOMMENDED**

#### Step 1: Setup & Warning
1. **Open the GUI application**
2. **Read the prominent file deletion warning** at the top
   - ⚠️ **Important:** The application will delete all .3mf and .gcode.3mf files in your input folder
   - This prevents errors when Bambu Studio tries to save files that already exist
   - Only .stl files will be preserved in the input folder
3. **Read the Bambu Studio setup instructions**
4. **Complete the Bambu Studio setup** as described
5. **Check the "I have completed..." checkbox** (includes acknowledging the deletion warning)
6. **Click "Next"**

#### Step 2: Select Input Folder
1. **Click "Browse..."** to select your input folder
   - The folder should contain all the STL files you want to process
2. **The application will automatically:**
   - Count the STL files in the folder
   - Create output folder at `{input_folder}\slicer_output`
   - Process all files sequentially
   - Keep only final output files (no intermediate files)
3. **Click "Run Pipeline"**

#### Step 3: Processing
1. **The application will:**
   - Delete all .3mf and .gcode.3mf files from input folder (before processing)
   - Process all STL files sequentially
   - Save final output files to `{input_folder}\slicer_output`
   - Delete all .3mf and .gcode.3mf files from input folder again (after successful processing)
2. **Watch the progress bar** and status updates
3. **Monitor the log output** for detailed information
4. **Wait for completion** (usually 2-5 minutes per file)
5. **Click "Open Output Folder"** to see your files

**Note:** If any file fails to process, the cleanup step will be skipped to preserve files for debugging.

### 🔧 Advanced GUI Version (Nov 4, 2025) - **MOST ADVANCED**

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
- **Simplified Version (Nov 10, 2025) - Try running from Command Prompt:**
  ```cmd
  python run_gui_nov10_2025.py
  ```
- **Advanced Version (Nov 4, 2025) - Try running from Command Prompt:**
  ```cmd
  python run_gui_nov4_2025.py
  ```
- **Original Version - Try running from Command Prompt:**
  ```cmd
  python run_gui.py
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

### Enhanced Features (Nov 4, 2025 Version) - **MOST ADVANCED**
- **Batch Processing**: Process entire folders of STL files sequentially
- **Auto Output Folder**: Automatically creates `{input_folder}\slicer_output`
- **Flexible Organization**: Option to use subfolders or place files directly
- **Sequential Processing**: Each file completes before the next starts
- **Progress Tracking**: Shows current file number during batch operations
- **Full Control**: All options customizable (output location, intermediate files, subfolders)

### Simplified Features (Nov 10, 2025 Version) - **RECOMMENDED**
- **Automatic Batch Processing**: Processes all STL files in folder automatically
- **Automatic Output Folder**: Always creates `{input_folder}\slicer_output`
- **Automatic Cleanup**: Deletes .3mf and .gcode.3mf files to prevent errors
- **No Configuration**: Everything is automatic - just select input folder
- **User-Friendly**: Minimal steps, maximum simplicity
- **Error Prevention**: Automatic file cleanup prevents Bambu Studio save conflicts
- **Smart File Management**: Automatic conflict resolution with file renaming

## 🔍 What the Pipeline Does

The pipeline automatically performs these steps for each STL file:

1. **Slices your STL** in Bambu Studio with your settings
2. **Analyzes the first layer** to find all print areas
3. **Creates a convex hull** that encompasses the print area
4. **Generates a 1mm thick baseplate** from the hull
5. **Positions the baseplate** to match your model
6. **Slices the baseplate** in Bambu Studio
7. **Combines the baseplate** with your original model
8. **Creates the final file** ready for printing

### Version-Specific Behavior

**Nov 10 (Simplified) Version:**
- Automatically processes all STL files in the input folder
- Automatically deletes .3mf and .gcode.3mf files before and after processing
- Only keeps final output files (no intermediate files)
- Output folder always at `{input_folder}\slicer_output`

**Nov 4 (Advanced) Version:**
- Can process single files or entire folders
- User controls output location and file organization
- Option to keep or discard intermediate files
- Option to create subfolders for each file

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
