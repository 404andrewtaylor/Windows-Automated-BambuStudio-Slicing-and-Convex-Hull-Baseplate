#!/usr/bin/env python3
"""
Baseplate Layer Replacement Script - FIXED VERSION

This script replaces the bottom layers of a 3D model with baseplate layers,
creating a solid foundation for printing.

FIXED: Properly cuts off baseplate extraction before shutdown commands.
"""

import os
import sys
import tempfile
import subprocess
import shutil
import re
import argparse
import zipfile
import hashlib
from pathlib import Path

def find_layer_boundaries(gcode_lines):
    """Find the start and end of the actual printing layers in G-code."""
    layer_starts = []
    layer_ends = []
    
    for i, line in enumerate(gcode_lines):
        # Find layer start markers
        if re.search(r'; layer num/total_layer_count: \d+/\d+', line):
            layer_starts.append(i)
        
        # Find the end of printing (before M104 S0 commands)
        if line.strip() == 'M104 S0 T0; turn off hotend':
            layer_ends.append(i)
            break
    
    return layer_starts, layer_ends

def find_baseplate_cutoff(gcode_lines, last_layer_start):
    """Find where to cut off baseplate extraction before shutdown commands."""
    
    # Look for the SKIPPABLE_END marker after the last layer
    for i in range(last_layer_start, len(gcode_lines)):
        if '; SKIPPABLE_END' in gcode_lines[i]:
            return i + 1  # Include the SKIPPABLE_END line
    
    # Fallback: look for "close powerlost recovery"
    for i in range(last_layer_start, len(gcode_lines)):
        if '; close powerlost recovery' in gcode_lines[i]:
            return i  # Cut off before this line
    
    # If neither found, use the original method
    for i in range(last_layer_start, len(gcode_lines)):
        if line.strip() == 'M104 S0 T0; turn off hotend':
            return i
    
    return len(gcode_lines)  # Fallback to end of file

