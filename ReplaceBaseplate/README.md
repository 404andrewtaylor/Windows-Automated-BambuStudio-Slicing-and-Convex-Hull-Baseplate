# ReplaceBaseplate

A Python tool that replaces the bottom layers of a 3D model with baseplate layers, creating a solid foundation for printing. Perfect for large prints that need better bed adhesion and reduced warping.

## What This Tool Does

- **Replaces bottom layers** of your 3D model with dense baseplate layers
- **Maintains full model height** and all original features
- **Fixes progress tracking** issues automatically
- **Adds optional startup sound** (Rick Roll)
- **Preserves all print settings** and quality

## Quick Start

```bash
python replace_baseplate_layers.py baseplate.gcode.3mf model.gcode.3mf output.gcode.3mf
```

## Prerequisites

- **Bambu Studio** (or compatible slicer)
- **Python 3.6+**
- **Command line tools**: `unzip`, `zip`, `md5`

## Setup Process

### Step 1: Prepare Your 3D Model
1. **Open your 3D model** in Bambu Studio
2. **Slice normally** with your desired settings
3. **Export as G-code 3MF**: `File → Export → Export Plate → G-code 3MF`
4. **Save as**: `my_model.gcode.3mf`

### Step 2: Create Baseplate
1. **Create a simple baseplate** in your CAD software (1-2mm thick)
2. **Import baseplate** into Bambu Studio
3. **Use IDENTICAL settings** as your main model
4. **Slice the baseplate** with these settings
5. **Export as G-code 3MF**: `File → Export → Export Plate → G-code 3MF`
6. **Save as**: `my_baseplate.gcode.3mf`

### Step 3: Run the Tool
```bash
python replace_baseplate_layers.py my_baseplate.gcode.3mf my_model.gcode.3mf my_model_with_baseplate.gcode.3mf
```

## Complete Documentation

For detailed instructions, troubleshooting, and advanced usage, see [README_Baseplate_Replacement_Complete.md](README_Baseplate_Replacement_Complete.md).

## Benefits

- **Better bed adhesion** - solid foundation prevents lifting
- **Reduced warping** - especially on large prints
- **Easier removal** - baseplate can be cut away
- **Maintains quality** - all original settings preserved
- **Progress tracking** - accurate percentage display
- **One continuous print** - no filament unloading

## Optional Features

### Rick Roll Startup Sound
```bash
python replace_baseplate_layers.py baseplate.gcode.3mf model.gcode.3mf output.gcode.3mf --startup-sound
```

### Custom Layer Count
```bash
python replace_baseplate_layers.py baseplate.gcode.3mf model.gcode.3mf output.gcode.3mf --layers 3
```

## Files

- `replace_baseplate_layers.py` - Main tool
- `README_Baseplate_Replacement_Complete.md` - Complete documentation
- `README.md` - This quick start guide

## Technical Details

The tool:
1. **Extracts G-code** from both 3MF files
2. **Replaces bottom layers** of model with baseplate layers
3. **Fixes layer numbering** for continuity
4. **Removes progress commands** from baseplate (prevents display issues)
5. **Repackages** into new 3MF file
6. **Updates metadata** (MD5 hash, etc.)

## Troubleshooting

- Ensure input files are valid Bambu Studio 3MF files
- Use identical settings for baseplate and model
- Check file permissions and disk space
- Run with `--verbose` for detailed output
