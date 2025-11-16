#!/usr/bin/env python3
"""
Batch Process CLI - Command Line Interface for Simplified Batch Processing (Nov 10, 2025)

A simplified command-line interface that processes all STL files in a folder.
Automatically handles cleanup and file management.

Usage: python batch_process_cli.py <input_folder>
Example: python batch_process_cli.py "C:\Users\YourName\Documents\STL_Files"
"""

import os
import sys
import subprocess
import glob
import shutil
import time
from pathlib import Path
from auto_update import check_for_updates, get_current_version


def get_script_directory():
    """Get the directory containing this script."""
    return Path(__file__).parent.absolute()


def delete_non_stl_files(folder_path):
    """
    Delete all .3mf and .gcode.3mf files from the input folder root.
    Only deletes files directly in the folder, not subdirectories.
    
    Args:
        folder_path: Path to folder to clean
        
    Returns:
        Number of files deleted
    """
    deleted_count = 0
    
    try:
        if not os.path.exists(folder_path):
            print(f"[WARNING] Folder does not exist: {folder_path}")
            return 0
        
        # List all files in folder root
        for filename in os.listdir(folder_path):
            file_path = os.path.join(folder_path, filename)
            
            # Only process files (not directories)
            if os.path.isfile(file_path):
                # Check if file is .3mf or .gcode.3mf
                if filename.lower().endswith('.3mf') or filename.lower().endswith('.gcode.3mf'):
                    try:
                        os.remove(file_path)
                        deleted_count += 1
                        print(f"  Deleted: {filename}")
                    except Exception as e:
                        print(f"  [WARNING] Could not delete {filename}: {e}")
        
        if deleted_count > 0:
            print(f"[OK] Deleted {deleted_count} file(s) from input folder")
        else:
            print("[OK] No .3mf or .gcode.3mf files found to delete")
        
        return deleted_count
        
    except Exception as e:
        print(f"[ERROR] Error deleting files: {e}")
        return deleted_count


def verify_dependencies(venv_python):
    """Verify that critical dependencies are installed in the venv."""
    try:
        venv_pip = os.path.join(os.path.dirname(venv_python), "pip.exe")
        
        # Check if pip exists
        if not os.path.exists(venv_pip):
            print(f"[ERROR] pip.exe not found at {venv_pip}")
            return False
        
        # List of critical packages to check: (package_name, import_test_command)
        # import_test_command is the Python code to test the import
        critical_packages = [
            ("pyautogui", "import pyautogui"),
            ("pydirectinput", "import pydirectinput"),
            ("numpy-stl", "import stl"),  # numpy-stl provides the 'stl' module
        ]
        
        missing_packages = []
        
        # Check each package individually
        for package_name, import_test in critical_packages:
            result = subprocess.run([venv_python, "-c", import_test], 
                                  capture_output=True, text=True, timeout=5)
            if result.returncode != 0:
                missing_packages.append((package_name, import_test))
                print(f"[WARNING] {package_name} module not found or import failed")
                if result.stderr:
                    print(f"  Import error: {result.stderr.strip()}")
        
        # Install any missing packages
        if missing_packages:
            print(f"[INFO] Installing missing packages: {', '.join([p[0] for p in missing_packages])}...")
            failed_installations = []
            
            for package_name, import_test in missing_packages:
                print(f"[INFO] Installing {package_name}...")
                result = subprocess.run([venv_pip, "install", package_name], 
                                     capture_output=True, text=True, timeout=120)
                if result.returncode != 0:
                    print(f"[ERROR] Failed to install {package_name}: {result.stderr}")
                    failed_installations.append(package_name)
                else:
                    # Wait a moment for installation to complete
                    import time
                    time.sleep(1)
                    # Verify installation succeeded by trying to import again
                    verify_result = subprocess.run([venv_python, "-c", import_test], 
                                                  capture_output=True, text=True, timeout=10)
                    if verify_result.returncode == 0:
                        print(f"[OK] Successfully installed and verified {package_name}")
                    else:
                        error_msg = verify_result.stderr.strip() if verify_result.stderr else "Unknown error"
                        print(f"[WARNING] {package_name} installed but import still fails: {error_msg}")
                        failed_installations.append(package_name)
            
            if failed_installations:
                print(f"[ERROR] Failed to install critical packages: {', '.join(failed_installations)}")
                return False
            else:
                print("[OK] All missing packages installed successfully")
                return True
        else:
            print("[OK] All critical dependencies are installed")
            return True
    except subprocess.TimeoutExpired:
        print("[ERROR] Timeout while verifying/installing dependencies")
        return False
    except Exception as e:
        print(f"[WARNING] Could not verify dependencies: {e}")
        return False