def add_startup_sound_to_gcode(gcode_lines):
    """Add Rick Roll startup sound to G-code."""
    
    # Find where to insert the startup sound
    insert_position = None
    for i, line in enumerate(gcode_lines):
        if line.strip() == 'M17':
            insert_position = i
            break
    
    if insert_position is None:
        # Fallback: look for the first layer change
        for i, line in enumerate(gcode_lines):
            if '; CHANGE_LAYER' in line:
                insert_position = i
                break
    
    if insert_position is None:
        print("Warning: Could not find suitable insertion point for startup sound")
        return gcode_lines
    
    print(f"Adding Rick Roll startup sound at line {insert_position}")
    
    # Create the Rick Roll startup sound code
    startup_sound = [
        ';Never-Gonna-Give-You-Up\n',
        ';music_long: 12.06072\n',
        'M17\n',
        'M400 S1\n',
        'M1006 S1\n',
        'M1006 L70 M70 N99\n',
        ';Tick 226, Time 2 sec\n',
        'M1006 A0 B23 C0 D23 E28 F23 N21 \n',
        'M1006 A0 B2 C0 D2 E0 F2 \n',
        'M1006 A0 B23 C0 D23 E30 F23 N24 \n',
        'M1006 A0 B2 C0 D2 E0 F2 \n',
        'M1006 A0 B76 C0 D76 E28 F75 N21 \n',
        ';Tick 352, Time 3 sec\n',
        'M1006 A0 B11 C0 D11 E21 F11 N38 \n',
        'M1006 A0 B14 C0 D14 E21 F1 N38 \n',
        'M1006 A0 B11 C0 D11 E23 F11 N42 \n',
        'M1006 A0 B14 C0 D14 E23 F1 N42 \n',
        ';Tick 402, Time 4 sec\n',
        'M1006 A50 B37 L69 C18 D37 M24 E30 F37 N24 \n',
        'M1006 A50 B13 L69 C0 D13 E30 F13 N24 \n',
        'M1006 A50 B19 L69 C21 D19 M42 E30 F19 N24 \n',
        'M1006 A0 B4 C21 D4 M42 E30 F4 N24 \n',
        'M1006 A0 B1 C21 D1 M42 E0 F1 \n',
        'M1006 A0 B1 C0 D1 E0 F1 \n',
        'M1006 A52 B24 L52 C16 D24 M35 E28 F24 N21 \n',
        ';Tick 501, Time 5 sec\n',
        'M1006 A52 B45 L52 C0 D46 E28 F46 N21 \n',
        'M1006 A0 B2 C0 D2 E28 F1 N21 \n',
        'M1006 A0 B4 C0 D4 E0 F4 \n',
        'M1006 A45 B11 L69 C0 D11 E21 F11 N38 \n',
        'M1006 A45 B14 L69 C0 D14 E21 F1 N38 \n',
        'M1006 A45 B11 L69 C0 D11 E23 F11 N42 \n',
        'M1006 A45 B10 L69 C0 D10 E23 F1 N42 \n',
        'M1006 A0 B4 C0 D4 E0 F4 \n',
        ';Tick 603, Time 6 sec\n',
        'M1006 A52 B37 L52 C16 D37 M35 E28 F37 N21 \n',
        'M1006 A52 B13 L52 C0 D13 E28 F13 N21 \n',
        'M1006 A52 B19 L52 C16 D19 M35 E28 F19 N21 \n',
        'M1006 A0 B4 C16 D4 M35 E28 F4 N21 \n',
        'M1006 A0 B1 C16 D1 M35 E0 F1 \n',
        'M1006 A0 B1 C0 D1 E0 F1 \n',
        'M1006 A54 B24 L52 C14 D24 M59 E26 F24 N24 \n',
        ';Tick 702, Time 7 sec\n',
        'M1006 A54 B11 L52 C0 D11 E26 F11 N24 \n',
        'M1006 A54 B16 L52 C0 D16 E0 F16 \n',
        'M1006 A54 B18 L52 C0 D19 E23 F19 N42 \n',
        'M1006 A0 B4 C0 D4 E23 F4 N42 \n',
        'M1006 A0 B2 C0 D2 E0 F2 \n',
        'M1006 A57 B11 L69 C0 D11 E21 F11 N38 \n',
        'M1006 A57 B1 L69 C0 D14 E21 F1 N38 \n',
        'M1006 A55 B11 L69 C0 D11 E23 F11 N42 \n',
        'M1006 A55 B1 L69 C0 D14 E23 F1 N42 \n',
        ';Tick 804, Time 8 sec\n',
        'M1006 A50 B46 L69 C0 D46 E26 F46 N24 \n',
        'M1006 A50 B4 L69 C0 D4 E0 F4 \n',
        'M1006 A50 B23 L69 C0 D23 E28 F23 N21 \n',
        'M1006 A50 B2 L69 C0 D2 E0 F2 \n',
        'M1006 A52 B7 L52 C0 D7 E25 F7 N35 \n',
        'M1006 A52 B28 L52 C0 D28 E25 F28 N35 \n',
        ';Tick 914, Time 9 sec\n',
        'M1006 A52 B16 L52 C0 D16 E0 F16 \n',
        'M1006 A52 B18 L52 C0 D19 E21 F19 N38 \n',
        'M1006 A0 B4 C0 D4 E21 F4 N38 \n',
        'M1006 A0 B2 C0 D2 E0 F2 \n',
        'M1006 A45 B23 L69 C0 D23 E21 F23 N38 \n',
        'M1006 A45 B2 L69 C0 D2 E0 F2 \n',
        'M1006 A45 B25 L69 C0 D25 E28 F25 N21 \n',
        ';Tick 1005, Time 10 sec\n',
        'M1006 A45 B37 L69 C25 D37 M35 E28 F37 N21 \n',
        'M1006 A45 B9 L69 C0 D9 E28 F9 N21 \n',
        'M1006 A45 B4 L69 C0 D4 E0 F4 \n',
        'M1006 A45 B69 L69 C23 D69 M31 E26 F69 N24 \n',
        ';Tick 1124, Time 11 sec\n',
        'M1006 A45 B1 L69 C23 D28 M31 E26 F27 N24 \n',
        'M1006 A0 B4 C23 D4 M31 E0 F4 \n',
        'M1006 A57 B11 L69 C23 D11 M31 E21 F11 N38 \n',
        'M1006 A57 B1 L69 C0 D14 E21 F1 N38 \n',
        'M1006 A55 B11 L69 C0 D11 E26 F11 N24 \n',
        'M1006 A55 B1 L69 C0 D14 E26 F1 N24 \n',
        ';Tick 1206, Time 12 sec\n',
        'M1006 A50 B12 L69 C0 D12 E23 F12 N42 \n',
        'M1006 A50 B70 L69 C0 D70 E0 F70 \n',
        'M1006 W\n',
        'M18\n',
        '\n'
    ]
    
    # Insert the startup sound
    return gcode_lines[:insert_position] + startup_sound + gcode_lines[insert_position:]

