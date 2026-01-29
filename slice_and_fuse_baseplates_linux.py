#!/usr/bin/env python3
"""
Linux Pipeline: Slice 4 Most Recent .3mf Files in Downloads, Create Baseplates, and Fuse Them

This script is a Linux-specific variant inspired by williamsikkema's
`slice_and_fuse_baseplates.py`, but it:
- DOES NOT modify or depend on the original Mac-only script.
- Uses `automation_linux.BambuStudioAutomation` for Bambu Studio control.
- Targets Bambu Studio installed as Flatpak (`com.bambulab.BambuStudio`).

Behavior:
- Finds the 4 most recent `.3mf` files in `~/Downloads` (excluding `.gcode.3mf`
  and `_baseplate` files).
- For each:
  1. Slice original `.3mf` → `.gcode.3mf`
  2. Create convex-hull baseplate `.3mf`
  3. Slice baseplate `.3mf` → `.gcode.3mf`
  4. Fuse baseplate onto model → `{name}_with_baseplate.gcode.3mf`
"""

import os
import sys
import subprocess
import time
import platform
import argparse
from pathlib import Path
from datetime import datetime


# Linux-only guard: we don't touch the original Mac pipeline.
if platform.system() != "Linux":
    print("=" * 60)
    print("❌ ERROR: This script is intended for Linux only.")
    print("=" * 60)
    print(f"Detected OS: {platform.system()}")
    sys.exit(1)


# Local imports (Linux automation + baseplate generator)
SCRIPT_DIR = Path(__file__).parent.absolute()
sys.path.insert(0, str(SCRIPT_DIR))

from automation_linux import BambuStudioAutomation  # noqa: E402
from gcode_to_convex_hull_3mf import gcode_to_convex_hull_3mf  # noqa: E402


def find_recent_3mf_files(downloads_dir: Path, count: int = 4):
    """
    Find the N most recent .3mf files in Downloads directory.
    Excludes .gcode.3mf files and *_baseplate.3mf files.
    """
    if not downloads_dir.exists():
        raise FileNotFoundError(f"Downloads directory not found: {downloads_dir}")

    three_mf_files = [
        f for f in downloads_dir.glob("*.3mf")
        if not f.name.endswith(".gcode.3mf")
        and "_baseplate" not in f.name
    ]

    three_mf_files.sort(key=lambda f: f.stat().st_mtime, reverse=True)
    return three_mf_files[:count]


def slice_3mf_file(automation: BambuStudioAutomation, three_mf_path: Path,
                   output_gcode_3mf: Path | None = None, max_retries: int = 3) -> Path | None:
    """
    Slice a .3mf file and return the path to the resulting .gcode.3mf file.
    Skips if output file already exists. Retries with increasing delays.
    """
    three_mf_path = Path(three_mf_path)

    if output_gcode_3mf is None:
        base_name = three_mf_path.stem
        output_gcode_3mf = three_mf_path.parent / f"{base_name}.gcode.3mf"
    else:
        output_gcode_3mf = Path(output_gcode_3mf)

    if output_gcode_3mf.exists():
        print(f"⏭️  Skipping slice - file already exists: {output_gcode_3mf.name}")
        return output_gcode_3mf

    print(f"\n{'=' * 60}")
    print(f"SLICING: {three_mf_path.name}")
    print(f"{'=' * 60}")

    # Ensure Bambu Studio is closed before starting
    print("🔒 Ensuring Bambu Studio is closed before starting...")
    automation.quit_bambu_studio()
    time.sleep(2)

    file_load_delay = 8
    slice_delay = 15

    for attempt in range(max_retries):
        if attempt > 0:
            file_load_delay = int(file_load_delay * 1.5)
            slice_delay = int(slice_delay * 1.5)
            print(
                f"🔄 Retry attempt {attempt + 1}/{max_retries} with delays: "
                f"load={file_load_delay}s, slice={slice_delay}s"
            )

        success = automation.slice_3mf(
            str(three_mf_path),
            str(output_gcode_3mf),
            file_load_delay=file_load_delay,
            slice_delay=slice_delay,
            quit_after=True,  # Close Bambu Studio completely after slicing
        )

        time.sleep(2)

        if success and output_gcode_3mf.exists():
            print(f"✅ Successfully sliced: {output_gcode_3mf.name}")
            return output_gcode_3mf

        print(f"⚠️  Attempt {attempt + 1} failed - file not created")
        if attempt < max_retries - 1:
            print("   Retrying with increased delays...")
            time.sleep(3)

    print(f"❌ Failed to slice after {max_retries} attempts: {three_mf_path.name}")
    return None


