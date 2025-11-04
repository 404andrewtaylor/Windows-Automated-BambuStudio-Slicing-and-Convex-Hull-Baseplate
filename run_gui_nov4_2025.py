#!/usr/bin/env python3
"""
Launcher script for the Hull Baseplate Pipeline GUI Application (Nov 4, 2025 Version).
This script ensures all dependencies are available and launches the GUI.
"""

import sys
import os
import subprocess
from pathlib import Path

def check_basic_dependencies():
    """Check if basic dependencies are available."""
    try:
        import tkinter
        return True
    except ImportError:
        print("ERROR: tkinter not available. This is usually included with Python.")
        return False

def main():
    """Main launcher function."""
    print("Hull Baseplate Pipeline - GUI Launcher (Nov 4, 2025)")
    print("=" * 50)
    
    # Check if we're in the right directory
    script_dir = Path(__file__).parent
    pipeline_script = script_dir / "full_pipeline.py"
    
    if not pipeline_script.exists():
        print("ERROR: full_pipeline.py not found!")
        print("Please run this script from the pipeline directory.")
        input("Press Enter to exit...")
        return
    
    # Check basic dependencies
    print("Checking basic dependencies...")
    if not check_basic_dependencies():
        input("Press Enter to exit...")
        return
    
    print("Basic dependencies found!")
    print("Launching GUI application...")
    print("(The GUI will automatically set up the virtual environment if needed)")
    
    # Launch the GUI
    try:
        from hull_baseplate_gui_nov4_2025 import main as gui_main
        gui_main()
    except Exception as e:
        print(f"Error launching GUI: {e}")
        input("Press Enter to exit...")

if __name__ == "__main__":
    main()