def extract_gcode_from_3mf(input_3mf, output_gcode):
    """Extract G-code from a 3MF file."""
    
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        
        # Extract the 3MF file using Python's zipfile module
        with zipfile.ZipFile(input_3mf, 'r') as zip_ref:
            zip_ref.extractall(temp_path)
        
        # Find the G-code file
        gcode_file = temp_path / "Metadata" / "plate_1.gcode"
        if not gcode_file.exists():
            raise Exception("Could not find plate_1.gcode in the 3MF file")
        
        # Copy the G-code to output location
        shutil.copy2(gcode_file, output_gcode)

def replace_gcode_in_3mf(input_3mf, modified_gcode, output_3mf):
    """Replace the G-code in a 3MF file with a modified version."""
    
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        
        # Extract the 3MF file using Python's zipfile module
        with zipfile.ZipFile(input_3mf, 'r') as zip_ref:
            zip_ref.extractall(temp_path)
        
        # Find the G-code file
        gcode_file = temp_path / "Metadata" / "plate_1.gcode"
        if not gcode_file.exists():
            raise Exception("Could not find plate_1.gcode in the 3MF file")
        
        # Replace with modified G-code
        shutil.copy2(modified_gcode, gcode_file)
        
        # Update MD5 hash using Python's hashlib
        md5_file = temp_path / "Metadata" / "plate_1.gcode.md5"
        if md5_file.exists():
            with open(gcode_file, 'rb') as f:
                file_hash = hashlib.md5(f.read()).hexdigest()
            with open(md5_file, 'w') as f:
                f.write(file_hash)
        
        # Repackage the 3MF file using Python's zipfile module
        temp_output_name = "output.3mf"
        temp_output_path = temp_path / temp_output_name
        
        with zipfile.ZipFile(temp_output_path, 'w', zipfile.ZIP_DEFLATED) as zip_ref:
            for root, dirs, files in os.walk(temp_path):
                for file in files:
                    if file != temp_output_name:  # Don't include the output file itself
                        file_path = os.path.join(root, file)
                        arcname = os.path.relpath(file_path, temp_path)
                        zip_ref.write(file_path, arcname)
        
        # Move the file to the original directory
        final_output = Path(output_3mf)
        if temp_output_path.exists():
            shutil.move(str(temp_output_path), str(final_output))
        else:
            raise Exception(f"Output file not found at {temp_output}")