def create_baseplate(gcode_3mf_path: Path, output_baseplate_3mf: Path | None = None,
                     n_layers: int = 10, buffer_mm: float = 4.0) -> Path | None:
    """
    Create a convex hull baseplate from a .gcode.3mf file.
    Skips if output file already exists.
    """
    gcode_3mf_path = Path(gcode_3mf_path)

    if output_baseplate_3mf is None:
        base_name = gcode_3mf_path.stem.replace(".gcode", "")
        output_baseplate_3mf = gcode_3mf_path.parent / f"{base_name}_baseplate.3mf"
    else:
        output_baseplate_3mf = Path(output_baseplate_3mf)

    if output_baseplate_3mf.exists():
        print(f"⏭️  Skipping baseplate creation - file already exists: {output_baseplate_3mf.name}")
        return output_baseplate_3mf

    print(f"\n{'=' * 60}")
    print(f"CREATING BASEPLATE: {gcode_3mf_path.name}")
    print(f"{'=' * 60}")

    try:
        blank_template_path = SCRIPT_DIR / "blank_template.3mf"
        if not blank_template_path.exists():
            raise FileNotFoundError(f"blank_template.3mf not found at: {blank_template_path}")

        result_path = gcode_to_convex_hull_3mf(
            input_gcode_3mf=str(gcode_3mf_path),
            output_3mf=str(output_baseplate_3mf),
            n_layers=n_layers,
            buffer_mm=buffer_mm,
            plate_size=180.0,
            hull_height=1.0,
            blank_template_path=str(blank_template_path),
        )

        result_path = Path(result_path)
        if result_path.exists():
            print(f"✅ Successfully created baseplate: {result_path.name}")
            return result_path

        print(f"❌ Baseplate file not found after creation: {result_path}")
        return None

    except Exception as e:
        print(f"❌ Error creating baseplate: {e}")
        import traceback
        traceback.print_exc()
        return None


def slice_baseplate(automation: BambuStudioAutomation, baseplate_3mf_path: Path,
                    output_baseplate_gcode_3mf: Path | None = None,
                    max_retries: int = 3) -> Path | None:
    """
    Slice a baseplate .3mf file to create a .gcode.3mf file.
    Skips if output file already exists. Retries with increasing delays.
    """
    baseplate_3mf_path = Path(baseplate_3mf_path)

    if output_baseplate_gcode_3mf is None:
        base_name = baseplate_3mf_path.stem
        output_baseplate_gcode_3mf = baseplate_3mf_path.parent / f"{base_name}.gcode.3mf"
    else:
        output_baseplate_gcode_3mf = Path(output_baseplate_gcode_3mf)

    if output_baseplate_gcode_3mf.exists():
        print(f"⏭️  Skipping baseplate slice - file already exists: {output_baseplate_gcode_3mf.name}")
        return output_baseplate_gcode_3mf

    print(f"\n{'=' * 60}")
    print(f"SLICING BASEPLATE: {baseplate_3mf_path.name}")
    print(f"{'=' * 60}")

    # Ensure Bambu Studio is closed before starting
    print("🔒 Ensuring Bambu Studio is closed before starting...")
    automation.quit_bambu_studio()
    time.sleep(2)

    file_load_delay = 8
    slice_delay = 5

    for attempt in range(max_retries):
        if attempt > 0:
            file_load_delay = int(file_load_delay * 1.5)
            slice_delay = int(slice_delay * 1.5)
            print(
                f"🔄 Retry attempt {attempt + 1}/{max_retries} with delays: "
                f"load={file_load_delay}s, slice={slice_delay}s"
            )

        success = automation.slice_3mf(
            str(baseplate_3mf_path),
            str(output_baseplate_gcode_3mf),
            file_load_delay=file_load_delay,
            slice_delay=slice_delay,
            quit_after=True,  # Close Bambu Studio after slicing baseplate
            new_project=True,  # Create new project before importing baseplate
        )

        time.sleep(2)

        if success and output_baseplate_gcode_3mf.exists():
            print(f"✅ Successfully sliced baseplate: {output_baseplate_gcode_3mf.name}")
            return output_baseplate_gcode_3mf

        print(f"⚠️  Attempt {attempt + 1} failed - file not created")
        if attempt < max_retries - 1:
            print("   Retrying with increased delays...")
            time.sleep(3)

    print(f"❌ Failed to slice baseplate after {max_retries} attempts: {baseplate_3mf_path.name}")
    return None


