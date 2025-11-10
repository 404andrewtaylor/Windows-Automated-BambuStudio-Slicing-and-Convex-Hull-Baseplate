@echo off
echo Hull Baseplate Pipeline - Batch Processing CLI (Nov 10, 2025)
echo =============================================================
echo.

REM Check if input folder is provided
if "%~1"=="" (
    echo ERROR: Please provide an input folder path
    echo Usage: batch_process_cli.bat ^<input_folder^>
    echo Example: batch_process_cli.bat "C:\Users\YourName\Documents\STL_Files"
    echo.
    pause
    exit /b 1
)

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.6 or later from https://python.org
    echo.
    pause
    exit /b 1
)

REM Run the CLI script
echo Starting batch processing...
echo (The script will automatically set up dependencies if needed)
echo.
python batch_process_cli.py "%~1"

REM Keep window open if there was an error
if errorlevel 1 (
    echo.
    echo An error occurred. Check the messages above.
    pause
)

