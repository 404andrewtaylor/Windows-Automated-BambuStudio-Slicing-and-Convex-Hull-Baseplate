#!/usr/bin/env python3
"""
Simple slice script that directly uses the automation.
"""

import sys
import os
from pathlib import Path

# Add current directory to path
script_dir = Path(__file__).parent.absolute()
if str(script_dir) not in sys.path:
    sys.path.insert(0, str(script_dir))

def main():
    if len(sys.argv) != 2:
        print("Usage: python simple_slice.py <stl_file>")
        sys.exit(1)
    
    input_stl = sys.argv[1]
    print(f"Starting slice automation for: {input_stl}")
    
    try:
        from automation_windows import slice_stl_file
        result = slice_stl_file(input_stl)
        if result:
            print("SUCCESS: Slice automation completed")
        else:
            print("ERROR: Slice automation failed")
            sys.exit(1)
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
