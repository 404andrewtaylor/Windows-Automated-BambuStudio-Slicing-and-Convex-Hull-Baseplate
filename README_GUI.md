# Hull Baseplate Pipeline - Desktop GUI

A user-friendly desktop application for the STL to Hull Baseplate Pipeline. This GUI makes it easy for anyone to create custom baseplates for their 3D prints without needing to use the command line.

## 🚀 Quick Start

### Option 1: Double-Click Launcher (Recommended)
1. **Double-click `launch_gui.bat`**
2. The application will automatically set up everything and launch
3. Follow the on-screen instructions

### Option 2: Python Command
1. **Open Command Prompt or PowerShell**
2. **Navigate to the pipeline folder:**
   ```cmd
   cd "C:\path\to\pipeline\folder"
   ```
3. **Run the GUI:**
   ```cmd
   python run_gui.py
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

### Step 1: Setup
1. **Open the GUI application**
2. **Read the Bambu Studio setup instructions**
3. **Complete the Bambu Studio setup** as described
4. **Check the "I have completed..." checkbox**
5. **Click "Next"**

### Step 2: File Selection
1. **Select your STL file** using the "Browse..." button
2. **Choose output folder** where the final file will be saved
3. **Choose whether to keep intermediate files:**
   - ✅ **Checked**: Keep all files (STL, hull files, analysis files)
   - ❌ **Unchecked**: Keep only the final combined model
4. **Click "Run Pipeline"**

### Step 3: Progress
1. **Watch the progress bar** and status updates
2. **Monitor the log output** for detailed information
3. **Wait for completion** (usually 2-5 minutes)
4. **Click "Open Output Folder"** to see your files

## 📁 Output Files

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
- **Try running from Command Prompt:**
  ```cmd
  python run_gui.py
  ```
- **Check Python installation:**
  ```cmd
  python --version
  ```

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

**Created**: December 2024  
**Version**: 1.0  
**Compatible with**: Windows 10/11, Bambu Studio