def count_layers_in_gcode_3mf(gcode_3mf_path: Path) -> int | None:
    """
    Count the number of layers in a .gcode.3mf file.
    
    Returns:
        Number of layers found, or None if error
    """
    import zipfile
    
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


def fuse_baseplate(baseplate_gcode_3mf: Path, model_gcode_3mf: Path,
                   output_fused_3mf: Path, layers: int = 10) -> Path | None:
    """
    Fuse a baseplate onto a model using ReplaceBaseplate/replace_baseplate_layers.py.
    Skips if output file already exists.
    """
    baseplate_gcode_3mf = Path(baseplate_gcode_3mf)
    model_gcode_3mf = Path(model_gcode_3mf)
    output_fused_3mf = Path(output_fused_3mf)

    if output_fused_3mf.exists():
        print(f"⏭️  Skipping fusion - file already exists: {output_fused_3mf.name}")
        return output_fused_3mf

    print(f"\n{'=' * 60}")
    print(f"FUSING BASEPLATE: {baseplate_gcode_3mf.name} + {model_gcode_3mf.name}")
    print(f"{'=' * 60}")

    replace_script = SCRIPT_DIR / "ReplaceBaseplate" / "replace_baseplate_layers.py"
    if not replace_script.exists():
        alt = SCRIPT_DIR / "baseplate_replacement_tool" / "replace_baseplate_layers.py"
        if alt.exists():
            replace_script = alt
        else:
            print("❌ replace_baseplate_layers.py not found")
            return None

    try:
        result = subprocess.run(
            [
                sys.executable,
                str(replace_script),
                str(baseplate_gcode_3mf),
                str(model_gcode_3mf),
                str(output_fused_3mf),
                "--layers",
                str(layers),
            ],
            capture_output=True,
            text=True,
            check=True,
        )

        if output_fused_3mf.exists():
            print(f"✅ Successfully fused: {output_fused_3mf.name}")
            if result.stdout:
                print(result.stdout)
            return output_fused_3mf

        print("❌ Fusion script completed but output file not found")
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)
        return None

    except subprocess.CalledProcessError as e:
        print(f"❌ Error running replace_baseplate_layers.py: {e}")
        print(e.stdout)
        print(e.stderr)
        return None