def create_virtual_environment(script_dir):
    """Create virtual environment and install dependencies."""
    try:
        print("[INFO] Creating virtual environment...")
        venv_path = os.path.join(script_dir, "venv")
        
        # Create virtual environment
        result = subprocess.run([sys.executable, "-m", "venv", venv_path], 
                              capture_output=True, text=True)
        if result.returncode != 0:
            print(f"[ERROR] Failed to create virtual environment: {result.stderr}")
            return False
        
        print("[OK] Virtual environment created successfully")
        
        # Install dependencies
        print("[INFO] Installing dependencies...")
        venv_python = os.path.join(venv_path, "Scripts", "python.exe")
        venv_pip = os.path.join(venv_path, "Scripts", "pip.exe")
        
        # Install requirements
        requirements_files = ["requirements.txt", "requirements_gui.txt"]
        for req_file in requirements_files:
            if os.path.exists(req_file):
                print(f"[INFO] Installing {req_file}...")
                result = subprocess.run([venv_pip, "install", "-r", req_file], 
                                      capture_output=True, text=True)
                if result.returncode != 0:
                    print(f"[WARNING] Failed to install {req_file}: {result.stderr}")
                else:
                    print(f"[OK] Successfully installed {req_file}")
        
        # Install additional packages (critical for pipeline)
        additional_packages = ["numpy-stl", "pydirectinput", "pyautogui", "pygetwindow", "pywinauto", "pywin32"]
        for package in additional_packages:
            print(f"[INFO] Installing {package}...")
            result = subprocess.run([venv_pip, "install", package], 
                                  capture_output=True, text=True)
            if result.returncode != 0:
                print(f"[WARNING] Failed to install {package}: {result.stderr}")
            else:
                print(f"[OK] Successfully installed {package}")
        
        print("[OK] Dependencies installation completed")
        
        # Verify dependencies after installation (as per developer guide)
        print("[INFO] Verifying installed dependencies...")
        if not verify_dependencies(venv_python):
            print("[WARNING] Some dependencies may not be properly installed")
            # Don't fail here - verification will happen again before processing
        
        return True
        
    except Exception as e:
        print(f"[ERROR] Error creating virtual environment: {str(e)}")
        return False


def get_python_executable(script_dir):
    """Get the appropriate Python executable (create venv if needed)."""
    # Check for virtual environment first
    venv_python = os.path.join(script_dir, "venv", "Scripts", "python.exe")
    if os.path.exists(venv_python):
        print(f"[INFO] Using virtual environment Python: {venv_python}")
        verify_dependencies(venv_python)
        return venv_python
    
    # Check for venv in current directory
    venv_python = os.path.join(os.getcwd(), "venv", "Scripts", "python.exe")
    if os.path.exists(venv_python):
        print(f"[INFO] Using virtual environment Python: {venv_python}")
        verify_dependencies(venv_python)
        return venv_python
    
    # Create virtual environment if it doesn't exist
    print("[INFO] Virtual environment not found. Creating one...")
    if create_virtual_environment(script_dir):
        venv_python = os.path.join(script_dir, "venv", "Scripts", "python.exe")
        if os.path.exists(venv_python):
            print(f"[OK] Using newly created virtual environment: {venv_python}")
            return venv_python
    
    # Fall back to system Python
    print(f"[INFO] Using system Python: {sys.executable}")
    print("[WARNING] Virtual environment not found. Some dependencies may be missing.")
    return sys.executable


