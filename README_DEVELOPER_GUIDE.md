# Developer & Maintainer Guide - Hull Baseplate Pipeline

## 📋 Table of Contents
1. [Prerequisites & System Requirements](#prerequisites--system-requirements)
2. [Dependency Management](#dependency-management)
3. [Virtual Environment Setup](#virtual-environment-setup)
4. [Creating New Versions](#creating-new-versions)
5. [Critical Dependencies & Verification](#critical-dependencies--verification)
6. [Common Issues & Solutions](#common-issues--solutions)
7. [Testing Checklist](#testing-checklist)
8. [Best Practices](#best-practices)

---

## Prerequisites & System Requirements

### System Requirements
- **Windows 10/11** (for Windows automation)
- **Python 3.6+** (Python 3.8+ recommended)
- **Bambu Studio** installed and configured
- **Administrator privileges** (may be required for some operations)

### Required Python Packages

The application requires several critical packages that **MUST** be installed:

#### Core Dependencies
- `numpy>=1.21.0` - Numerical computing
- `scipy>=1.7.0` - Scientific computing
- `matplotlib>=3.5.0` - Plotting and visualization
- `numpy-stl>=2.16.0` - **CRITICAL**: STL file handling (provides `stl` module)

#### Windows Automation Dependencies
- `pyautogui>=0.9.54` - GUI automation
- `pydirectinput>=1.0.4` - **CRITICAL**: Precise keyboard input (for SHIFT+arrow keys)
- `pygetwindow>=0.0.9` - Window management
- `pywinauto>=0.6.8` - Windows automation
- `pywin32>=306` - Windows API access

#### GUI Dependencies
- `tkinter` - GUI framework (usually included with Python)

### File Structure Requirements
```
project_root/
├── full_pipeline.py              # Main pipeline script
├── hull_to_stl.py               # Hull extraction (requires numpy-stl)
├── extract_and_analyze.py        # G-code analysis
├── extrude_hull_to_stl.py        # STL creation (requires numpy-stl)
├── automation_windows.py         # Windows automation
├── requirements.txt              # Core dependencies
├── requirements_gui.txt          # GUI dependencies (includes numpy-stl)
├── hull_baseplate_gui.py         # Original GUI (OBSOLETE)
├── hull_baseplate_gui_nov4_2025.py  # Advanced GUI version (MOST ADVANCED)
├── hull_baseplate_gui_nov10_2025.py # Simplified GUI version (RECOMMENDED)
├── run_gui.py                    # Original GUI launcher
├── run_gui_nov4_2025.py         # Advanced GUI launcher
├── run_gui_nov10_2025.py        # Simplified GUI launcher
├── launch_gui.bat               # Original GUI batch file
├── launch_gui_nov4_2025.bat     # Advanced GUI batch file
├── launch_gui_nov10_2025.bat    # Simplified GUI batch file
└── venv/                        # Virtual environment (created automatically)
```

### GUI Version Status

| Version | Status | Purpose | Complexity |
|---------|--------|---------|------------|
| **Nov 10, 2025** | **RECOMMENDED** | Simplified, user-friendly batch processing | ⭐ Simple |
| **Nov 4, 2025** | **MOST ADVANCED** | Full-featured with all options | ⭐⭐⭐ Advanced |
| **Original** | **OBSOLETE** | Legacy compatibility only | ⭐⭐ Basic |

**Note:** The original GUI version is kept for compatibility but is not recommended for new users. Use Nov 4 (advanced) or Nov 10 (simplified) versions instead.

---

## Dependency Management

### ⚠️ CRITICAL: Dependency Verification

**The most common issue is missing dependencies in existing virtual environments.**

When creating a new GUI version, you **MUST** implement proper dependency verification:

#### Required Verification Method

```python
def _verify_dependencies(self, venv_python):
    """Verify that critical dependencies are installed in the venv."""
    try:
        venv_pip = os.path.join(os.path.dirname(venv_python), "pip.exe")
        
        # Check if pip exists
        if not os.path.exists(venv_pip):
            self.log(f"Error: pip.exe not found at {venv_pip}")
            return False
        
        # List of critical packages: (package_name, import_name)
        # IMPORTANT: import_name is what you use in "import X"
        # package_name is what you install with pip
        critical_packages = [
            ("pyautogui", "pyautogui"),
            ("pydirectinput", "pydirectinput"),
            ("numpy-stl", "stl"),  # ⚠️ CRITICAL: numpy-stl provides 'stl' module
        ]
        
        missing_packages = []
        
        # Check each package individually
        for package_name, import_name in critical_packages:
            result = subprocess.run([venv_python, "-c", f"import {import_name}"], 
                                  capture_output=True, text=True, timeout=5)
            if result.returncode != 0:
                missing_packages.append((package_name, import_name))
                self.log(f"Warning: {import_name} module not found (from {package_name})")
        
        # Install any missing packages
        if missing_packages:
            self.log(f"Installing missing packages: {', '.join([p[0] for p in missing_packages])}...")
            failed_installations = []
            
            for package_name, import_name in missing_packages:
                self.log(f"Installing {package_name}...")
                result = subprocess.run([venv_pip, "install", package_name], 
                                     capture_output=True, text=True, timeout=120)
                if result.returncode != 0:
                    self.log(f"Error: Failed to install {package_name}: {result.stderr}")
                    failed_installations.append(package_name)
                else:
                    # ⚠️ CRITICAL: Verify installation succeeded by re-importing
                    verify_result = subprocess.run([venv_python, "-c", f"import {import_name}"], 
                                                  capture_output=True, text=True, timeout=5)
                    if verify_result.returncode == 0:
                        self.log(f"Successfully installed and verified {package_name}")
                    else:
                        self.log(f"Warning: {package_name} installed but import still fails")
                        failed_installations.append(package_name)
            
            if failed_installations:
                self.log(f"Error: Failed to install critical packages: {', '.join(failed_installations)}")
                return False
            else:
                self.log("All missing packages installed successfully")
                return True
        else:
            self.log("All critical dependencies are installed")
            return True
    except subprocess.TimeoutExpired:
        self.log(f"Error: Timeout while verifying/installing dependencies")
        return False
    except Exception as e:
        self.log(f"Warning: Could not verify dependencies: {e}")
        return False
```

#### Key Points:
1. **Check each package individually** - Don't assume if one is installed, all are
2. **Verify after installation** - Re-import to confirm installation succeeded
3. **Handle timeouts** - Some operations may take time
4. **Log everything** - Users need to see what's happening
5. **Return False on failure** - Don't silently continue if critical packages fail

### Common Dependency Issues

#### Issue: `ModuleNotFoundError: No module named 'stl'`
**Cause:** `numpy-stl` package not installed (provides the `stl` module)  
**Solution:** Ensure `_verify_dependencies` checks for `numpy-stl` and installs it if missing

#### Issue: `ModuleNotFoundError: No module named 'pydirectinput'`
**Cause:** `pydirectinput` not installed  
**Solution:** Ensure `_verify_dependencies` checks for `pydirectinput` and installs it if missing

#### Issue: Dependencies installed but import fails
**Cause:** Installation may have failed silently or package is corrupted  
**Solution:** Re-verify after installation by attempting import

---

## Virtual Environment Setup

### Automatic Setup (Recommended)

The GUI automatically creates and manages virtual environments:

1. **Checks for existing venv** in script directory
2. **Checks for venv** in current working directory
3. **Creates new venv** if none exists
4. **Installs all dependencies** from requirements files
5. **Verifies critical dependencies** before use

### Manual Setup

If you need to set up manually:

```cmd
# Create virtual environment
python -m venv venv

# Activate virtual environment
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
pip install -r requirements_gui.txt

# Verify critical packages
python -c "import pyautogui"
python -c "import pydirectinput"
python -c "import stl"  # From numpy-stl
```

### Virtual Environment Location

The application checks for venv in this order:
1. `{script_dir}/venv/Scripts/python.exe` (preferred)
2. `{current_dir}/venv/Scripts/python.exe`
3. Creates new venv if neither exists
4. Falls back to system Python (not recommended)

---

## Creating New Versions

### Step-by-Step Guide for Creating New GUI Versions

#### 1. Copy Existing Version
```bash
# Copy the latest working version (choose based on your needs)
# For advanced features: Copy Nov 4 version
cp hull_baseplate_gui_nov4_2025.py hull_baseplate_gui_new_version.py

# For simplified version: Copy Nov 10 version
cp hull_baseplate_gui_nov10_2025.py hull_baseplate_gui_new_version.py
```

**Note:** 
- **Nov 4 version** is the most advanced with all features
- **Nov 10 version** is simplified and user-friendly
- Choose the base version that matches your target complexity

#### 2. Update Version Information
```python
# Update title
self.root.title("Hull Baseplate Pipeline (New Version)")

# Update docstring
"""
Hull Baseplate Pipeline - Desktop GUI Application (New Version)
...
"""
```

#### 3. Implement Dependency Verification
**⚠️ CRITICAL:** Copy the complete `_verify_dependencies` method from the latest working version.

**DO NOT:**
- Skip dependency verification
- Only check one package (like `pyautogui`)
- Assume dependencies are installed

**DO:**
- Check all critical packages individually
- Verify installation after installing
- Handle errors gracefully
- Log everything

#### 4. Update `_get_python_executable` Method
Ensure it calls `_verify_dependencies`:

```python
def _get_python_executable(self, script_dir):
    venv_python = os.path.join(script_dir, "venv", "Scripts", "python.exe")
    if os.path.exists(venv_python):
        self.log(f"Using virtual environment Python: {venv_python}")
        # ⚠️ CRITICAL: Verify dependencies
        self._verify_dependencies(venv_python)
        return venv_python
    # ... rest of method
```

#### 5. Add Explicit Verification Before Processing
```python
def _process_single_file(self):
    # ... existing code ...
    python_exe = self._get_python_executable(script_dir)
    
    # ⚠️ CRITICAL: Verify dependencies before processing
    self.log("Verifying dependencies before processing...")
    if not self._verify_dependencies(python_exe):
        self.log("ERROR: Critical dependencies are missing. Pipeline may fail.")
        self.root.after(0, lambda: messagebox.showwarning("Dependency Warning", 
            "Some critical dependencies could not be installed.\nThe pipeline may fail. Check the log for details."))
    
    # ... continue with processing ...
```

#### 6. Create Launcher Script
```python
# run_gui_new_version.py
from hull_baseplate_gui_new_version import main as gui_main
gui_main()
```

#### 7. Create Batch File
```batch
@echo off
echo Hull Baseplate Pipeline - GUI Launcher (New Version)
python run_gui_new_version.py
pause
```

#### 8. Update Requirements Files
Ensure `requirements_gui.txt` includes:
```
numpy-stl>=2.16.0
```

---

## Creating & Modifying Workflows

### Understanding the Current Workflow Architecture

The pipeline follows a **sequential step-by-step workflow** where each step depends on the previous one:

```
Input STL
    ↓
Step 1: Slice Original STL (Bambu Studio automation)
    ↓
Step 2: Find Generated Files (.gcode.3mf, .3mf)
    ↓
Step 3: Extract Hull & Create Hull STL (Python processing)
    ↓
Step 4: Calculate Offset & Move/Slice Hull (Bambu Studio automation)
    ↓
Step 5: Combine Baseplate with Original (Python processing)
    ↓
Step 6: Create Analysis Files (Python processing)
    ↓
Final Output (.gcode.3mf)
```

### Workflow Components

#### 1. **Pipeline Orchestrator** (`full_pipeline.py`)
- **Purpose**: Main workflow controller
- **Responsibilities**:
  - Validates input
  - Creates output directory
  - Orchestrates all steps
  - Handles errors and cleanup
  - Creates final output

#### 2. **Automation Modules** (`automation_windows.py`, `automation_mac.py`)
- **Purpose**: Control Bambu Studio
- **Responsibilities**:
  - Open/close Bambu Studio
  - Import STL files
  - Slice models
  - Export files
  - Handle keyboard/mouse input

#### 3. **Processing Modules** (`hull_to_stl.py`, `extract_and_analyze.py`, `extrude_hull_to_stl.py`)
- **Purpose**: Process data and create files
- **Responsibilities**:
  - Extract G-code data
  - Calculate convex hull
  - Create STL files
  - Calculate offsets

#### 4. **Baseplate Replacement** (`ReplaceBaseplate/replace_baseplate_layers.py`)
- **Purpose**: Combine hull with original model
- **Responsibilities**:
  - Replace bottom layers
  - Merge models
  - Create final output

#### 5. **GUI Application** (`hull_baseplate_gui*.py`)
- **Purpose**: User interface
- **Responsibilities**:
  - User input
  - Progress tracking
  - File management
  - Dependency verification

### Current Workflow Steps (Detailed)

#### Step 1: Slice Original STL
**Function**: `slice_original_stl(input_stl, script_dir)`  
**Module**: `automation_windows.py` → `slice_stl_file()`  
**Dependencies**: `pyautogui`, `pydirectinput`, `pygetwindow`  
**Output**: `.gcode.3mf` and `.3mf` files in STL directory

**What it does**:
1. Opens Bambu Studio
2. Imports STL file
3. Slices the model
4. Exports as `.gcode.3mf`
5. Saves project as `.3mf`

**Key Integration Points**:
- Uses `script_dir` to find automation modules
- Returns `True/False` for success/failure
- Files saved to same directory as input STL

#### Step 2: Find Generated Files
**Function**: `find_generated_files(stl_path)`  
**Module**: `full_pipeline.py`  
**Dependencies**: None (file system only)  
**Output**: Path to `.gcode.3mf` file

**What it does**:
1. Constructs expected filename from STL name
2. Checks if file exists
3. Returns absolute path

**Key Integration Points**:
- Must match naming convention: `{stl_name}.gcode.3mf`
- Returns `None` if file not found
- Used by Step 3

#### Step 3: Extract Hull & Create Hull STL
**Function**: `create_hull_stl(gcode_3mf, output_dir, stl_name, script_dir, input_stl)`  
**Module**: `hull_to_stl.py` (called as subprocess)  
**Dependencies**: `numpy-stl`, `numpy`, `scipy`  
**Output**: `{stl_name}_hull.stl` in output directory

**What it does**:
1. Extracts G-code from `.gcode.3mf`
2. Parses first layer
3. Calculates convex hull
4. Creates extruded STL (1mm height)
5. Saves hull STL file

**Key Integration Points**:
- **CRITICAL**: Requires `numpy-stl` (provides `stl` module)
- Runs as subprocess using venv Python
- Must receive absolute paths
- Returns path to hull STL or `False`

#### Step 4: Calculate Offset & Move/Slice Hull
**Function**: `import_move_slice_hull(hull_stl, x_moves, y_moves, output_dir, stl_name, script_dir)`  
**Module**: `automation_windows.py` → `import_move_slice_file()`  
**Dependencies**: `pyautogui`, `pydirectinput`  
**Output**: `{stl_name}_hull.gcode.3mf` and `{stl_name}_hull.3mf`

**What it does**:
1. Calculates offset between original and hull
2. Opens Bambu Studio
3. Imports hull STL
4. Moves hull to match original position (using SHIFT+arrow keys)
5. Slices hull
6. Exports hull `.gcode.3mf`
7. Saves hull `.3mf`

**Key Integration Points**:
- Uses `pydirectinput` for precise 1mm movement
- Must calculate correct offset
- Returns success status and file paths

#### Step 5: Combine Baseplate with Original
**Function**: `run_replace_baseplate(hull_gcode_3mf, original_gcode_3mf, final_output, script_dir)`  
**Module**: `ReplaceBaseplate/replace_baseplate_layers.py`  
**Dependencies**: `zipfile`, `json` (standard library)  
**Output**: `{stl_name}_with_hull_baseplate.gcode.3mf`

**What it does**:
1. Opens both `.gcode.3mf` files (zip archives)
2. Extracts layer data
3. Replaces bottom 5 layers of original with hull
4. Creates new combined `.gcode.3mf`
5. Saves final output

**Key Integration Points**:
- Works with `.gcode.3mf` as ZIP files
- Replaces specific number of layers (configurable)
- Returns success status

#### Step 6: Create Analysis Files
**Function**: `create_analysis_files(gcode_3mf, output_dir, stl_name, script_dir)`  
**Module**: `extract_and_analyze.py`  
**Dependencies**: `numpy`, `scipy`, `matplotlib`  
**Output**: Analysis files (`.txt`, `.png`)

**What it does**:
1. Analyzes first layer
2. Creates visualization
3. Generates summary report
4. Saves analysis files

**Key Integration Points**:
- Optional step (can be skipped)
- Provides debugging information
- Creates visualizations

### Creating a New Workflow

#### Step 1: Plan Your Workflow

**Questions to Answer**:
1. What new steps do you need?
2. What existing steps can you reuse?
3. What new dependencies are required?
4. How do steps integrate with each other?
5. What files are created/modified at each step?

**Example**: Adding a post-processing step
- New step: Apply smoothing to hull
- Reuse: Steps 1-3 (slice, find, create hull)
- New dependency: `scipy` (already installed)
- Integration: After Step 3, before Step 4
- Files: Modified hull STL

#### Step 2: Create New Pipeline File

**Best Practice**: Copy existing pipeline and modify

```python
# full_pipeline_custom.py
#!/usr/bin/env python3
"""
Custom Pipeline: STL → Slice → Extract Hull → [YOUR STEP] → Slice Hull STL
Usage: python full_pipeline_custom.py <input_stl_file>
"""

import os
import sys
import time
import subprocess
from pathlib import Path

# Copy all helper functions from full_pipeline.py
def get_script_directory():
    """Get the directory containing this script."""
    return Path(__file__).parent.absolute()

def check_input_file(input_stl):
    """Check if input STL file exists and is valid."""
    # ... (copy from full_pipeline.py)

# Add your new step function
def your_new_step(input_file, output_dir, stl_name, script_dir):
    """Your custom processing step."""
    print("[CUSTOM] Your Custom Step...")
    
    # Your processing logic here
    # ...
    
    return output_file  # or False on failure

# Modify main() function
def main():
    """Main pipeline function."""
    # ... (copy validation from full_pipeline.py)
    
    # Step 1: Slice original STL
    if not slice_original_stl(input_stl, script_dir):
        sys.exit(1)
    
    # Step 2: Find generated files
    gcode_3mf = find_generated_files(input_stl)
    if not gcode_3mf:
        sys.exit(1)
    
    # Step 3: Create hull STL
    hull_stl = create_hull_stl(gcode_3mf, output_dir, stl_name, script_dir, input_stl)
    if not hull_stl:
        sys.exit(1)
    
    # YOUR NEW STEP HERE
    modified_hull_stl = your_new_step(hull_stl, output_dir, stl_name, script_dir)
    if not modified_hull_stl:
        print("[ERROR] Error: Your custom step failed")
        sys.exit(1)
    
    # Step 4: Continue with existing steps (using modified_hull_stl instead of hull_stl)
    # ...
```

#### Step 3: Create Supporting Modules (If Needed)

**If your step needs a new module**:

```python
# your_custom_module.py
"""Custom processing module."""

import os
import sys

def process_hull_stl(input_stl, output_stl, parameters):
    """
    Process hull STL file.
    
    Args:
        input_stl: Path to input STL file
        output_stl: Path to output STL file
        parameters: Dictionary of processing parameters
    
    Returns:
        True on success, False on failure
    """
    try:
        # Your processing logic
        # ...
        return True
    except Exception as e:
        print(f"[ERROR] Error in custom processing: {e}")
        return False
```

**Key Points**:
- Use absolute paths
- Return `True/False` for success/failure
- Handle errors gracefully
- Print clear error messages

#### Step 4: Update Dependencies

**If your workflow needs new dependencies**:

1. **Update `requirements.txt`**:
```
# Add your new dependencies
your-new-package>=1.0.0
```

2. **Update `requirements_gui.txt`** (if GUI is used):
```
# Add your new dependencies
your-new-package>=1.0.0
```

3. **Update `_verify_dependencies` in GUI**:
```python
critical_packages = [
    ("pyautogui", "pyautogui"),
    ("pydirectinput", "pydirectinput"),
    ("numpy-stl", "stl"),
    ("your-new-package", "your_new_module"),  # Add your package
]
```

4. **Update `_create_virtual_environment`**:
```python
additional_packages = [
    "numpy-stl",
    "pydirectinput",
    "pyautogui",
    "your-new-package",  # Add your package
]
```

#### Step 5: Integrate with GUI (If Needed)

**If you want GUI support for your workflow**:

1. **Update GUI to call your pipeline**:
```python
# In hull_baseplate_gui_custom.py
def _process_single_file(self):
    # ... existing code ...
    
    # Determine which pipeline to use
    if self.use_custom_workflow.get():
        pipeline_script = os.path.join(script_dir, "full_pipeline_custom.py")
    else:
        pipeline_script = os.path.join(script_dir, "full_pipeline.py")
    
    # ... rest of code ...
```

2. **Add GUI options** (if needed):
```python
# Add checkbox for custom workflow
self.use_custom_workflow = tk.BooleanVar(value=False)
custom_checkbox = ttk.Checkbutton(
    options_frame,
    text="Use custom workflow",
    variable=self.use_custom_workflow
)
```

### Modifying Existing Workflow Steps

#### Modifying Step 1: Slice Original STL

**Location**: `automation_windows.py` → `slice_stl_file()`

**Common Modifications**:
- Change slice settings
- Add pre-slice operations
- Add post-slice operations
- Modify file naming

**Example**: Add custom slice settings
```python
def slice_stl_file(input_stl, custom_settings=None):
    """Slice STL with optional custom settings."""
    # ... existing code ...
    
    # Add custom settings before slicing
    if custom_settings:
        apply_custom_settings(custom_settings)
    
    # ... continue with slicing ...
```

#### Modifying Step 3: Hull Creation

**Location**: `hull_to_stl.py`

**Common Modifications**:
- Change hull extrusion height
- Modify hull calculation method
- Add hull smoothing
- Change output format

**Example**: Change extrusion height
```python
# In hull_to_stl.py
def main():
    # ... existing code ...
    
    # Change extrusion height (default is 1.0mm)
    extrusion_height = 2.0  # Your custom height
    
    # ... rest of code ...
```

**⚠️ Important**: If you modify `hull_to_stl.py`, ensure:
- It still accepts the same command-line arguments
- It still returns the same exit codes
- Dependencies are still met

#### Modifying Step 4: Hull Movement

**Location**: `automation_windows.py` → `import_move_slice_file()`

**Common Modifications**:
- Change movement distance
- Modify movement method
- Add rotation
- Change alignment method

**Example**: Add rotation step
```python
def import_move_slice_file(hull_stl, x_moves, y_moves, output_gcode, output_3mf, rotation=0):
    """Import, move, rotate, and slice hull."""
    # ... existing import code ...
    
    # Add rotation if needed
    if rotation != 0:
        rotate_model(rotation)
    
    # ... continue with movement and slicing ...
```

### Adding New Workflow Steps

#### Step 1: Define Your Step Function

```python
def your_new_step(input_file, output_dir, stl_name, script_dir, **kwargs):
    """
    Your new processing step.
    
    Args:
        input_file: Input file path (from previous step)
        output_dir: Output directory
        stl_name: Base name for files
        script_dir: Script directory
        **kwargs: Additional parameters
    
    Returns:
        Output file path on success, False on failure
    """
    print("[YOUR_STEP] Your Step Name...")
    
    try:
        # Your processing logic
        output_file = os.path.join(output_dir, f"{stl_name}_your_output.ext")
        
        # Process input_file and create output_file
        # ...
        
        if os.path.exists(output_file):
            print(f"[OK] Created: {output_file}")
            return output_file
        else:
            print(f"[ERROR] Output file not created: {output_file}")
            return False
            
    except Exception as e:
        print(f"[ERROR] Error in your step: {e}")
        return False
```

#### Step 2: Integrate into Pipeline

```python
# In full_pipeline.py main()
def main():
    # ... existing steps ...
    
    # Step 3: Create hull STL
    hull_stl = create_hull_stl(gcode_3mf, output_dir, stl_name, script_dir, input_stl)
    if not hull_stl:
        sys.exit(1)
    
    # YOUR NEW STEP HERE
    print("")
    print("[YOUR_STEP] Your Step Name...")
    your_output = your_new_step(hull_stl, output_dir, stl_name, script_dir)
    if not your_output:
        print("[ERROR] Error: Your step failed")
        sys.exit(1)
    
    # Step 4: Continue with next step (using your_output)
    # ...
```

#### Step 3: Handle Dependencies

**If your step needs new dependencies**:

1. Add to requirements files
2. Update dependency verification
3. Test installation

**If your step runs as subprocess**:

```python
def your_new_step(input_file, output_dir, stl_name, script_dir):
    """Your step that runs as subprocess."""
    # Get Python executable
    if os.name == 'nt':  # Windows
        python_exe = os.path.join(script_dir, "venv", "Scripts", "python.exe")
    else:
        python_exe = os.path.join(script_dir, "venv", "bin", "python")
    
    # Run your script
    your_script = os.path.join(script_dir, "your_script.py")
    cmd = [python_exe, your_script, input_file, output_dir, stl_name]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"[ERROR] Error: {result.stderr}")
        return False
    
    return output_file
```

### Workflow Testing Checklist

#### Before Modifying Workflow

- [ ] Understand current workflow completely
- [ ] Identify which steps you're modifying
- [ ] List all dependencies (existing and new)
- [ ] Plan integration points
- [ ] Document expected inputs/outputs

#### During Development

- [ ] Test each step individually
- [ ] Test step integration
- [ ] Test error handling
- [ ] Test with different input files
- [ ] Verify output files are created correctly

#### After Modifying

- [ ] Test complete workflow end-to-end
- [ ] Test with fresh venv (no dependencies)
- [ ] Test with existing venv
- [ ] Test error cases (missing files, invalid input)
- [ ] Verify all dependencies are installed
- [ ] Test GUI integration (if applicable)
- [ ] Test batch processing (if applicable)

### Common Workflow Modification Patterns

#### Pattern 1: Add Pre-Processing Step

```python
# Before Step 1
preprocessed_stl = preprocess_stl(input_stl, output_dir, stl_name)
if not preprocessed_stl:
    sys.exit(1)

# Use preprocessed_stl instead of input_stl
if not slice_original_stl(preprocessed_stl, script_dir):
    sys.exit(1)
```

#### Pattern 2: Add Post-Processing Step

```python
# After Step 5
final_output = run_replace_baseplate(...)
if not final_output:
    sys.exit(1)

# Add post-processing
postprocessed_output = postprocess_output(final_output, output_dir, stl_name)
if not postprocessed_output:
    sys.exit(1)
```

#### Pattern 3: Modify Intermediate Step

```python
# Modify Step 3 to add smoothing
def create_hull_stl_with_smoothing(gcode_3mf, output_dir, stl_name, script_dir, input_stl):
    """Create hull STL with smoothing."""
    # Create hull STL (existing code)
    hull_stl = create_hull_stl(gcode_3mf, output_dir, stl_name, script_dir, input_stl)
    if not hull_stl:
        return False
    
    # Add smoothing
    smoothed_hull = smooth_stl(hull_stl, output_dir, stl_name)
    if not smoothed_hull:
        return False
    
    return smoothed_hull
```

#### Pattern 4: Conditional Steps

```python
# Conditional step based on parameters
if use_custom_hull:
    hull_stl = create_custom_hull(gcode_3mf, output_dir, stl_name, script_dir)
else:
    hull_stl = create_hull_stl(gcode_3mf, output_dir, stl_name, script_dir, input_stl)

if not hull_stl:
    sys.exit(1)
```

### Workflow Best Practices

#### 1. **Maintain Step Independence**
- Each step should be a separate function
- Steps should not depend on internal state of other steps
- Use file paths to pass data between steps

#### 2. **Use Absolute Paths**
- Always convert paths to absolute
- Prevents issues with working directory changes
- Makes debugging easier

#### 3. **Return Clear Status**
- Return file path on success
- Return `False` or `None` on failure
- Print clear error messages

#### 4. **Handle Errors Gracefully**
- Check return values from each step
- Exit early on failure
- Clean up temporary files

#### 5. **Log Everything**
- Print step names clearly
- Log file paths
- Log errors with context

#### 6. **Test Incrementally**
- Test each step individually
- Test step integration
- Test complete workflow

#### 7. **Document Changes**
- Update docstrings
- Document new dependencies
- Document integration points

### Workflow Modification Examples

#### Example 1: Add Hull Smoothing Step

```python
# Add after Step 3, before Step 4
def smooth_hull_stl(hull_stl, output_dir, stl_name, script_dir):
    """Smooth hull STL using scipy."""
    print("[SMOOTH] Smoothing hull STL...")
    
    try:
        from scipy.spatial import ConvexHull
        from stl import mesh
        import numpy as np
        
        # Load hull STL
        hull_mesh = mesh.Mesh.from_file(hull_stl)
        
        # Apply smoothing (your algorithm)
        # ...
        
        # Save smoothed STL
        smoothed_stl = os.path.join(output_dir, f"{stl_name}_hull_smoothed.stl")
        hull_mesh.save(smoothed_stl)
        
        print(f"[OK] Smoothed hull STL: {smoothed_stl}")
        return smoothed_stl
        
    except Exception as e:
        print(f"[ERROR] Error smoothing hull: {e}")
        return False

# In main():
hull_stl = create_hull_stl(...)
if not hull_stl:
    sys.exit(1)

# Add smoothing step
smoothed_hull = smooth_hull_stl(hull_stl, output_dir, stl_name, script_dir)
if not smoothed_hull:
    sys.exit(1)

# Use smoothed_hull instead of hull_stl for Step 4
```

#### Example 2: Add Quality Check Step

```python
# Add after Step 5
def quality_check(final_output, output_dir, stl_name):
    """Check quality of final output."""
    print("[QUALITY] Checking output quality...")
    
    try:
        # Your quality checks
        # - File size check
        # - Layer count check
        # - Geometry validation
        # ...
        
        if quality_passed:
            print("[OK] Quality check passed")
            return True
        else:
            print("[WARNING] Quality check failed")
            return False
            
    except Exception as e:
        print(f"[ERROR] Error in quality check: {e}")
        return False

# In main():
final_output = run_replace_baseplate(...)
if not final_output:
    sys.exit(1)

# Add quality check
if not quality_check(final_output, output_dir, stl_name):
    print("[WARNING] Quality check failed, but continuing...")
```

---

## Critical Dependencies & Verification

### Why Dependency Verification is Critical

**The original `hull_baseplate_gui.py` did NOT verify dependencies**, which led to:
- Silent failures when dependencies were missing
- Users not knowing what was wrong
- Inconsistent behavior across different systems

### Required Verification Points

1. **When finding existing venv** - Check if dependencies are installed
2. **Before single file processing** - Verify before starting
3. **Before batch processing** - Verify before starting batch
4. **After creating new venv** - Verify installation succeeded

### Critical Packages That Must Be Verified

| Package Name | Import Name | Used By | Critical? |
|-------------|-------------|----------|-----------|
| `numpy-stl` | `stl` | `hull_to_stl.py`, `extrude_hull_to_stl.py` | ✅ YES |
| `pydirectinput` | `pydirectinput` | `automation_windows.py` | ✅ YES |
| `pyautogui` | `pyautogui` | `automation_windows.py` | ✅ YES |

### Verification Checklist

- [ ] Check `numpy-stl` (imports as `stl`)
- [ ] Check `pydirectinput`
- [ ] Check `pyautogui`
- [ ] Install missing packages
- [ ] Verify installation succeeded (re-import)
- [ ] Handle installation failures
- [ ] Log all operations
- [ ] Show user warnings if verification fails

---

## Common Issues & Solutions

### Issue 1: `ModuleNotFoundError: No module named 'stl'`

**Symptoms:**
```
[ERROR] Error: Failed to create hull STL: Traceback (most recent call last):
  File "hull_to_stl.py", line 10, in module>
    from stl import mesh
ModuleNotFoundError: No module named 'stl'
```

**Root Cause:**
- `numpy-stl` package not installed in virtual environment
- Dependency verification not checking for `numpy-stl`
- Verification only checking `pyautogui` and skipping others

**Solution:**
1. Ensure `_verify_dependencies` checks for `numpy-stl` (imports as `stl`)
2. Install missing package: `pip install numpy-stl`
3. Verify installation: `python -c "import stl"`

**Prevention:**
- Always verify all critical packages individually
- Don't assume if one package is installed, all are
- Re-verify after installation

### Issue 2: Batch Processing Fails for All Files

**Symptoms:**
- All files in batch fail with same error
- Error occurs at same step for all files
- Usually `ModuleNotFoundError` for `stl` module

**Root Cause:**
- Dependency verification not running before batch processing
- Verification only runs once, not before each file
- Missing dependency affects all files

**Solution:**
1. Add explicit verification before batch processing starts
2. Verify dependencies before processing any files
3. Show warning if verification fails

**Prevention:**
- Always verify dependencies before batch processing
- Don't assume dependencies are still installed
- Log verification results

### Issue 3: Original GUI Works, New Version Doesn't

**Root Cause:**
- Original GUI doesn't verify dependencies (assumes they're installed)
- New version tries to verify but implementation is flawed
- Existing venv missing some dependencies

**Solution:**
1. Implement complete dependency verification
2. Check all critical packages individually
3. Install missing packages automatically
4. Verify installation succeeded

**Prevention:**
- Always implement complete dependency verification
- Test with fresh venv and existing venv
- Test with missing dependencies

### Issue 4: Dependencies Installed But Import Fails

**Symptoms:**
- `pip install` succeeds
- But `import` still fails
- Package may be corrupted or wrong version

**Root Cause:**
- Installation succeeded but package is broken
- Wrong package version installed
- Virtual environment corruption

**Solution:**
1. Re-verify after installation (attempt import)
2. Reinstall package: `pip uninstall numpy-stl && pip install numpy-stl`
3. Check package version: `pip show numpy-stl`
4. Recreate venv if necessary

**Prevention:**
- Always verify installation by attempting import
- Check package version matches requirements
- Handle verification failures gracefully

### Issue 5: Virtual Environment Not Found

**Symptoms:**
- Application falls back to system Python
- Dependencies may be missing
- Inconsistent behavior

**Root Cause:**
- Venv not created
- Venv in wrong location
- Path issues

**Solution:**
1. Check venv location (script_dir/venv or current_dir/venv)
2. Create venv if missing
3. Verify venv creation succeeded
4. Check Python executable path

**Prevention:**
- Always check multiple venv locations
- Create venv if missing
- Verify venv creation succeeded
- Log venv location being used

---

## Testing Checklist

### Before Releasing New Version

#### Basic Functionality
- [ ] GUI launches without errors
- [ ] Can select single STL file
- [ ] Can select input folder (if batch processing)
- [ ] Can select output folder
- [ ] Can run pipeline on single file
- [ ] Can run batch processing (if implemented)
- [ ] Progress bar updates correctly
- [ ] Log output shows all steps

#### Dependency Verification
- [ ] Works with fresh venv (no dependencies)
- [ ] Works with existing venv (all dependencies installed)
- [ ] Works with existing venv (missing some dependencies)
- [ ] Verifies `numpy-stl` correctly
- [ ] Verifies `pydirectinput` correctly
- [ ] Verifies `pyautogui` correctly
- [ ] Installs missing dependencies automatically
- [ ] Verifies installation succeeded
- [ ] Shows warning if verification fails

#### Virtual Environment
- [ ] Finds venv in script directory
- [ ] Finds venv in current directory
- [ ] Creates venv if missing
- [ ] Installs dependencies in new venv
- [ ] Falls back to system Python gracefully (with warning)

#### Error Handling
- [ ] Handles missing STL file gracefully
- [ ] Handles missing output folder gracefully
- [ ] Handles pipeline failures gracefully
- [ ] Shows error messages in log
- [ ] Shows error dialogs when appropriate
- [ ] Doesn't crash on errors

#### Batch Processing (if implemented)
- [ ] Processes all files in folder
- [ ] Handles files sequentially
- [ ] Shows progress for each file
- [ ] Continues after file failure
- [ ] Shows summary at end
- [ ] Organizes output correctly
- [ ] Handles duplicate filenames

#### Output Management
- [ ] Moves files to output folder correctly
- [ ] Respects "keep intermediate files" option
- [ ] Respects "create subfolders" option
- [ ] Handles filename conflicts
- [ ] Cleans up pipeline folders
- [ ] Opens output folder correctly

### Testing Scenarios

#### Scenario 1: Fresh Installation
1. Delete venv folder
2. Launch GUI
3. Verify venv is created
4. Verify dependencies are installed
5. Run pipeline on test file
6. Verify output is correct

#### Scenario 2: Existing Venv with Missing Dependencies
1. Create venv manually
2. Install only `pyautogui` (missing `numpy-stl`)
3. Launch GUI
4. Verify missing dependencies are detected
5. Verify dependencies are installed
6. Run pipeline on test file
7. Verify output is correct

#### Scenario 3: Batch Processing
1. Create folder with multiple STL files
2. Launch GUI
3. Select input folder
4. Select output folder
5. Run batch processing
6. Verify all files are processed
7. Verify output is organized correctly

#### Scenario 4: Error Handling
1. Launch GUI
2. Try to run without selecting files (should show error)
3. Select invalid file (should show error)
4. Select invalid output folder (should show error)
5. Run pipeline with file that will fail (should handle gracefully)

---

## Best Practices

### Code Organization

1. **Separate concerns** - GUI logic separate from pipeline logic
2. **Reusable methods** - Don't duplicate code
3. **Clear naming** - Method names should describe what they do
4. **Comments** - Document complex logic
5. **Error handling** - Always handle errors gracefully

### Dependency Management

1. **Always verify dependencies** - Don't assume they're installed
2. **Check individually** - Don't assume if one is installed, all are
3. **Verify after installation** - Re-import to confirm
4. **Log everything** - Users need to see what's happening
5. **Handle failures** - Show warnings, don't silently fail

### Virtual Environment

1. **Check multiple locations** - Script dir and current dir
2. **Create if missing** - Don't require manual setup
3. **Install all dependencies** - From requirements files
4. **Verify installation** - Check that packages work
5. **Fall back gracefully** - System Python with warning

### User Experience

1. **Clear error messages** - Tell users what went wrong
2. **Progress feedback** - Show what's happening
3. **Log output** - Detailed logs for debugging
4. **Warning dialogs** - Alert users to potential issues
5. **Help text** - Explain options and features

### Testing

1. **Test with fresh venv** - No dependencies installed
2. **Test with existing venv** - All dependencies installed
3. **Test with partial venv** - Some dependencies missing
4. **Test error cases** - Missing files, invalid paths, etc.
5. **Test batch processing** - Multiple files, failures, etc.

### Version Control

1. **Keep old versions** - Don't delete working versions
2. **Clear version naming** - Use dates or version numbers
3. **Document changes** - What's new in each version
4. **Test before committing** - Don't commit broken code
5. **Update README** - Document new features

---

## Quick Reference: Critical Code Patterns

### Dependency Verification Pattern
```python
def _verify_dependencies(self, venv_python):
    """Verify that critical dependencies are installed."""
    # 1. Check pip exists
    # 2. Define critical packages (package_name, import_name)
    # 3. Check each package individually
    # 4. Install missing packages
    # 5. Verify installation succeeded
    # 6. Return True/False
```

### Virtual Environment Pattern
```python
def _get_python_executable(self, script_dir):
    """Get Python executable, creating venv if needed."""
    # 1. Check script_dir/venv
    # 2. Check current_dir/venv
    # 3. Create venv if missing
    # 4. Verify dependencies
    # 5. Fall back to system Python
```

### Error Handling Pattern
```python
try:
    # Operation
except SpecificError as e:
    self.log(f"Error: {e}")
    # Handle error
    return False
except Exception as e:
    self.log(f"Unexpected error: {e}")
    # Handle unexpected error
    return False
```

---

## Summary

### Key Takeaways

1. **Always verify dependencies** - Don't assume they're installed
2. **Check all critical packages individually** - Don't skip any
3. **Verify after installation** - Re-import to confirm
4. **Handle errors gracefully** - Show warnings, don't crash
5. **Test thoroughly** - Fresh venv, existing venv, missing deps
6. **Log everything** - Users need visibility
7. **Document changes** - Future you will thank you

### Most Common Mistakes

1. ❌ Only checking `pyautogui` and assuming others are installed
2. ❌ Not verifying installation succeeded
3. ❌ Not checking dependencies before batch processing
4. ❌ Assuming venv has all dependencies
5. ❌ Not handling errors gracefully

### Success Criteria

✅ Works with fresh venv (no dependencies)  
✅ Works with existing venv (all dependencies)  
✅ Works with existing venv (missing dependencies)  
✅ Installs missing dependencies automatically  
✅ Verifies installation succeeded  
✅ Handles errors gracefully  
✅ Provides clear feedback to users  

---

**Last Updated:** November 2025  
**Version:** 1.0  
**Maintained By:** Development Team

