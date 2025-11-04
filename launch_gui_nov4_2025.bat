@echo off
echo Hull Baseplate Pipeline - GUI Launcher (Nov 4, 2025)
echo =====================================================
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.6 or later from https://python.org
    echo.
    pause
    exit /b 1
)

REM Run the GUI launcher
echo Starting GUI application...
echo (The GUI will automatically set up dependencies if needed)
echo.
python run_gui_nov4_2025.py

REM Keep window open if there was an error
if errorlevel 1 (
    echo.
    echo An error occurred. Check the messages above.
    pause
)