def replace_bottom_layers(baseplate_file, nobase_file, output_file, layers_to_replace=5, add_startup_sound=False):
    """Replace the bottom layers of no-base with baseplate layers."""
    
    print(f"Reading baseplate G-code from: {baseplate_file}")
    with open(baseplate_file, 'r') as f:
        baseplate_lines = f.readlines()
    
    print(f"Reading no-base G-code from: {nobase_file}")
    with open(nobase_file, 'r') as f:
        nobase_lines = f.readlines()
    
    # Find layer boundaries
    print("Finding layer boundaries...")
    baseplate_layer_starts, baseplate_layer_ends = find_layer_boundaries(baseplate_lines)
    nobase_layer_starts, nobase_layer_ends = find_layer_boundaries(nobase_lines)
    
    print(f"Baseplate: {len(baseplate_layer_starts)} layers")
    print(f"No-base: {len(nobase_layer_starts)} layers")
    
    if len(baseplate_layer_starts) < layers_to_replace:
        raise Exception(f"Baseplate only has {len(baseplate_layer_starts)} layers, but trying to replace {layers_to_replace}")
    
    if len(nobase_layer_starts) < layers_to_replace:
        raise Exception(f"No-base only has {len(nobase_layer_starts)} layers, but trying to replace {layers_to_replace}")
    
    # Find the proper cutoff point for baseplate (before shutdown commands)
    last_baseplate_layer_start = baseplate_layer_starts[layers_to_replace - 1]
    baseplate_cutoff = find_baseplate_cutoff(baseplate_lines, last_baseplate_layer_start)
    
    print(f"Baseplate cutoff at line {baseplate_cutoff} (before shutdown commands)")
    
    # Extract baseplate printing content (without shutdown commands)
    baseplate_content = baseplate_lines[baseplate_layer_starts[0]:baseplate_cutoff].copy()
    
    # Fix layer numbering in baseplate content to show correct total layers
    print("Fixing layer numbering in baseplate content...")
    for i, line in enumerate(baseplate_content):
        # Fix layer number in comments
        if re.search(r'; layer num/total_layer_count: \d+/\d+', line):
            match = re.search(r'; layer num/total_layer_count: (\d+)/(\d+)', line)
            if match:
                current_layer = int(match.group(1))
                # Update total to match the full model
                baseplate_content[i] = f'; layer num/total_layer_count: {current_layer}/{len(nobase_layer_starts)}\n'
        
        # Fix M73 layer progress commands
        elif re.search(r'M73 L\d+', line):
            match = re.search(r'M73 L(\d+)', line)
            if match:
                current_layer = int(match.group(1))
                # Keep the same layer number
                baseplate_content[i] = re.sub(r'M73 L\d+', f'M73 L{current_layer}', line)
        
        # Fix M991 layer change notifications
        elif re.search(r'M991 S0 P\d+', line):
            match = re.search(r'M991 S0 P(\d+)', line)
            if match:
                current_layer = int(match.group(1))
                # Keep the same layer number
                baseplate_content[i] = re.sub(r'M991 S0 P\d+', f'M991 S0 P{current_layer}', line)
    
    # Remove M73 progress commands from baseplate content to prevent incorrect progress calculation
    print("Removing M73 progress commands from baseplate layers...")
    baseplate_content = [line for line in baseplate_content if not re.search(r'^M73 P\d+', line.strip())]
    
    # Extract no-base header and end
    nobase_header = nobase_lines[:nobase_layer_starts[0]]
    
    # Check if we have layer ends
    if len(nobase_layer_ends) == 0:
        # If no layer end found, use the end of the file
        nobase_end = nobase_lines[nobase_layer_starts[-1]:]
    else:
        nobase_end = nobase_lines[nobase_layer_ends[0]:]
    
    # Extract no-base layers starting from layer 6 (index 5)
    nobase_remaining_start = nobase_layer_starts[layers_to_replace]  # Start from layer 6
    
    # Check if we have layer ends for the remaining content
    if len(nobase_layer_ends) == 0:
        # If no layer end found, use the end of the file
        nobase_remaining_content = nobase_lines[nobase_remaining_start:]
    else:
        nobase_remaining_content = nobase_lines[nobase_remaining_start:nobase_layer_ends[0]]
    
    # Fix layer numbering in remaining no-base content
    print("Fixing layer numbers in remaining no-base content...")
    for i, line in enumerate(nobase_remaining_content):
        # Update layer number in comments
        if re.search(r'; layer num/total_layer_count: \d+/\d+', line):
            match = re.search(r'; layer num/total_layer_count: (\d+)/(\d+)', line)
            if match:
                current_layer = int(match.group(1))
                total_layers = int(match.group(2))
                # Renumber: layer 6 becomes 6, layer 7 becomes 7, etc.
                new_layer = current_layer - layers_to_replace + layers_to_replace
                nobase_remaining_content[i] = f'; layer num/total_layer_count: {new_layer}/{total_layers}\n'
        
        # Update M73 layer progress commands
        elif re.search(r'M73 L\d+', line):
            match = re.search(r'M73 L(\d+)', line)
            if match:
                current_layer = int(match.group(1))
                new_layer = current_layer - layers_to_replace + layers_to_replace
                nobase_remaining_content[i] = re.sub(r'M73 L\d+', f'M73 L{new_layer}', line)
        
        # Update M991 layer change notifications
        elif re.search(r'M991 S0 P\d+', line):
            match = re.search(r'M991 S0 P(\d+)', line)
            if match:
                current_layer = int(match.group(1))
                new_layer = current_layer - layers_to_replace + layers_to_replace
                nobase_remaining_content[i] = re.sub(r'M991 S0 P\d+', f'M991 S0 P{new_layer}', line)
    
    # Combine: header + baseplate + remaining no-base + end
    combined_lines = nobase_header + baseplate_content + nobase_remaining_content + nobase_end
    
    # Add startup sound if requested
    if add_startup_sound:
        print("Adding startup sound...")
        combined_lines = add_startup_sound_to_gcode(combined_lines)
    
    # Write output
    print(f"Writing to: {output_file}")
    with open(output_file, 'w') as f:
        f.writelines(combined_lines)
    
    print(f"[SUCCESS] Success! Created {output_file}")
    print(f"   - Total lines: {len(combined_lines)}")
    print(f"   - Layers 1-{layers_to_replace}: Baseplate (clean, no shutdown commands)")
    print(f"   - Layers {layers_to_replace + 1}-{len(nobase_layer_starts)}: No-base (renumbered)")
    if add_startup_sound:
        print(f"   - Startup sound: Rick Roll")
    
    return True

