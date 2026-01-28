#!/usr/bin/env python3
"""
Automated Pipeline: Slice 4 Most Recent .3mf Files, Create Baseplates, and Fuse Them

⚠️  MAC OS ONLY - This script requires Mac OS and uses AppleScript for automation.

This script:
1. Finds the 4 most recent .3mf files in Downloads
2. Slices each one using Bambu Studio automation
3. Creates convex hull baseplates from the sliced .gcode.3mf files
4. Slices the baseplates
5. Fuses the baseplates onto their respective sliced files

Requirements:
- ⚠️  Mac OS ONLY (uses AppleScript automation - automation_mac.py)
- Bambu Studio installed
- Python dependencies: numpy, trimesh, pathlib

Note: The core baseplate generation (gcode_to_convex_hull_3mf.py) is OS-agnostic,
but this pipeline script requires Mac OS for Bambu Studio automation.
"""

import os
import sys
import subprocess
import time
import argparse
import platform
from pathlib import Path
from datetime import datetime

# Check OS - this script is Mac-only
if platform.system() != "Darwin":
    print("="*60)
    print("❌ ERROR: This script requires Mac OS")
    print("="*60)
    print(f"Detected OS: {platform.system()}")
    print("\nThis script uses AppleScript automation which is only available on Mac OS.")
    print("\nNote: The core baseplate generation (gcode_to_convex_hull_3mf.py) is")
    print("OS-agnostic and can be used on Windows/Linux, but this pipeline script")
    print("requires Mac OS for Bambu Studio automation.")
    print("\nWindows support: Not yet implemented (automation_windows.py lacks slice_3mf method)")
    sys.exit(1)

# Add script directory to path for imports
script_dir = Path(__file__).parent.absolute()
sys.path.insert(0, str(script_dir))

from automation_mac import BambuStudioAutomation
from gcode_to_convex_hull_3mf import gcode_to_convex_hull_3mf


def find_recent_3mf_files(downloads_dir, count=4):
    """
    Find the N most recent .3mf files in Downloads directory.
    Excludes .gcode.3mf files and baseplate files.
    
    Args:
        downloads_dir: Path to Downloads directory
        count: Number of files to return (default: 4)
    
    Returns:
        List of Path objects, sorted by modification time (newest first)
    """
    downloads_path = Path(downloads_dir)
    if not downloads_path.exists():
        raise FileNotFoundError(f"Downloads directory not found: {downloads_dir}")
    
    # Find all .3mf files (but not .gcode.3mf files or baseplate files)
    three_mf_files = [
        f for f in downloads_path.glob("*.3mf")
        if not f.name.endswith(".gcode.3mf")
        and "_baseplate" not in f.name
    ]
    
    # Sort by modification time (newest first)
    three_mf_files.sort(key=lambda f: f.stat().st_mtime, reverse=True)
    
    # Return the N most recent
    return three_mf_files[:count]


def slice_3mf_file(automation, three_mf_path, output_gcode_3mf=None, max_retries=3):
    """
    Slice a .3mf file and return the path to the resulting .gcode.3mf file.
    Skips if output file already exists. Retries with increasing delays if file not created.
    
    Args:
        automation: BambuStudioAutomation instance
        three_mf_path: Path to input .3mf file
        output_gcode_3mf: Optional output path (default: same directory, .gcode.3mf extension)
        max_retries: Maximum number of retries with increased delays (default: 3)
    
    Returns:
        Path to created .gcode.3mf file, or None if failed
    """
    three_mf_path = Path(three_mf_path)
    
    if output_gcode_3mf is None:
        # Create output path: same directory, add .gcode before .3mf
        base_name = three_mf_path.stem
        output_gcode_3mf = three_mf_path.parent / f"{base_name}.gcode.3mf"
    else:
        output_gcode_3mf = Path(output_gcode_3mf)
    
    # Check if file already exists
    if output_gcode_3mf.exists():
        print(f"⏭️  Skipping slice - file already exists: {output_gcode_3mf.name}")
        return output_gcode_3mf
    
    print(f"\n{'='*60}")
    print(f"SLICING: {three_mf_path.name}")
    print(f"{'='*60}")
    
    # Initial delays
    file_load_delay = 8
    slice_delay = 15
    
    for attempt in range(max_retries):
        if attempt > 0:
            # Increase delays by 50% each retry
            file_load_delay = int(file_load_delay * 1.5)
            slice_delay = int(slice_delay * 1.5)
            print(f"🔄 Retry attempt {attempt + 1}/{max_retries} with delays: load={file_load_delay}s, slice={slice_delay}s")
        
        # Temporarily modify automation delays (we'll need to pass them)
        success = automation.slice_3mf(str(three_mf_path), str(output_gcode_3mf), 
                                       file_load_delay=file_load_delay, slice_delay=slice_delay)
        
        # Wait a bit for file to be written
        time.sleep(2)
        
        if success and Path(output_gcode_3mf).exists():
            print(f"✅ Successfully sliced: {output_gcode_3mf.name}")
            return Path(output_gcode_3mf)
        else:
            print(f"⚠️  Attempt {attempt + 1} failed - file not created")
            if attempt < max_retries - 1:
                print(f"   Retrying with increased delays...")
                time.sleep(3)  # Brief pause before retry
    
    print(f"❌ Failed to slice after {max_retries} attempts: {three_mf_path.name}")
    return None