def move_output_files(stl_file_path, output_folder_path):
    """Move final output file to the output folder (no intermediate files, no subfolders)."""
    try:
        # Find the generated pipeline folder
        stl_dir = os.path.dirname(stl_file_path)
        stl_name = os.path.splitext(os.path.basename(stl_file_path))[0]
        pipeline_dir = os.path.join(stl_dir, f"{stl_name}_pipeline")
        
        print(f"[MOVE] Looking for pipeline directory: {pipeline_dir}")
        
        if not os.path.exists(pipeline_dir):
            print(f"[ERROR] Pipeline output directory not found: {pipeline_dir}")
            return False
        
        # Find all *_with_hull_baseplate.gcode.3mf files
        import glob
        all_output_files = glob.glob(os.path.join(pipeline_dir, "*_with_hull_baseplate.gcode.3mf"))
        print(f"[MOVE] Looking for output files matching pattern: *_with_hull_baseplate.gcode.3mf")
        print(f"[MOVE] Found {len(all_output_files)} output file(s)")
        
        if not all_output_files:
            print(f"[ERROR] No *_with_hull_baseplate.gcode.3mf files found in {pipeline_dir}")
            # List what files are actually in the pipeline directory
            if os.path.exists(pipeline_dir):
                print(f"[DEBUG] Files in pipeline directory:")
                for f in os.listdir(pipeline_dir):
                    print(f"  - {f}")
            return False
        
        # Place files directly in output folder (no subfolders)
        output_destination = output_folder_path
        os.makedirs(output_destination, exist_ok=True)
        print(f"[MOVE] Output destination: {output_destination}")
        
        # Copy all output files
        copied_count = 0
        for final_output in all_output_files:
            final_filename = os.path.basename(final_output)
            dest_path = os.path.join(output_destination, final_filename)
            
            # Check for filename conflicts
            if os.path.exists(dest_path):
                # Add number suffix to avoid overwriting
                if final_filename.endswith('.gcode.3mf'):
                    base = final_filename[:-10]  # Remove '.gcode.3mf'
                    ext = '.gcode.3mf'
                else:
                    base, ext = os.path.splitext(final_filename)
                counter = 1
                while os.path.exists(dest_path):
                    new_name = f"{base}_{counter}{ext}"
                    dest_path = os.path.join(output_destination, new_name)
                    counter += 1
                print(f"  [WARNING] File exists, renaming to: {os.path.basename(dest_path)}")
            
            print(f"[MOVE] Copying output from {final_output} to {dest_path}")
            shutil.copy2(final_output, dest_path)
            if os.path.exists(dest_path):
                file_size = os.path.getsize(dest_path)
                print(f"  [OK] Output copied to: {dest_path} ({file_size} bytes)")
                copied_count += 1
            else:
                print(f"  [ERROR] Copy failed - destination file does not exist!")
                return False
        
        if copied_count == 0:
            print(f"  [ERROR] No files were successfully copied!")
            return False
        
        # Always copy the log file to output directory
        log_file = os.path.join(pipeline_dir, f"{stl_name}_pipeline_log.txt")
        if os.path.exists(log_file):
            log_dest = os.path.join(output_destination, os.path.basename(log_file))
            print(f"[MOVE] Copying log file from {log_file} to {log_dest}")
            shutil.copy2(log_file, log_dest)
            if os.path.exists(log_dest):
                file_size = os.path.getsize(log_dest)
                print(f"  [OK] Log file copied to: {log_dest} ({file_size} bytes)")
            else:
                print(f"  [WARNING] Log file copy may have failed")
        else:
            print(f"  [WARNING] Log file not found: {log_file}")
        
        # Remove the entire pipeline folder since we only want the final output
        print(f"[MOVE] Removing pipeline directory: {pipeline_dir}")
        try:
            shutil.rmtree(pipeline_dir)
            if not os.path.exists(pipeline_dir):
                print(f"  [OK] Pipeline folder removed successfully")
            else:
                print(f"  [WARNING] Pipeline folder still exists after removal attempt")
        except Exception as e:
            print(f"  [ERROR] Failed to remove pipeline folder: {e}")
            return False
        
        return True
        
    except Exception as e:
        print(f"[ERROR] Error managing output files: {str(e)}")
        import traceback
        traceback.print_exc()
        return False