def main():
    parser = argparse.ArgumentParser(
        description='Replace bottom layers of a 3D model with baseplate layers',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python replace_baseplate_layers_fixed.py baseplate.gcode.3mf model.gcode.3mf output.gcode.3mf
  python replace_baseplate_layers_fixed.py baseplate.gcode.3mf model.gcode.3mf output.gcode.3mf --startup-sound
  python replace_baseplate_layers_fixed.py baseplate.gcode.3mf model.gcode.3mf output.gcode.3mf --layers 3
        """
    )
    
    parser.add_argument('baseplate_3mf', help='Input baseplate 3MF file')
    parser.add_argument('model_3mf', help='Input model 3MF file')
    parser.add_argument('output_3mf', help='Output 3MF file with baseplate layers')
    parser.add_argument('--startup-sound', action='store_true', help='Add Rick Roll startup sound')
    parser.add_argument('--layers', type=int, default=5, help='Number of layers to replace (default: 5)')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    
    args = parser.parse_args()
    
    # Validate input files
    if not os.path.exists(args.baseplate_3mf):
        print(f"Error: Baseplate file '{args.baseplate_3mf}' not found")
        sys.exit(1)
    
    if not os.path.exists(args.model_3mf):
        print(f"Error: Model file '{args.model_3mf}' not found")
        sys.exit(1)
    
    try:
        print("=" * 60)
        print("Baseplate Layer Replacement Process - FIXED VERSION")
        print("=" * 60)
        print(f"Baseplate 3MF: {args.baseplate_3mf}")
        print(f"Model 3MF: {args.model_3mf}")
        print(f"Output 3MF: {args.output_3mf}")
        print(f"Layers to replace: {args.layers}")
        if args.startup_sound:
            print("Startup sound: Rick Roll")
        print("=" * 60)
        
        # Step 1: Extract G-code from both 3MF files
        print("\nStep 1: Extracting G-code from 3MF files...")
        temp_baseplate_gcode = "temp_baseplate.gcode"
        temp_model_gcode = "temp_model.gcode"
        
        extract_gcode_from_3mf(args.baseplate_3mf, temp_baseplate_gcode)
        extract_gcode_from_3mf(args.model_3mf, temp_model_gcode)
        
        # Step 2: Replace bottom layers
        print(f"\nStep 2: Replacing bottom {args.layers} layers...")
        temp_combined_gcode = "temp_combined.gcode"
        replace_bottom_layers(
            temp_baseplate_gcode, 
            temp_model_gcode, 
            temp_combined_gcode, 
            layers_to_replace=args.layers,
            add_startup_sound=args.startup_sound
        )
        
        # Step 3: Repackage into 3MF
        print(f"\nStep 3: Repackaging into 3MF...")
        replace_gcode_in_3mf(args.model_3mf, temp_combined_gcode, args.output_3mf)
        
        # Step 4: Clean up
        print(f"\nStep 4: Cleaning up...")
        for temp_file in [temp_baseplate_gcode, temp_model_gcode, temp_combined_gcode]:
            if os.path.exists(temp_file):
                os.remove(temp_file)
        
        print("\n" + "=" * 60)
        print("[SUCCESS] SUCCESS! Process completed successfully!")
        print("=" * 60)
        print(f"Output file: {args.output_3mf}")
        print(f"File size: {os.path.getsize(args.output_3mf) / (1024*1024):.1f} MB")
        print("\nThe file is ready to print in Bambu Studio!")
        print("It contains:")
        print(f"  - Layers 1-{args.layers}: Baseplate foundation (clean, no shutdown)")
        print(f"  - Layers {args.layers + 1}-N: Original model")
        if args.startup_sound:
            print("  - Rick Roll startup sound")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n[ERROR] ERROR: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