def create_baseplate(gcode_3mf_path, output_baseplate_3mf=None, n_layers=10, buffer_mm=4.0):
    """
    Create a convex hull baseplate from a .gcode.3mf file.
    Skips if output file already exists.
    
    Args:
        gcode_3mf_path: Path to input .gcode.3mf file
        output_baseplate_3mf: Optional output path (default: same directory with _baseplate suffix)
        n_layers: Number of bottom layers to analyze (default: 10)
        buffer_mm: Buffer distance in mm (default: 4.0)
    
    Returns:
        Path to created baseplate .3mf file, or None if failed
    """
    gcode_3mf_path = Path(gcode_3mf_path)
    
    if output_baseplate_3mf is None:
        # Create output path: same directory, add _baseplate suffix
        base_name = gcode_3mf_path.stem.replace(".gcode", "")
        output_baseplate_3mf = gcode_3mf_path.parent / f"{base_name}_baseplate.3mf"
    else:
        output_baseplate_3mf = Path(output_baseplate_3mf)
    
    # Check if file already exists
    if output_baseplate_3mf.exists():
        print(f"⏭️  Skipping baseplate creation - file already exists: {output_baseplate_3mf.name}")
        return output_baseplate_3mf
    
    print(f"\n{'='*60}")
    print(f"CREATING BASEPLATE: {gcode_3mf_path.name}")
    print(f"{'='*60}")
    
    try:
        # Get blank_template path
        blank_template_path = script_dir / "blank_template.3mf"
        if not blank_template_path.exists():
            raise FileNotFoundError(f"blank_template.3mf not found at: {blank_template_path}")
        
        result_path = gcode_to_convex_hull_3mf(
            input_gcode_3mf=str(gcode_3mf_path),
            output_3mf=str(output_baseplate_3mf),
            n_layers=n_layers,
            buffer_mm=buffer_mm,
            plate_size=180.0,
            hull_height=1.0,
            blank_template_path=str(blank_template_path)
        )
        
        if Path(result_path).exists():
            print(f"✅ Successfully created baseplate: {Path(result_path).name}")
            return Path(result_path)
        else:
            print(f"❌ Baseplate file not found after creation: {result_path}")
            return None
            
    except Exception as e:
        print(f"❌ Error creating baseplate: {e}")
        import traceback
        traceback.print_exc()
        return None


