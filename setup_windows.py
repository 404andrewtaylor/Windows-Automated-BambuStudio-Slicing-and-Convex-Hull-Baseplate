#!/usr/bin/env python3
"""
Windows setup script for STL to Hull Baseplate Pipeline.
This script sets up the Python environment and installs dependencies on Windows.
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

# Windows console encoding fix - replace emojis with text


def check_python():
    """Check if Python 3 is available."""
    try:
        result = subprocess.run([sys.executable, "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"[OK] Python found: {result.stdout.strip()}")
            return True
    except Exception as e:
        print(f"[ERROR] Error checking Python: {e}")
    
    print("[ERROR] Error: Python 3 is not installed or not in PATH")
    print("   Please install Python 3.6 or later from https://python.org")
    return False


def find_bambu_studio():
    """Find Bambu Studio installation on Windows."""
    possible_paths = [
        r"C:\Program Files\BambuStudio\bambu-studio.exe",
        r"C:\Program Files (x86)\BambuStudio\bambu-studio.exe",
        r"C:\Users\{}\AppData\Local\Programs\BambuStudio\bambu-studio.exe".format(os.getenv('USERNAME', '')),
        r"C:\Users\{}\AppData\Local\BambuStudio\bambu-studio.exe".format(os.getenv('USERNAME', '')),
        r"C:\Program Files\Bambu Lab\BambuStudio\bambu-studio.exe",
        r"C:\Program Files (x86)\Bambu Lab\BambuStudio\bambu-studio.exe",
        r"C:\Users\{}\AppData\Local\Bambu Lab\BambuStudio\bambu-studio.exe".format(os.getenv('USERNAME', '')),
    ]
    
    # Try to find in PATH first
    bambu_path = shutil.which("bambu-studio")
    if bambu_path:
        print(f"[OK] Bambu Studio found in PATH: {bambu_path}")
        return bambu_path
    
    # Try to find by checking Start Menu shortcut
    start_menu_path = r"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Bambu Studio"
    if os.path.exists(start_menu_path):
        print(f"[SEARCH] Found Bambu Studio in Start Menu: {start_menu_path}")
        # Look for .lnk files in the Start Menu folder
        for file in os.listdir(start_menu_path):
            if file.endswith('.lnk'):
                # Try to resolve the shortcut to find the actual executable
                try:
                    import win32com.client
                    shell = win32com.client.Dispatch("WScript.Shell")
                    shortcut = shell.CreateShortCut(os.path.join(start_menu_path, file))
                    target_path = shortcut.TargetPath
                    if os.path.exists(target_path) and target_path.endswith('.exe'):
                        print(f"[OK] Bambu Studio found via Start Menu shortcut: {target_path}")
                        return target_path
                except Exception as e:
                    print(f"[WARNING]  Could not resolve Start Menu shortcut: {e}")
                    pass
    
    # Check common installation paths
    for path in possible_paths:
        if os.path.exists(path):
            print(f"[OK] Bambu Studio found: {path}")
            return path
    
    # Try to find by searching for bambu-studio.exe in common locations
    print("[SEARCH] Searching for Bambu Studio executable...")
    search_paths = [
        r"C:\Program Files",
        r"C:\Program Files (x86)",
        os.path.expanduser(r"~\AppData\Local\Programs"),
        os.path.expanduser(r"~\AppData\Local"),
    ]
    
    for search_path in search_paths:
        if os.path.exists(search_path):
            print(f"   Searching in: {search_path}")
            for root, dirs, files in os.walk(search_path):
                if "bambu-studio.exe" in files:
                    exe_path = os.path.join(root, "bambu-studio.exe")
                    if os.path.exists(exe_path):
                        print(f"[OK] Bambu Studio found: {exe_path}")
                        return exe_path
                # Stop searching if we've gone too deep
                if root.count(os.sep) - search_path.count(os.sep) > 3:
                    dirs[:] = []
    
    print("[ERROR] Error: Bambu Studio not found")
    print("   Please install Bambu Studio from https://bambulab.com/en/download/studio")
    print("   Common installation paths checked:")
    for path in possible_paths:
        print(f"     - {path}")
    print("   Also searched in Start Menu and common program directories")
    return None


def create_virtual_environment():
    """Create Python virtual environment."""
    print("[PACKAGE] Creating Python virtual environment...")
    
    try:
        result = subprocess.run([sys.executable, "-m", "venv", "venv"], 
                              capture_output=True, text=True, check=True)
        print("[OK] Virtual environment created successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] Error creating virtual environment: {e}")
        print(f"   stderr: {e.stderr}")
        return False
    except Exception as e:
        print(f"[ERROR] Error creating virtual environment: {e}")
        return False


def get_pip_executable():
    """Get the pip executable path for the virtual environment."""
    if os.name == 'nt':  # Windows
        return os.path.join("venv", "Scripts", "pip.exe")
    else:
        return os.path.join("venv", "bin", "pip")


def get_python_executable():
    """Get the Python executable path for the virtual environment."""
    if os.name == 'nt':  # Windows
        return os.path.join("venv", "Scripts", "python.exe")
    else:
        return os.path.join("venv", "bin", "python")


def install_dependencies():
    """Install Python dependencies."""
    print("[INSTALL] Installing Python dependencies...")
    
    pip_exe = get_pip_executable()
    
    if not os.path.exists(pip_exe):
        print(f"[ERROR] Error: pip not found at {pip_exe}")
        return False
    
    try:
        # Upgrade pip first
        print("   Upgrading pip...")
        result = subprocess.run([pip_exe, "install", "--upgrade", "pip"], 
                              capture_output=True, text=True, check=True)
        
        # Install requirements
        print("   Installing requirements.txt...")
        result = subprocess.run([pip_exe, "install", "-r", "requirements.txt"], 
                              capture_output=True, text=True, check=True)
        
        print("   Installing requirements_stl.txt...")
        result = subprocess.run([pip_exe, "install", "-r", "requirements_stl.txt"], 
                              capture_output=True, text=True, check=True)
        
        print("[OK] Dependencies installed successfully")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] Error installing dependencies: {e}")
        print(f"   stderr: {e.stderr}")
        return False
    except Exception as e:
        print(f"[ERROR] Error installing dependencies: {e}")
        return False


def create_batch_files():
    """Create Windows batch files for easy execution."""
    print("[CREATE] Creating Windows batch files...")
    
    # Create run_pipeline.bat
    batch_content = '''@echo off
echo Starting STL to Hull Baseplate Pipeline...
python run_pipeline_windows.py %*
pause
'''
    
    with open("run_pipeline.bat", "w") as f:
        f.write(batch_content)
    
    # Create setup.bat
    setup_batch_content = '''@echo off
echo Setting up STL to Hull Baseplate Pipeline...
python setup_windows.py
pause
'''
    
    with open("setup.bat", "w") as f:
        f.write(setup_batch_content)
    
    print("[OK] Batch files created:")
    print("   - run_pipeline.bat (run the pipeline)")
    print("   - setup.bat (run setup)")


def create_config_file():
    """Create a configuration file with Bambu Studio path."""
    print("[CONFIG]  Creating configuration file...")
    
    bambu_path = find_bambu_studio()
    
    config = {
        "bambu_studio_path": bambu_path,
        "platform": "Windows",
        "python_executable": get_python_executable(),
        "pip_executable": get_pip_executable()
    }
    
    import json
    with open("config.json", "w") as f:
        json.dump(config, f, indent=2)
    
    print("[OK] Configuration file created: config.json")


def print_usage_instructions():
    """Print usage instructions for Windows users."""
    print("")
    print("[SUCCESS] Setup completed successfully!")
    print("")
    print("To run the pipeline:")
    print("  1. Double-click 'run_pipeline.bat'")
    print("  2. Or run: python full_pipeline.py <path_to_your_model.stl>")
    print("")
    print("Example:")
    print("  python full_pipeline.py C:\\Users\\YourName\\Desktop\\model.stl")
    print("")
    print("To activate the virtual environment manually:")
    print("  venv\\Scripts\\activate")
    print("")
    print("Troubleshooting:")
    print("  - If Bambu Studio is not found, install it from:")
    print("    https://bambulab.com/en/download/studio")
    print("  - If you get permission errors, run Command Prompt as Administrator")
    print("  - If automation fails, you can manually slice files in Bambu Studio")


def main():
    """Main setup function."""
    print("[START] Setting up STL to Hull Baseplate Pipeline for Windows...")
    print("")
    
    # Check Python
    if not check_python():
        sys.exit(1)
    
    # Find Bambu Studio
    bambu_path = find_bambu_studio()
    if not bambu_path:
        print("[WARNING]  Warning: Bambu Studio not found. You can install it later.")
        print("   The pipeline will not work until Bambu Studio is installed.")
        print("")
    
    # Create virtual environment
    if not create_virtual_environment():
        sys.exit(1)
    
    # Install dependencies
    if not install_dependencies():
        sys.exit(1)
    
    # Create batch files
    create_batch_files()
    
    # Create config file
    create_config_file()
    
    # Print usage instructions
    print_usage_instructions()


if __name__ == "__main__":
    main()
