# STL to Hull Baseplate Pipeline

This folder contains all the scripts needed to run the complete pipeline that converts an STL file into a 3D printable model with a convex hull baseplate.

## Quick Start

### For Windows Users

1. **Run the Windows setup:**
   ```cmd
   python setup_windows.py
   ```
   Or double-click `setup.bat`

2. **Run the pipeline:**
   ```cmd
   python full_pipeline.py C:\path\to\your\model.stl
   ```
   Or double-click `run_pipeline.bat`

### For macOS Users

1. **Install Python dependencies:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   pip install -r requirements_stl.txt
   ```

2. **Run the pipeline:**
   ```bash
   ./full_pipeline.sh /path/to/your/model.stl
   ```

## What the Pipeline Does

1. **Slices the original STL** in Bambu Studio
2. **Extracts the convex hull** from the first layer
3. **Creates a 1mm extruded hull STL**
4. **Calculates alignment offset** and moves the hull to match the original position
5. **Slices the aligned hull** in Bambu Studio
6. **Combines the hull baseplate** with the original model using ReplaceBaseplate
7. **Organizes all output files** and creates analysis reports

## Files in this Folder

### Main Scripts
- `full_pipeline.py` - Main pipeline script (cross-platform)
- `full_pipeline.sh` - macOS pipeline script (legacy)
- `slice_bambu_windows.py` - Windows slice script
- `slice_bambu.sh` - macOS slice script (legacy)
- `slice_bambu.scpt` - AppleScript for Bambu Studio automation (macOS)
- `import_move_slice_windows.py` - Windows import/move/slice script
- `import_move_slice.sh` - macOS import/move/slice script (legacy)

### Python Scripts
- `hull_to_stl.py` - Extracts convex hull and creates extruded STL
- `extract_and_analyze.py` - Analyzes first layer and computes convex hull
- `extrude_hull_to_stl.py` - Creates 3D STL from 2D hull points
- `extract_hull_points.py` - Extracts hull points from gcode

### Automation Modules
- `automation_windows.py` - Windows automation using pyautogui
- `automation_mac.py` - macOS automation using AppleScript

### Dependencies
- `ReplaceBaseplate/` - Folder containing the ReplaceBaseplate tool
- `requirements.txt` - Python dependencies for analysis and Windows automation
- `requirements_stl.txt` - Python dependencies for STL generation

### Setup Scripts
- `setup_windows.py` - Windows setup script
- `setup.sh` - macOS setup script (legacy)
- `setup.bat` - Windows batch file for easy setup
- `run_pipeline.bat` - Windows batch file for easy pipeline execution

## Output Files

The pipeline creates a folder named `{model_name}_pipeline` containing:

- `{model_name}.gcode.3mf` - Original sliced model
- `{model_name}.3mf` - Original project file
- `{model_name}_hull.stl` - Extruded convex hull STL
- `{model_name}_hull.gcode.3mf` - Sliced and aligned hull
- `{model_name}_hull.3mf` - Hull project file
- `{model_name}_with_hull_baseplate.gcode.3mf` - **Final combined model**
- `hull_points.txt` - Hull vertices for reference
- `first_layer_analysis.png` - Visualization of first layer
- `pipeline_summary.txt` - Complete pipeline report

## Requirements

### Windows
- **Windows 10/11** (for pyautogui automation)
- **Bambu Studio** installed (auto-detected)
- **Python 3.6+** with required packages
- **Command Prompt or PowerShell** access

### macOS
- **macOS** (for AppleScript automation)
- **Bambu Studio** installed in `/Applications/BambuStudio.app`
- **Python 3.6+** with required packages
- **Terminal access** for running scripts

## Troubleshooting

### Windows
- **Bambu Studio not found**: Run `python setup_windows.py` to detect installation
- **Python errors**: Check that all dependencies are installed in the virtual environment
- **Automation fails**: Make sure Bambu Studio is not minimized and is visible on screen
- **Permission errors**: Run Command Prompt as Administrator if needed

### macOS
- **Permission errors**: Make sure scripts are executable (`chmod +x *.sh`)
- **Bambu Studio not found**: Ensure Bambu Studio is installed in Applications
- **AppleScript errors**: Grant Terminal accessibility permissions in System Preferences

### General
- **Python errors**: Check that all dependencies are installed in the virtual environment
- **Alignment issues**: The pipeline automatically calculates and applies alignment offsets

## Notes

- The pipeline uses Shift+arrow keys to move objects in 1mm increments
- All movement calculations are automatic based on the original model's position
- The final output is ready for 3D printing with perfect baseplate alignment
