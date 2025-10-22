#!/bin/bash

# Get the directory of the input STL file
STL_DIR=$(dirname "$1")
export STL_DIR

# Check if Bambu Studio is installed and open it
if [ -d "/Applications/BambuStudio.app" ]; then
    echo "Opening Bambu Studio..."
    open -a "BambuStudio"
    # Wait for Bambu Studio to fully launch
    sleep 3
else
    echo "Error: Bambu Studio not found in Applications folder"
    exit 1
fi

osascript -e "on run argv
    tell application \"BambuStudio\" to activate
    delay 3
    tell application \"System Events\"
        tell process \"BambuStudio\"
            keystroke \"n\" using command down
            delay 0.05
            delay 2
            keystroke \"i\" using command down
            delay 0.05
            delay 2
            keystroke \"G\" using {shift down, command down}
            delay 0.05
            delay 1
            keystroke (item 1 of argv)
            delay 0.05
            delay 1
            keystroke return
            delay 0.05
            delay 2
            keystroke return
            delay 0.05
            delay 5
            keystroke \"r\" using command down
            delay 0.05
            delay 30
            keystroke \"g\" using command down
            delay 0.05
            delay 4
            -- Save exported file to same directory as STL
            set stlDir to do shell script \"dirname \" & quoted form of (item 1 of argv)
            repeat with i from 1 to count of characters of stlDir
                keystroke character i of stlDir
                delay 0.05
            end repeat
            delay 2
            keystroke return
            delay 0.05
            delay 2
            keystroke return
            delay 0.05
            delay 5
            -- Save project file
            keystroke \"s\" using command down
            delay 0.05
            delay 4
            repeat with i from 1 to count of characters of stlDir
                keystroke character i of stlDir
                delay 0.05
            end repeat
            delay 2
            keystroke return
            delay 0.05
            delay 2
            keystroke return
            delay 0.05
            delay 5
            keystroke \"q\" using command down
            delay 0.05
        end tell
    end tell
end run" "$1"

# Wait a bit for Bambu Studio to fully close and files to be written
echo "⏳ Waiting for Bambu Studio to close and files to be written..."
sleep 5

# Call the Python analysis script
echo "🐍 Running first layer analysis..."
python3 "$(dirname "$0")/extract_and_analyze.py" "$1"