def slice_baseplate(automation, baseplate_3mf_path, output_baseplate_gcode_3mf=None, max_retries=3):
    """
    Slice a baseplate .3mf file to create a .gcode.3mf file.
    Skips if output file already exists. Retries with increasing delays if file not created.
    
    Args:
        automation: BambuStudioAutomation instance
        baseplate_3mf_path: Path to baseplate .3mf file
        output_baseplate_gcode_3mf: Optional output path
        max_retries: Maximum number of retries with increased delays (default: 3)
    
    Returns:
        Path to created .gcode.3mf file, or None if failed
    """
    baseplate_3mf_path = Path(baseplate_3mf_path)
    
    if output_baseplate_gcode_3mf is None:
        # Create output path: same directory, add .gcode before .3mf
        base_name = baseplate_3mf_path.stem
        output_baseplate_gcode_3mf = baseplate_3mf_path.parent / f"{base_name}.gcode.3mf"
    else:
        output_baseplate_gcode_3mf = Path(output_baseplate_gcode_3mf)
    
    # Check if file already exists
    if output_baseplate_gcode_3mf.exists():
        print(f"⏭️  Skipping baseplate slice - file already exists: {output_baseplate_gcode_3mf.name}")
        return output_baseplate_gcode_3mf
    
    print(f"\n{'='*60}")
    print(f"SLICING BASEPLATE: {baseplate_3mf_path.name}")
    print(f"{'='*60}")
    
    # Initial delays (shorter for baseplates)
    file_load_delay = 8
    slice_delay = 5
    
    for attempt in range(max_retries):
        if attempt > 0:
            # Increase delays by 50% each retry
            file_load_delay = int(file_load_delay * 1.5)
            slice_delay = int(slice_delay * 1.5)
            print(f"🔄 Retry attempt {attempt + 1}/{max_retries} with delays: load={file_load_delay}s, slice={slice_delay}s")
        
        success = automation.slice_3mf(str(baseplate_3mf_path), str(output_baseplate_gcode_3mf),
                                      file_load_delay=file_load_delay, slice_delay=slice_delay, quit_after=False)
        
        # Wait a bit for file to be written
        time.sleep(2)
        
        if success and Path(output_baseplate_gcode_3mf).exists():
            print(f"✅ Successfully sliced baseplate: {Path(output_baseplate_gcode_3mf).name}")
            return Path(output_baseplate_gcode_3mf)
        else:
            print(f"⚠️  Attempt {attempt + 1} failed - file not created")
            if attempt < max_retries - 1:
                print(f"   Retrying with increased delays...")
                time.sleep(3)  # Brief pause before retry
    
    print(f"❌ Failed to slice baseplate after {max_retries} attempts: {baseplate_3mf_path.name}")
    return None


def count_layers_in_gcode_3mf(gcode_3mf_path):
    """
    Count the number of layers in a .gcode.3mf file.
    
    Args:
        gcode_3mf_path: Path to .gcode.3mf file
    
    Returns:
        Number of layers found, or None if error
    """
    import zipfile
    import tempfile
    
    gcode_3mf_path = Path(gcode_3mf_path)
    
    try:
        # Extract G-code from .gcode.3mf
        with zipfile.ZipFile(gcode_3mf_path, 'r') as zip_ref:
            gcode_content = zip_ref.read("Metadata/plate_1.gcode").decode('utf-8')
        
        # Count layers by looking for layer markers
        lines = gcode_content.split('\n')
        layer_count = 0
        for line in lines:
            if line.startswith("; layer num/total_layer_count:"):
                layer_count += 1
        
        return layer_count if layer_count > 0 else None
    except Exception as e:
        print(f"⚠️  Warning: Could not count layers: {e}")
        return None


def fuse_baseplate(baseplate_gcode_3mf, model_gcode_3mf, output_fused_3mf, layers=10):
    """
    Fuse a baseplate onto a model using replace_baseplate_layers.py.
    Skips if output file already exists.
    
    Args:
        baseplate_gcode_3mf: Path to sliced baseplate .gcode.3mf file
        model_gcode_3mf: Path to sliced model .gcode.3mf file
        output_fused_3mf: Path for output fused .gcode.3mf file
        layers: Number of layers to replace (default: 10)
    
    Returns:
        Path to created fused file, or None if failed
    """
    baseplate_gcode_3mf = Path(baseplate_gcode_3mf)
    model_gcode_3mf = Path(model_gcode_3mf)
    output_fused_3mf = Path(output_fused_3mf)
    
    # Check if file already exists
    if output_fused_3mf.exists():
        print(f"⏭️  Skipping fusion - file already exists: {output_fused_3mf.name}")
        return output_fused_3mf
    
    print(f"\n{'='*60}")
    print(f"FUSING BASEPLATE: {baseplate_gcode_3mf.name} + {model_gcode_3mf.name}")
    print(f"{'='*60}")
    
    # Find replace_baseplate_layers.py script
    replace_script = script_dir / "ReplaceBaseplate" / "replace_baseplate_layers.py"
    if not replace_script.exists():
        # Try alternative location
        replace_script = script_dir / "baseplate_replacement_tool" / "replace_baseplate_layers.py"
    
    if not replace_script.exists():
        print(f"❌ replace_baseplate_layers.py not found")
        return None
    
    # Run the replacement script
    try:
        result = subprocess.run(
            [
                sys.executable,
                str(replace_script),
                str(baseplate_gcode_3mf),
                str(model_gcode_3mf),
                str(output_fused_3mf),
                "--layers", str(layers)
            ],
            capture_output=True,
            text=True,
            check=True
        )
        
        if output_fused_3mf.exists():
            print(f"✅ Successfully fused: {output_fused_3mf.name}")
            print(result.stdout)
            return output_fused_3mf
        else:
            print(f"❌ Fused file not found after fusion")
            print(result.stdout)
            print(result.stderr)
            return None
            
    except subprocess.CalledProcessError as e:
        print(f"❌ Error fusing baseplate: {e}")
        print(f"stdout: {e.stdout}")
        print(f"stderr: {e.stderr}")
        return None


