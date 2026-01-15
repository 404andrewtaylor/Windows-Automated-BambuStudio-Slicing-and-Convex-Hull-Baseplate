#!/usr/bin/env python3
"""
Simple CLI tool to add a baseplate to a sliced model file.

Usage:
    python add_baseplate.py model.gcode.3mf --baseplate-type multicolor -o output.gcode.3mf
    python add_baseplate.py model.gcode.3mf --baseplate-type single -o output.gcode.3mf
"""

import os
import sys
import argparse
from pathlib import Path


def get_script_directory():
    """Get the directory containing this script."""
    return Path(__file__).parent.absolute()


def get_baseplate_file(baseplate_type, script_dir):
    """
    Get the baseplate file path based on type.
    
    Args:
        baseplate_type: "multicolor" or "single"
        script_dir: Directory where the script is located
        
    Returns:
        tuple: (baseplate_file_path, layers_to_replace)
        
    Raises:
        FileNotFoundError: If baseplate file is not found
        ValueError: If baseplate_type is invalid
    """
    if baseplate_type == "multicolor":
        # Look for multicolor baseplate
        baseplate_path = os.path.join(script_dir, "presliced_multicolour_baseplate.gcode.3mf")
        if not os.path.exists(baseplate_path):
            # Check alternative location
            baseplate_path = os.path.join(script_dir, "presliced_baseplates", "multicolor", 
                                         "presliced_multicolour_baseplate.gcode.3mf")
        layers = 6
    elif baseplate_type == "single":
        # Look for single color baseplate
        baseplate_path = os.path.join(script_dir, "default_colour_baseplate.gcode.3mf")
        layers = 6
    else:
        raise ValueError(f"Invalid baseplate type: {baseplate_type}. Must be 'multicolor' or 'single'")
    
    if not os.path.exists(baseplate_path):
        raise FileNotFoundError(f"Baseplate file not found: {baseplate_path}")
    
    return baseplate_path, layers


def main():
    parser = argparse.ArgumentParser(
        description='Add a baseplate to a sliced model file',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python add_baseplate.py model.gcode.3mf --baseplate-type multicolor -o output.gcode.3mf
  python add_baseplate.py model.gcode.3mf --baseplate-type single -o output.gcode.3mf
        """
    )
    
    parser.add_argument('model_file', help='Input sliced model file (.gcode.3mf)')
    parser.add_argument('--baseplate-type', 
                       choices=['multicolor', 'single'],
                       required=True,
                       help='Type of baseplate to use (multicolor or single)')
    parser.add_argument('-o', '--output',
                       help='Output file path (default: {input}_with_baseplate.gcode.3mf)')
    parser.add_argument('--layers', type=int, default=None,
                       help='Number of layers to replace (default: 6 for both types)')
    
    args = parser.parse_args()
    
    # Validate input file
    if not os.path.exists(args.model_file):
        print(f"[ERROR] Model file not found: {args.model_file}")
        sys.exit(1)
    
    if not args.model_file.endswith('.gcode.3mf'):
        print(f"[ERROR] Model file must be a .gcode.3mf file: {args.model_file}")
        sys.exit(1)
    
    # Get script directory
    script_dir = get_script_directory()
    
    # Get baseplate file
    try:
        baseplate_path, default_layers = get_baseplate_file(args.baseplate_type, script_dir)
        layers = args.layers if args.layers is not None else default_layers
    except FileNotFoundError as e:
        print(f"[ERROR] {e}")
        sys.exit(1)
    except ValueError as e:
        print(f"[ERROR] {e}")
        sys.exit(1)
    
    # Determine output file
    if args.output:
        output_path = os.path.abspath(args.output)
    else:
        # Default: add _with_baseplate before .gcode.3mf
        base_name = os.path.splitext(os.path.splitext(args.model_file)[0])[0]  # Remove .gcode.3mf
        output_path = f"{base_name}_with_baseplate.gcode.3mf"
    
    # Get absolute paths
    model_path = os.path.abspath(args.model_file)
    baseplate_path = os.path.abspath(baseplate_path)
    output_path = os.path.abspath(output_path)
    
    print("=" * 60)
    print("Add Baseplate Tool")
    print("=" * 60)
    print(f"Model file: {model_path}")
    print(f"Baseplate file: {baseplate_path}")
    print(f"Baseplate type: {args.baseplate_type}")
    print(f"Layers to replace: {layers}")
    print(f"Output file: {output_path}")
    print("=" * 60)
    
    # Import ReplaceBaseplate
    replace_baseplate_script = os.path.join(script_dir, "ReplaceBaseplate", "replace_baseplate_layers.py")
    if not os.path.exists(replace_baseplate_script):
        print(f"[ERROR] ReplaceBaseplate script not found: {replace_baseplate_script}")
        sys.exit(1)
    
    # Run ReplaceBaseplate
    import subprocess
    cmd = [sys.executable, replace_baseplate_script, baseplate_path, model_path, output_path, "--layers", str(layers)]
    
    print("\nRunning ReplaceBaseplate...")
    result = subprocess.run(cmd, capture_output=False)
    
    if result.returncode != 0:
        print(f"[ERROR] ReplaceBaseplate failed with exit code {result.returncode}")
        sys.exit(1)
    
    print("\n" + "=" * 60)
    print("[SUCCESS] Baseplate added successfully!")
    print(f"Output file: {output_path}")
    print("=" * 60)


if __name__ == "__main__":
    main()
