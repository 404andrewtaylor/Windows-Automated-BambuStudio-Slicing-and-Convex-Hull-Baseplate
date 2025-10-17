#!/usr/bin/env python3
"""
Clean Windows setup script without emoji characters.
"""

import os
import sys
import subprocess
import json
from pathlib import Path

def check_python():
    """Check if Python 3 is available."""
    try:
        result = subprocess.run([sys.executable, "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"SUCCESS: Python found: {result.stdout.strip()}")
            return True
    except Exception as e:
        print(f"ERROR: Error checking Python: {e}")
    
    print("ERROR: Python 3 is not installed or not in PATH")
    print("   Please install Python 3.6 or later from https://python.org")
    return False

def find_bambu_studio():
    """Find Bambu Studio installation."""
    print("Searching for Bambu Studio...")
    
    # Check PATH first
    import shutil
    bambu_path = shutil.which("bambu-studio")
    if bambu_path:
        print(f"SUCCESS: Bambu Studio found in PATH: {bambu_path}")
        return bambu_path
    
    # Check common installation paths
    possible_paths = [
        r"C:\Program Files\Bambu Studio\bambu-studio.exe",
        r"C:\Program Files (x86)\Bambu Studio\bambu-studio.exe",
        r"C:\Users\{}\AppData\Local\Programs\Bambu Studio\bambu-studio.exe".format(os.getenv('USERNAME', '')),
        r"C:\Users\{}\AppData\Local\Bambu Studio\bambu-studio.exe".format(os.getenv('USERNAME', '')),
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            print(f"SUCCESS: Bambu Studio found: {path}")
            return path
    
    # Check Start Menu shortcuts
    start_menu_path = r"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Bambu Studio"
    if os.path.exists(start_menu_path):
        print(f"Found Bambu Studio in Start Menu: {start_menu_path}")
        for file in os.listdir(start_menu_path):
            if file.endswith('.lnk'):
                try:
                    import win32com.client
                    shell = win32com.client.Dispatch("WScript.Shell")
                    shortcut = shell.CreateShortCut(os.path.join(start_menu_path, file))
                    target_path = shortcut.TargetPath
                    if os.path.exists(target_path) and target_path.endswith('.exe'):
                        print(f"SUCCESS: Bambu Studio found via Start Menu shortcut: {target_path}")
                        return target_path
                except Exception as e:
                    print(f"WARNING: Could not resolve Start Menu shortcut: {e}")
    
    # Recursive search in common directories
    search_paths = [
        r"C:\Program Files",
        r"C:\Program Files (x86)",
        os.path.expanduser(r"~\AppData\Local\Programs"),
        os.path.expanduser(r"~\AppData\Local"),
    ]
    
    for search_path in search_paths:
        if os.path.exists(search_path):
            print(f"Searching in: {search_path}")
            for root, dirs, files in os.walk(search_path):
                if "bambu-studio.exe" in files:
                    exe_path = os.path.join(root, "bambu-studio.exe")
                    if os.path.exists(exe_path):
                        print(f"SUCCESS: Bambu Studio found: {exe_path}")
                        return exe_path
                # Limit depth to avoid long searches
                if root.count(os.sep) - search_path.count(os.sep) > 3:
                    dirs[:] = []
    
    print("ERROR: Bambu Studio not found")
    print("   Please install Bambu Studio from: https://bambulab.com/en/download/studio")
    return None

def create_virtual_environment():
    """Create Python virtual environment."""
    print("Creating Python virtual environment...")
    try:
        subprocess.run([sys.executable, "-m", "venv", "venv"], check=True)
        print("SUCCESS: Virtual environment created successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"ERROR: Error creating virtual environment: {e}")
        return False
    except Exception as e:
        print(f"ERROR: Error creating virtual environment: {e}")
        return False

def install_dependencies():
    """Install Python dependencies."""
    print("Installing Python dependencies...")
    
    venv_python = Path("venv/Scripts/python.exe")
    pip_exe = Path("venv/Scripts/pip.exe")
    
    if not pip_exe.exists():
        print(f"ERROR: pip not found at {pip_exe}")
        return False
    
    try:
        # Upgrade pip
        print("Upgrading pip...")
        subprocess.run([str(venv_python), "-m", "pip", "install", "--upgrade", "pip"], check=True)
        
        # Install requirements
        print("Installing requirements.txt...")
        subprocess.run([str(venv_python), "-m", "pip", "install", "-r", "requirements.txt"], check=True)
        
        # Install STL requirements
        if os.path.exists("requirements_stl.txt"):
            print("Installing requirements_stl.txt...")
            subprocess.run([str(venv_python), "-m", "pip", "install", "-r", "requirements_stl.txt"], check=True)
        
        print("SUCCESS: Dependencies installed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"ERROR: Error installing dependencies: {e}")
        return False
    except Exception as e:
        print(f"ERROR: Error installing dependencies: {e}")
        return False

def create_batch_files():
    """Create Windows batch files."""
    print("Creating Windows batch files...")
    
    # run_pipeline.bat
    run_pipeline_content = '''@echo off
echo STL to Hull Baseplate Pipeline
echo ==============================

if "%~1"=="" (
    echo Usage: run_pipeline.bat ^<stl_file^>
    echo Example: run_pipeline.bat C:\\path\\to\\model.stl
    pause
    exit /b 1
)

echo Input STL: %1
echo.

venv\\Scripts\\python.exe simple_slice.py "%1"

pause
'''
    
    with open("run_pipeline.bat", "w") as f:
        f.write(run_pipeline_content)
    
    # setup.bat
    setup_content = '''@echo off
echo Setting up STL to Hull Baseplate Pipeline
echo =========================================

python setup_windows_clean.py

pause
'''
    
    with open("setup.bat", "w") as f:
        f.write(setup_content)
    
    print("SUCCESS: Batch files created:")
    print("  - run_pipeline.bat (run the pipeline)")
    print("  - setup.bat (run setup)")

def create_config(bambu_path):
    """Create configuration file."""
    print("Creating configuration file...")
    
    config = {
        "bambu_studio_path": bambu_path,
        "python_path": sys.executable,
        "version": "1.0.0"
    }
    
    with open("config.json", "w") as f:
        json.dump(config, f, indent=2)
    
    print("SUCCESS: Configuration file created: config.json")

def main():
    """Main setup function."""
    print("Setting up STL to Hull Baseplate Pipeline for Windows...")
    print("")
    
    # Check Python
    if not check_python():
        sys.exit(1)
    
    # Find Bambu Studio
    bambu_path = find_bambu_studio()
    if not bambu_path:
        print("WARNING: Bambu Studio not found. You can install it later.")
        print("   The pipeline will not work until Bambu Studio is installed.")
        bambu_path = ""
    
    # Create virtual environment
    if not create_virtual_environment():
        sys.exit(1)
    
    # Install dependencies
    if not install_dependencies():
        sys.exit(1)
    
    # Create batch files
    create_batch_files()
    
    # Create config
    create_config(bambu_path)
    
    print("")
    print("SUCCESS: Setup completed successfully!")
    print("")
    print("To run the pipeline:")
    print("  1. Double-click 'run_pipeline.bat'")
    print("  2. Or run: python simple_slice.py <path_to_your_model.stl>")
    print("")
    print("Example:")
    print("  python simple_slice.py C:\\Users\\YourName\\Desktop\\model.stl")
    print("")
    print("To activate the virtual environment manually:")
    print("  venv\\Scripts\\activate")
    print("")
    print("Troubleshooting:")
    print("  - If Bambu Studio is not found, install it from:")
    print("    https://bambulab.com/en/download/studio")
    print("  - If you get permission errors, run Command Prompt as Administrator")
    print("  - If automation fails, you can manually slice files in Bambu Studio")

if __name__ == "__main__":
    main()
