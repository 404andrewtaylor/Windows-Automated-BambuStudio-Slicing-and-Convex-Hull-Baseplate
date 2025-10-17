on sliceSTL(stlPath)
    -- Check if Bambu Studio is installed and open it
    try
        tell application "BambuStudio" to activate
    on error
        -- If Bambu Studio is not running, try to open it
        try
            tell application "BambuStudio" to launch
            delay 3 -- Wait for Bambu Studio to fully launch
        on error
            display dialog "Error: Bambu Studio not found. Please make sure it's installed in the Applications folder." buttons {"OK"} default button "OK"
            return
        end try
    end try
    
    delay 3
    
    tell application "System Events"
        tell process "BambuStudio"
            keystroke "n" using command down
            delay 2
            
            keystroke "i" using command down
            delay 2
            
            -- Type or paste file path
            keystroke "G" using {shift down, command down}
            delay 1
            keystroke stlPath
            delay 1
            keystroke return
            delay 2
            keystroke return
            
            delay 5 -- wait for import
            
            keystroke "r" using command down -- slice
            delay 30 -- wait for slicing
            
            keystroke "g" using command down -- export
            delay 4
            
            -- Save exported file to same directory as STL
            set stlDir to do shell script "dirname " & quoted form of stlPath
            keystroke stlDir
            delay 2
            keystroke return
            delay 2
            keystroke return
            delay 5
            
            -- Save project file
            keystroke "s" using command down -- save
            delay 4
            keystroke stlDir
            delay 2
            keystroke return
            delay 2
            keystroke return
            delay 5
            
            keystroke "q" using command down -- quit
        end tell
    end tell
end sliceSTL

sliceSTL("/path/to/your/model.stl")