def main():
    parser = argparse.ArgumentParser(
        description="Slice 4 most recent .3mf files in Downloads, create baseplates, and fuse them (Linux)"
    )
    parser.add_argument(
        "--cleanup",
        action="store_true",
        help="Delete intermediate files after successful fusion, keeping only original .3mf and final _with_baseplate.gcode.3mf files"
    )
    args = parser.parse_args()

    print("=" * 60)
    print("AUTOMATED BASEPLATE PIPELINE (Linux)")
    print("=" * 60)
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    if args.cleanup:
        print("🧹 Cleanup mode: Will delete intermediate files after successful fusion")
    print("")

    downloads_dir = Path.home() / "Downloads"
    n_files = 4
    n_layers = 10
    buffer_mm = 4.0
    layers_to_replace = 10

    try:
        three_mf_files = find_recent_3mf_files(downloads_dir, count=n_files)
    except FileNotFoundError as e:
        print(f"❌ {e}")
        sys.exit(1)

    if not three_mf_files:
        print("⚠️  No .3mf files found in Downloads.")
        sys.exit(0)

    print("=" * 60)
    print(f"STEP 1: Finding {n_files} most recent .3mf files in Downloads")
    print("=" * 60)
    print(f"Downloads directory: {downloads_dir}")
    print("")
    print(f"Found {len(three_mf_files)} .3mf file(s):")
    for i, f in enumerate(three_mf_files, start=1):
        mtime = datetime.fromtimestamp(f.stat().st_mtime).strftime("%Y-%m-%d %H:%M:%S")
        print(f"  {i}. {f.name} (modified: {mtime})")
    print("")

    automation = BambuStudioAutomation()

    processed_count = 0

    for idx, three_mf in enumerate(three_mf_files, start=1):
        print("#" * 60)
        print(f"PROCESSING FILE {idx}/{len(three_mf_files)}: {three_mf.name}")
        print("#" * 60)

        base_name = three_mf.stem
        model_gcode_3mf = three_mf.parent / f"{base_name}.gcode.3mf"
        baseplate_3mf = three_mf.parent / f"{base_name}_baseplate.3mf"
        baseplate_gcode_3mf = three_mf.parent / f"{base_name}_baseplate.gcode.3mf"
        fused_gcode_3mf = three_mf.parent / f"{base_name}_with_baseplate.gcode.3mf"

        # Step 1: Slice original .3mf
        print("")
        print("[STEP 1/4] Slicing original .3mf file...")
        sliced_gcode_3mf = slice_3mf_file(automation, three_mf, model_gcode_3mf)
        if sliced_gcode_3mf is None:
            print(f"❌ Skipping {three_mf.name} due to slicing failure.")
            continue

        # Step 2: Create baseplate .3mf
        print("")
        print("[STEP 2/4] Creating convex hull baseplate...")
        baseplate_3mf_path = create_baseplate(sliced_gcode_3mf, baseplate_3mf,
                                              n_layers=n_layers, buffer_mm=buffer_mm)
        if baseplate_3mf_path is None:
            print(f"❌ Skipping {three_mf.name} due to baseplate creation failure.")
            continue

        # Step 3: Slice baseplate .3mf
        print("")
        print("[STEP 3/4] Slicing baseplate...")
        baseplate_gcode_3mf_path = slice_baseplate(automation, baseplate_3mf_path, baseplate_gcode_3mf)
        if baseplate_gcode_3mf_path is None:
            print(f"❌ Skipping {three_mf.name} due to baseplate slicing failure.")
            continue

        # Step 4: Fuse baseplate onto model
        print("")
        print("[STEP 4/4] Fusing baseplate onto model...")
        # Count layers in baseplate and use the minimum (like original Mac script)
        baseplate_layers = count_layers_in_gcode_3mf(baseplate_gcode_3mf_path)
        if baseplate_layers:
            actual_layers = min(baseplate_layers, layers_to_replace)
            print(f"   Baseplate has {baseplate_layers} layers, using {actual_layers} for fusion")
        else:
            actual_layers = layers_to_replace
            print(f"   Could not count baseplate layers, using {actual_layers} for fusion")
        
        fused_path = fuse_baseplate(
            baseplate_gcode_3mf_path,
            sliced_gcode_3mf,
            fused_gcode_3mf,
            layers=actual_layers,
        )
        if fused_path is None:
            print(f"❌ Skipping {three_mf.name} due to fusion failure.")
            continue

        # Cleanup intermediate files if requested
        if args.cleanup:
            print("")
            print("🧹 Cleaning up intermediate files...")
            files_to_delete = [
                (sliced_gcode_3mf, "sliced original"),
                (baseplate_3mf_path, "baseplate project"),
                (baseplate_gcode_3mf_path, "sliced baseplate"),
            ]
            for file_path, desc in files_to_delete:
                if file_path.exists():
                    try:
                        file_path.unlink()
                        print(f"   ✅ Deleted {desc}: {file_path.name}")
                    except Exception as e:
                        print(f"   ⚠️  Could not delete {desc} {file_path.name}: {e}")
            print(f"   📁 Kept original: {three_mf.name}")
            print(f"   📁 Kept final output: {fused_path.name}")

        processed_count += 1

        # Small pause between files to avoid overwhelming Bambu Studio
        print("")
        print("Waiting 5 seconds before next file...")
        time.sleep(5)

    # Ensure Bambu Studio is closed at the end
    print("")
    print("🔒 Closing Bambu Studio at end of pipeline...")
    automation.quit_bambu_studio()

    # Summary
    print("")
    print("=" * 60)
    print("PIPELINE SUMMARY (Linux)")
    print("=" * 60)
    print(f"Successfully processed: {processed_count}/{len(three_mf_files)} files")
    print("")

    print("=" * 60)
    print(f"Completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)


if __name__ == "__main__":
    main()

