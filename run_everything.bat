@echo off
echo One-Stop STL to Hull Baseplate Pipeline
echo ======================================

if "%~1"=="" (
    echo Usage: run_everything.bat ^<stl_file^>
    echo Example: run_everything.bat C:\path\to\model.stl
    pause
    exit /b 1
)

echo Input STL: %1
echo.

python run_everything.py "%1"

pause