def main():
    """Main pipeline execution."""
    parser = argparse.ArgumentParser(
        description='Automated baseplate pipeline: slice 4 most recent .3mf files, create baseplates, and fuse them\n⚠️  MAC OS ONLY - Requires Mac OS and AppleScript automation',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  # Keep all intermediate files
  python slice_and_fuse_baseplates.py
  
  # Delete intermediate files (keep only originals and final outputs)
  python slice_and_fuse_baseplates.py --delete-intermediate

⚠️  Note: This script is Mac OS only. Windows support not yet implemented.
        '''
    )
    parser.add_argument(
        '--delete-intermediate',
        action='store_true',
        help='Delete intermediate files after processing (keeps only original .3mf and final _with_baseplate.gcode.3mf files)'
    )
    
    args = parser.parse_args()
    
    print("="*60)
    print("AUTOMATED BASEPLATE PIPELINE")
    print("="*60)
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    if args.delete_intermediate:
        print("🗑️  Intermediate file deletion: ENABLED")
    else:
        print("📁 Intermediate file deletion: DISABLED (keeping all files)")
    print("="*60)
    
    # Configuration
    downloads_dir = Path.home() / "Downloads"
    n_layers = 10
    buffer_mm = 4.0
    layers_to_replace = 10
    delete_intermediate_files = args.delete_intermediate
    delete_intermediate_files = True  # Set to False to keep all intermediate files
    
    # Initialize automation
    try:
        automation = BambuStudioAutomation()
    except Exception as e:
        print(f"❌ Failed to initialize Bambu Studio automation: {e}")
        sys.exit(1)
    
    # Find 4 most recent .3mf files
    print(f"\n{'='*60}")
    print("STEP 1: Finding 4 most recent .3mf files in Downloads")
    print(f"{'='*60}")
    
    try:
        recent_files = find_recent_3mf_files(downloads_dir, count=4)
    except Exception as e:
        print(f"❌ Error finding .3mf files: {e}")
        sys.exit(1)
    
    if len(recent_files) == 0:
        print("❌ No .3mf files found in Downloads directory")
        sys.exit(1)
    
    print(f"Found {len(recent_files)} .3mf file(s):")
    for i, f in enumerate(recent_files, 1):
        mod_time = datetime.fromtimestamp(f.stat().st_mtime).strftime('%Y-%m-%d %H:%M:%S')
        print(f"  {i}. {f.name} (modified: {mod_time})")
    
    # Process each file
    results = []
    
    for idx, three_mf_file in enumerate(recent_files, 1):
        print(f"\n\n{'#'*60}")
        print(f"PROCESSING FILE {idx}/{len(recent_files)}: {three_mf_file.name}")
        print(f"{'#'*60}")
        
        file_results = {
            'original': three_mf_file,
            'sliced': None,
            'baseplate_3mf': None,
            'baseplate_gcode_3mf': None,
            'fused': None
        }
        
        # Step 1: Slice the original .3mf file
        print(f"\n[STEP 1/{idx}] Slicing original .3mf file...")
        sliced_gcode_3mf = slice_3mf_file(automation, three_mf_file)
        if not sliced_gcode_3mf:
            print(f"⚠️  Skipping {three_mf_file.name} - slicing failed")
            results.append(file_results)
            continue
        file_results['sliced'] = sliced_gcode_3mf
        
        # Step 2: Create baseplate from sliced file
        print(f"\n[STEP 2/{idx}] Creating convex hull baseplate...")
        baseplate_3mf = create_baseplate(
            sliced_gcode_3mf,
            n_layers=n_layers,
            buffer_mm=buffer_mm
        )
        if not baseplate_3mf:
            print(f"⚠️  Skipping {three_mf_file.name} - baseplate creation failed")
            results.append(file_results)
            continue
        file_results['baseplate_3mf'] = baseplate_3mf
        
        # Step 3: Slice the baseplate
        print(f"\n[STEP 3/{idx}] Slicing baseplate...")
        baseplate_gcode_3mf = slice_baseplate(automation, baseplate_3mf)
        if not baseplate_gcode_3mf:
            print(f"⚠️  Skipping {three_mf_file.name} - baseplate slicing failed")
            results.append(file_results)
            continue
        file_results['baseplate_gcode_3mf'] = baseplate_gcode_3mf
        
        # Step 4: Fuse baseplate onto model
        print(f"\n[STEP 4/{idx}] Fusing baseplate onto model...")
        # Count layers in baseplate and use the minimum
        baseplate_layers = count_layers_in_gcode_3mf(baseplate_gcode_3mf)
        if baseplate_layers:
            actual_layers = min(baseplate_layers, layers_to_replace)
            print(f"   Baseplate has {baseplate_layers} layers, using {actual_layers} for fusion")
        else:
            actual_layers = layers_to_replace
            print(f"   Could not count baseplate layers, using {actual_layers} for fusion")
        
        output_fused_name = sliced_gcode_3mf.stem.replace(".gcode", "_with_baseplate.gcode.3mf")
        output_fused = sliced_gcode_3mf.parent / output_fused_name
        fused_file = fuse_baseplate(
            baseplate_gcode_3mf,
            sliced_gcode_3mf,
            output_fused,
            layers=actual_layers
        )
        if not fused_file:
            print(f"⚠️  Skipping {three_mf_file.name} - fusion failed")
            results.append(file_results)
            continue
        file_results['fused'] = fused_file
        
        # Cleanup: Delete intermediate files if option is enabled
        if delete_intermediate_files:
            print(f"\n[CLEANUP] Deleting intermediate files...")
            files_to_delete = []
            if sliced_gcode_3mf.exists():
                files_to_delete.append(sliced_gcode_3mf)
            if baseplate_3mf.exists():
                files_to_delete.append(baseplate_3mf)
            if baseplate_gcode_3mf.exists():
                files_to_delete.append(baseplate_gcode_3mf)
            
            for file_to_delete in files_to_delete:
                try:
                    file_to_delete.unlink()
                    print(f"  🗑️  Deleted: {file_to_delete.name}")
                except Exception as e:
                    print(f"  ⚠️  Could not delete {file_to_delete.name}: {e}")
        
        # Close Bambu Studio after processing this file (will restart for next file)
        if idx < len(recent_files):
            print(f"\n[CLOSE] Closing Bambu Studio before next file...")
            automation.quit_bambu_studio()
            time.sleep(2)  # Brief pause after closing
        
        results.append(file_results)
        
        # Add delay between files to avoid overwhelming Bambu Studio
        if idx < len(recent_files):
            print(f"\n⏳ Waiting 5 seconds before processing next file...")
            time.sleep(5)
    
    # Summary
    print(f"\n\n{'='*60}")
    print("PIPELINE SUMMARY")
    print(f"{'='*60}")
    
    successful = sum(1 for r in results if r['fused'] is not None)
    print(f"Successfully processed: {successful}/{len(results)} files")
    
    for idx, r in enumerate(results, 1):
        print(f"\nFile {idx}: {r['original'].name}")
        print(f"  ✅ Sliced: {r['sliced'].name if r['sliced'] else '❌ Failed'}")
        print(f"  ✅ Baseplate: {r['baseplate_3mf'].name if r['baseplate_3mf'] else '❌ Failed'}")
        print(f"  ✅ Baseplate sliced: {r['baseplate_gcode_3mf'].name if r['baseplate_gcode_3mf'] else '❌ Failed'}")
        print(f"  ✅ Fused: {r['fused'].name if r['fused'] else '❌ Failed'}")
    
    print(f"\n{'='*60}")
    print(f"Completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