def process_folder(input_folder):
    """Process all STL files in a folder sequentially."""
    input_folder = os.path.abspath(input_folder)
    
    # Find all STL files in the input folder (remove duplicates - Windows is case-insensitive)
    stl_files = glob.glob(os.path.join(input_folder, "*.stl"))
    stl_files.extend(glob.glob(os.path.join(input_folder, "*.STL")))
    # Remove duplicates
    unique_files = {}
    for f in stl_files:
        normalized = os.path.normpath(os.path.normcase(f))
        if normalized not in unique_files:
            unique_files[normalized] = f
    stl_files = list(unique_files.values())
    stl_files.sort()  # Sort for consistent order
    
    if not stl_files:
        print("[ERROR] No STL files found in the selected folder.")
        return False
    
    total_files = len(stl_files)
    print(f"[INFO] Found {total_files} STL file(s) to process")
    print("=" * 60)
    
    # Check if full_pipeline.py exists
    script_dir = get_script_directory()
    pipeline_script = os.path.join(script_dir, "full_pipeline.py")
    
    if not os.path.exists(pipeline_script):
        print("[ERROR] full_pipeline.py not found in the application directory")
        return False
    
    # Determine which Python to use (prefer virtual environment)
    python_exe = get_python_executable(script_dir)
    
    # Verify dependencies are installed before starting batch processing
    print("[INFO] Verifying dependencies before batch processing...")
    if not verify_dependencies(python_exe):
        print("[ERROR] Critical dependencies are missing. Batch processing may fail.")
        print("[WARNING] Continuing anyway, but pipeline may fail...")
    
    # Generate output folder
    output_folder = os.path.join(input_folder, "slicer_output")
    os.makedirs(output_folder, exist_ok=True)
    print(f"[INFO] Output folder: {output_folder}")
    print("")
    
    successful_files = 0
    failed_files = 0
    
    # Process each file sequentially
    for idx, stl_file in enumerate(stl_files, 1):
        file_name = os.path.basename(stl_file)
        print("")
        print("=" * 60)
        print(f"[PROCESS] Processing file {idx}/{total_files}: {file_name}")
        print("=" * 60)
        
        # Prepare command
        cmd = [python_exe, pipeline_script, stl_file]
        
        print(f"[INFO] Running command: {' '.join(cmd)}")
        
        # Run the pipeline
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            cwd=script_dir
        )
        
        # Read output line by line
        for line in process.stdout:
            line = line.strip()
            if line:
                print(f"  {line}")
        
        # Wait for process to complete
        return_code = process.wait()
        
        if return_code == 0:
            successful_files += 1
            print(f"[OK] Successfully processed: {file_name}")
            
            # Move final output to specified folder (always try, even if pipeline had warnings)
            print(f"[MOVE] Moving output files to: {output_folder}")
            move_success = move_output_files(stl_file, output_folder)
            if not move_success:
                print(f"[WARNING] Failed to move output files for {file_name}")
        else:
            failed_files += 1
            print(f"[ERROR] Failed to process: {file_name} (return code: {return_code})")
            
            # Still try to move files even on failure (in case partial output exists)
            print(f"[MOVE] Attempting to move any output files despite failure...")
            move_output_files(stl_file, output_folder)
    
    # Final summary
    print("")
    print("=" * 60)
    print(f"[SUMMARY] Batch Processing Complete!")
    print(f"  Total files: {total_files}")
    print(f"  Successful: {successful_files}")
    print(f"  Failed: {failed_files}")
    print("=" * 60)
    
    # Only clean up if all files processed successfully
    if failed_files == 0:
        # Delete non-STL files AFTER processing (only if successful)
        print("")
        print("=" * 60)
        print("[CLEANUP] Cleaning input folder (deleting .3mf and .gcode.3mf files)...")
        print("=" * 60)
        delete_non_stl_files(input_folder)
        print("")
        print("[SUCCESS] All files processed successfully!")
        print(f"[INFO] Output files saved to: {output_folder}")
        return True
    else:
        print("")
        print("[WARNING] Some files failed to process.")
        print("[INFO] Input folder was NOT cleaned up due to failures.")
        print(f"[INFO] Output files saved to: {output_folder}")
        return False


