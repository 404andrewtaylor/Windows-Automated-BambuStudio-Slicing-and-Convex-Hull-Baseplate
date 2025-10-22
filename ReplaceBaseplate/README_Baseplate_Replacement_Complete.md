# Baseplate Layer Replacement - Complete Guide

This tool replaces the bottom layers of a 3D model with baseplate layers, creating a solid foundation for printing. Perfect for large prints that need better bed adhesion and reduced warping.

## What This Tool Does

- **Replaces bottom layers** of your 3D model with dense baseplate layers
- **Maintains full model height** and all original features
- **Fixes progress tracking** issues automatically
- **Adds optional startup sound** (Rick Roll)
- **Preserves all print settings** and quality

## Prerequisites

- **Bambu Studio** (or compatible slicer)
- **Python 3.6+**
- **Command line tools**: `unzip`, `zip`, `md5`
- **Two separate G-code files** (see setup below)

## Setup Process

### Step 1: Prepare Your 3D Model

1. **Open your 3D model** in Bambu Studio
2. **Slice normally** with your desired settings
3. **Export as G-code 3MF**: `File → Export → Export Plate → G-code 3MF`
4. **Save as**: `my_model.gcode.3mf`

### Step 2: Create Baseplate

1. **Create a simple baseplate** in your CAD software:
   - **Dimensions**: Same as your model's footprint
   - **Height**: 1-2mm (typically 5 layers at 0.2mm layer height)
   - **Shape**: Rectangle or match your model's outline
   - **No holes or complex geometry** - just a solid base

2. **Import baseplate** into Bambu Studio
3. **Use IDENTICAL settings** as your main model:
   - Same layer height (0.2mm)
   - Same infill percentage (100% recommended)
   - Same print speed
   - Same temperature settings
   - Same filament type

4. **Slice the baseplate** with these settings
5. **Export as G-code 3MF**: `File → Export → Export Plate → G-code 3MF`
6. **Save as**: `my_baseplate.gcode.3mf`

### Step 3: Run the Tool

```bash
python replace_baseplate_layers.py my_baseplate.gcode.3mf my_model.gcode.3mf my_model_with_baseplate.gcode.3mf
```

## Usage Examples

### Basic Usage
```bash
python replace_baseplate_layers.py baseplate.gcode.3mf model.gcode.3mf output.gcode.3mf
```

### With Rick Roll Startup Sound
```bash
python replace_baseplate_layers.py baseplate.gcode.3mf model.gcode.3mf output.gcode.3mf --startup-sound
```

### Custom Layer Count
```bash
python replace_baseplate_layers.py baseplate.gcode.3mf model.gcode.3mf output.gcode.3mf --layers 3
```

### Verbose Output
```bash
python replace_baseplate_layers.py baseplate.gcode.3mf model.gcode.3mf output.gcode.3mf --verbose
```

## What You Get

### Input Files
- **Baseplate 3MF**: 5 layers, ~1mm height, dense infill
- **Model 3MF**: 600+ layers, full model height

### Output File
- **Combined 3MF**: 
  - Layers 1-5: Baseplate foundation
  - Layers 6-N: Original model
  - Total: Same as original model
  - Print time: Same as original model
  - Filament usage: Slightly more due to baseplate

## Benefits

- **Better bed adhesion** - solid foundation prevents lifting
- **Reduced warping** - especially on large prints
- **Easier removal** - baseplate can be cut away
- **Maintains quality** - all original settings preserved
- **Progress tracking** - accurate percentage display
- **One continuous print** - no filament unloading

## Technical Details

### Layer Structure
```
Original Model:     [Layer 1] [Layer 2] [Layer 3] ... [Layer 636]
Baseplate:          [Layer 1] [Layer 2] [Layer 3] [Layer 4] [Layer 5]
Combined Result:    [Base 1]  [Base 2]  [Base 3]  [Base 4]  [Base 5]  [Model 6] ... [Model 636]
```

### File Processing
1. **Extracts G-code** from both 3MF files
2. **Replaces bottom layers** of model with baseplate layers
3. **Fixes layer numbering** for continuity
4. **Removes progress commands** from baseplate (prevents display issues)
5. **Repackages** into new 3MF file
6. **Updates metadata** (MD5 hash, etc.)

### Progress Tracking Fix
- **Problem**: Baseplate layers had M73 progress commands designed for 5-layer prints
- **Solution**: Automatically removes M73 commands from baseplate layers
- **Result**: Accurate progress display throughout entire print

## Startup Sound

The tool includes an optional Rick Roll startup sound that plays when printing begins:

```bash
python replace_baseplate_layers.py baseplate.gcode.3mf model.gcode.3mf output.gcode.3mf --startup-sound
```

**Sound Details:**
- **Duration**: 12 seconds
- **Plays**: Before actual printing begins
- **Can be disabled**: Omit `--startup-sound` flag

## File Structure

```
your_project/
├── replace_baseplate_layers.py          # Main tool
├── README_Baseplate_Replacement_Complete.md  # This documentation
├── my_baseplate.gcode.3mf              # Input: baseplate
├── my_model.gcode.3mf                  # Input: main model
└── my_model_with_baseplate.gcode.3mf   # Output: combined
```

## Troubleshooting

### Common Issues

**"Could not find plate_1.gcode"**
- Solution: Ensure input files are valid Bambu Studio 3MF files

**"Error extracting 3MF"**
- Solution: File is corrupted or not a valid ZIP archive

**"Error repackaging 3MF"**
- Solution: Check disk space and file permissions

**"Printer unloads filament after baseplate"**
- Solution: This is fixed in current version - baseplate layers no longer include shutdown commands

**"Progress shows wrong percentage"**
- Solution: This is fixed in current version - M73 progress commands are automatically removed

### Verification

**Check if it worked:**
1. Open output file in Bambu Studio
2. Verify layer count matches original model
3. Check that first 5 layers are dense baseplate
4. Confirm no shutdown commands between layers 5 and 6

## Success Indicators

**Successful completion shows:**
- "Successfully created combined G-code file"
- "Successfully created: [output_file]"
- File size ~12-13MB (similar to original)
- Can be opened in Bambu Studio

**Verification checklist:**
- Extract G-code and check layer numbers
- Layers 1-5 should be baseplate (dense)
- Layers 6-N should be model (normal density)
- Total layers = original model layers
- No G92 E0 or M104 S0 between layers 5 and 6

## Tips for Best Results

### Baseplate Design
- **Keep it simple** - rectangular or match model outline
- **Use 100% infill** for maximum strength
- **Height**: 1-2mm (5-10 layers at 0.2mm)
- **No overhangs** - keep it flat

### Settings Consistency
- **Use identical settings** for baseplate and model
- **Same layer height** (0.2mm recommended)
- **Same temperature** settings
- **Same print speed** settings
- **Same filament** type

### Print Preparation
- **Clean bed** thoroughly
- **Level bed** properly
- **Use appropriate bed temperature**
- **Consider brim** for extra adhesion

## Workflow Summary

1. **Design your model** in CAD
2. **Create simple baseplate** (1-2mm thick)
3. **Slice model normally** → export as G-code 3MF
4. **Slice baseplate with same settings** → export as G-code 3MF
5. **Run the tool** to combine them
6. **Print the combined file** in Bambu Studio
7. **Remove baseplate** after printing (cut or break away)
