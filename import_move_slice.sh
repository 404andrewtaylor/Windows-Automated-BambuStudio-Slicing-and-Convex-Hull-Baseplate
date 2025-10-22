#!/bin/bash

# Import STL, move it, slice it, export gcode, and save project
# Usage: ./import_move_slice.sh <stl_file> <x_moves> <y_moves> <output_gcode_3mf> <output_3mf>

STL_FILE="$1"
X_MOVES="$2"
Y_MOVES="$3"
OUTPUT_GCODE_3MF="$4"
OUTPUT_3MF="$5"

if [ -z "$STL_FILE" ] || [ -z "$X_MOVES" ] || [ -z "$Y_MOVES" ] || [ -z "$OUTPUT_GCODE_3MF" ] || [ -z "$OUTPUT_3MF" ]; then
    echo "Usage: $0 <stl_file> <x_moves> <y_moves> <output_gcode_3mf> <output_3mf>"
    echo "Example: $0 hull.stl 13 7 hull.gcode.3mf hull.3mf"
    exit 1
fi

if [ ! -f "$STL_FILE" ]; then
    echo "❌ Error: STL file not found: $STL_FILE"
    exit 1
fi

echo "🎯 Importing STL, moving, slicing, and exporting..."
echo "📁 STL: $STL_FILE"
echo "📊 X moves: $X_MOVES, Y moves: $Y_MOVES"
echo "📁 Output gcode: $OUTPUT_GCODE_3MF"
echo "📁 Output 3MF: $OUTPUT_3MF"

# Check if Bambu Studio is installed and open it
if [ -d "/Applications/BambuStudio.app" ]; then
    echo "Opening Bambu Studio..."
    open -a "BambuStudio"
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
            -- New project
            keystroke \"n\" using command down
            delay 0.05
            delay 2
            
            -- Import STL
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
            
            -- Select the object
            click at {500, 300}
            delay 0.5
            
            -- Move in X direction
            set xMoves to item 2 of argv as integer
            if xMoves > 0 then
                repeat xMoves times
                    key code 124 using {shift down}  -- Right arrow with Shift
                    delay 0.1
                end repeat
            else if xMoves < 0 then
                repeat (-xMoves) times
                    key code 123 using {shift down}  -- Left arrow with Shift
                    delay 0.1
                end repeat
            end if
            
            -- Move in Y direction (corrected - positive Y goes up)
            set yMoves to item 3 of argv as integer
            if yMoves > 0 then
                repeat yMoves times
                    key code 126 using {shift down}  -- Up arrow with Shift
                    delay 0.1
                end repeat
            else if yMoves < 0 then
                repeat (-yMoves) times
                    key code 125 using {shift down}  -- Down arrow with Shift
                    delay 0.1
                end repeat
            end if
            
            -- Wait for moves to complete
            delay 1
            
            -- Slice
            keystroke \"r\" using command down
            delay 0.05
            delay 30
            
            -- Export gcode
            keystroke \"g\" using command down
            delay 0.05
            delay 4
            -- Save exported file
            set gcodePath to item 4 of argv
            repeat with i from 1 to count of characters of gcodePath
                keystroke character i of gcodePath
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
            set projectPath to item 5 of argv
            repeat with i from 1 to count of characters of projectPath
                keystroke character i of projectPath
                delay 0.05
            end repeat
            delay 2
            keystroke return
            delay 0.05
            delay 2
            keystroke return
            delay 0.05
            delay 5
            
            -- Quit
            keystroke \"q\" using command down
            delay 0.05
        end tell
    end tell
end run" "$STL_FILE" "$X_MOVES" "$Y_MOVES" "$OUTPUT_GCODE_3MF" "$OUTPUT_3MF"

# Wait for Bambu Studio to close and files to be written
echo "⏳ Waiting for Bambu Studio to close and files to be written..."
sleep 5

# Check if files were created
if [ -f "$OUTPUT_GCODE_3MF" ]; then
    echo "✅ G-code 3MF created: $OUTPUT_GCODE_3MF"
else
    echo "❌ Error: G-code 3MF not created: $OUTPUT_GCODE_3MF"
    exit 1
fi

if [ -f "$OUTPUT_3MF" ]; then
    echo "✅ Project 3MF created: $OUTPUT_3MF"
else
    echo "❌ Error: Project 3MF not created: $OUTPUT_3MF"
    exit 1
fi

echo "🎉 Import, move, slice, and export completed successfully!"