def check_updates_command():
    """Handle --check-updates command."""
    print("=" * 60)
    print("Checking for updates...")
    print("=" * 60)
    
    current_version = get_current_version()
    print(f"[INFO] Current version: {current_version}")
    
    result = check_for_updates()
    if result is None:
        print("[ERROR] Failed to check for updates. Please check your internet connection.")
        sys.exit(1)
    
    if result['available']:
        print(f"[INFO] Update available!")
        print(f"[INFO] Latest version: {result['latest_version']}")
        print(f"[INFO] Release name: {result['release_name']}")
        print(f"[INFO] Release notes:")
        print(result.get('release_notes', 'No release notes available.'))
        print("")
        print("[INFO] To update, use the GUI version or download manually from GitHub.")
        print(f"[INFO] Download URL: {result.get('download_url', 'N/A')}")
    else:
        print(f"[INFO] You are running the latest version ({current_version}).")
    
    sys.exit(0)


def main():
    """Main function."""
    # Check for --check-updates flag
    if len(sys.argv) == 2 and sys.argv[1] == "--check-updates":
        check_updates_command()
    
    if len(sys.argv) != 2:
        print("[ERROR] Please provide an input folder path")
        print("Usage: python batch_process_cli.py <input_folder>")
        print("       python batch_process_cli.py --check-updates")
        print("Example: python batch_process_cli.py \"C:\\Users\\YourName\\Documents\\STL_Files\"")
        sys.exit(1)
    
    input_folder = os.path.abspath(sys.argv[1])
    
    # Validate input folder
    if not os.path.exists(input_folder):
        print(f"[ERROR] Input folder does not exist: {input_folder}")
        sys.exit(1)
    
    if not os.path.isdir(input_folder):
        print(f"[ERROR] Input path is not a directory: {input_folder}")
        sys.exit(1)
    
    print("=" * 60)
    print("Hull Baseplate Pipeline - Batch Processing CLI (Nov 10, 2025)")
    print("=" * 60)
    print(f"[INFO] Input folder: {input_folder}")
    print("")
    print("[WARNING] This will delete all .3mf and .gcode.3mf files in the input folder")
    print("[WARNING] This deletion prevents errors when Bambu Studio saves files")
    print("[WARNING] Only .stl files will be preserved in the input folder")
    print("")
    
    # Delete non-STL files BEFORE processing
    print("=" * 60)
    print("[CLEANUP] Cleaning input folder (deleting .3mf and .gcode.3mf files)...")
    print("=" * 60)
    delete_non_stl_files(input_folder)
    print("")
    
    # Process all STL files
    success = process_folder(input_folder)
    
    if success:
        print("[SUCCESS] Batch processing completed successfully!")
        sys.exit(0)
    else:
        print("[ERROR] Batch processing completed with errors.")
        sys.exit(1)


if __name__ == "__main__":
    main()

