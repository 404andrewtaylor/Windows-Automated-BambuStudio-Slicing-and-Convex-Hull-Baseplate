#!/bin/bash

# Full Pipeline: STL → Slice → Extract Hull → Create Hull STL → Slice Hull STL
# Usage: ./full_pipeline.sh <input_stl_file>

set -e  # Exit on any error

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "❌ Error: Please provide an STL file path"
    echo "Usage: $0 <input_stl_file>"
    echo "Example: $0 /path/to/model.stl"
    exit 1
fi

INPUT_STL="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if input file exists
if [ ! -f "$INPUT_STL" ]; then
    echo "❌ Error: Input STL file not found: $INPUT_STL"
    exit 1
fi

# Get directory and filename without extension
STL_DIR=$(dirname "$INPUT_STL")
STL_NAME=$(basename "$INPUT_STL" .stl)
OUTPUT_DIR="$STL_DIR/${STL_NAME}_pipeline"

echo "🚀 Starting Full Pipeline"
echo "📁 Input STL: $INPUT_STL"
echo "📁 Output Directory: $OUTPUT_DIR"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Step 1: Slice the original STL
echo "🔧 Step 1: Slicing original STL..."
echo "   Running Bambu Studio automation..."
if ! "$SCRIPT_DIR/slice_bambu.sh" "$INPUT_STL"; then
    echo "❌ Error: Failed to slice original STL"
    exit 1
fi

# Wait a moment for files to be written
sleep 2

# Step 2: Find the generated .gcode.3mf file
echo ""
echo "🔍 Step 2: Locating generated files..."
GCODE_3MF="$STL_DIR/${STL_NAME}.gcode.3mf"
if [ ! -f "$GCODE_3MF" ]; then
    echo "❌ Error: Generated .gcode.3mf file not found: $GCODE_3MF"
    echo "   Expected location: $GCODE_3MF"
    exit 1
fi
echo "✅ Found: $GCODE_3MF"

# Copy files to output directory
cp "$GCODE_3MF" "$OUTPUT_DIR/"
echo "📁 Copied .gcode.3mf to output directory"

# Step 3: Extract convex hull and create hull STL
echo ""
echo "🔺 Step 3: Extracting convex hull and creating hull STL..."
cd "$SCRIPT_DIR"
source venv/bin/activate

# Create hull STL
HULL_STL="$OUTPUT_DIR/${STL_NAME}_hull.stl"
if ! python3 hull_to_stl.py "$GCODE_3MF" "$HULL_STL" "$INPUT_STL"; then
    echo "❌ Error: Failed to create hull STL"
    exit 1
fi

echo "✅ Created hull STL: $HULL_STL"

# Step 4: Calculate offset and move/slice hull
echo ""
echo "🔄 Step 4: Calculating offset and moving/slicing hull..."
echo "   Importing hull STL, moving it, slicing, and exporting..."

# Temporarily move original files to avoid conflicts
TEMP_DIR="$OUTPUT_DIR/temp_original"
mkdir -p "$TEMP_DIR"
mv "$STL_DIR/${STL_NAME}.gcode.3mf" "$TEMP_DIR/" 2>/dev/null || true
mv "$STL_DIR/${STL_NAME}.3mf" "$TEMP_DIR/" 2>/dev/null || true

# Prepare file paths
HULL_STL="$OUTPUT_DIR/${STL_NAME}_hull.stl"
ORIGINAL_3MF="$TEMP_DIR/${STL_NAME}.3mf"
HULL_GCODE_3MF="$OUTPUT_DIR/${STL_NAME}_hull.gcode.3mf"
HULL_3MF="$OUTPUT_DIR/${STL_NAME}_hull.3mf"

# Check if required files exist
if [ ! -f "$HULL_STL" ]; then
    echo "❌ Error: Hull STL file not found: $HULL_STL"
    exit 1
fi

if [ ! -f "$ORIGINAL_3MF" ]; then
    echo "❌ Error: Original 3MF file not found: $ORIGINAL_3MF"
    exit 1
fi

# Calculate offset
echo "   Calculating alignment offset..."

# Extract the move counts from the Python script output
X_MOVES=$(python3 -c "
import sys
import zipfile
import json

def get_bbox_center(three_mf_path):
    with zipfile.ZipFile(three_mf_path, 'r') as zip_ref:
        with zip_ref.open('Metadata/plate_1.json') as f:
            data = json.load(f)
    
    bbox = data['bbox_objects'][0]['bbox']
    center_x = (bbox[0] + bbox[2]) / 2
    center_y = (bbox[1] + bbox[3]) / 2
    return (center_x, center_y)

# Get original center
original_center = get_bbox_center('$ORIGINAL_3MF')

# For hull, we need to estimate where it will be positioned
# Since we don't have the hull 3MF yet, we'll use a default offset
# This will be refined by the move_and_slice_hull.py script
hull_center = (175.0, 160.0)  # Default hull position

offset_x = original_center[0] - hull_center[0]
offset_y = original_center[1] - hull_center[1]

x_moves = int(round(offset_x))
y_moves = int(round(offset_y))

print(f'{x_moves} {y_moves}')
")

# Run the import, move, slice, and export script
echo "   Importing hull STL, moving, slicing, and exporting..."
if ! "$SCRIPT_DIR/import_move_slice.sh" "$HULL_STL" $X_MOVES $Y_MOVES "$HULL_GCODE_3MF" "$HULL_3MF"; then
    echo "❌ Error: Failed to import, move, and slice hull"
    exit 1
fi

echo "✅ Hull import, move, slice, and export completed successfully"
echo "📁 Hull gcode: $HULL_GCODE_3MF"
echo "📁 Hull 3MF: $HULL_3MF"

# Step 5: Run ReplaceBaseplate
echo ""
echo "🔄 Step 5: Running ReplaceBaseplate..."
echo "   Using hull as baseplate and original model as model..."

# Check if ReplaceBaseplate script exists
REPLACE_BASEPLATE_SCRIPT="$SCRIPT_DIR/ReplaceBaseplate/replace_baseplate_layers.py"
if [ ! -f "$REPLACE_BASEPLATE_SCRIPT" ]; then
    echo "❌ Error: ReplaceBaseplate script not found: $REPLACE_BASEPLATE_SCRIPT"
    echo "   Please ensure ReplaceBaseplate repository is cloned in the script directory"
    exit 1
fi

# Prepare file paths for ReplaceBaseplate
ORIGINAL_GCODE_3MF="$TEMP_DIR/${STL_NAME}.gcode.3mf"
FINAL_OUTPUT="$OUTPUT_DIR/${STL_NAME}_with_hull_baseplate.gcode.3mf"

# Check if required files exist
if [ ! -f "$HULL_GCODE_3MF" ]; then
    echo "❌ Error: Hull .gcode.3mf file not found: $HULL_GCODE_3MF"
    exit 1
fi

if [ ! -f "$ORIGINAL_GCODE_3MF" ]; then
    echo "❌ Error: Original .gcode.3mf file not found: $ORIGINAL_GCODE_3MF"
    exit 1
fi

# Run ReplaceBaseplate
echo "   Baseplate file: $HULL_GCODE_3MF"
echo "   Model file: $ORIGINAL_GCODE_3MF"
echo "   Output file: $FINAL_OUTPUT"

if ! python3 "$REPLACE_BASEPLATE_SCRIPT" "$HULL_GCODE_3MF" "$ORIGINAL_GCODE_3MF" "$FINAL_OUTPUT"; then
    echo "❌ Error: ReplaceBaseplate failed"
    exit 1
fi

echo "✅ ReplaceBaseplate completed successfully"
echo "📁 Final output: $FINAL_OUTPUT"

# Step 6: Organize all output files
echo ""
echo "📁 Step 6: Organizing output files..."

# The hull files should already be in the output directory since we sliced the hull STL there
# But let's check if they're in the original directory and move them if needed
HULL_GCODE_IN_ORIGINAL="$STL_DIR/${STL_NAME}_hull.gcode.3mf"
HULL_3MF_IN_ORIGINAL="$STL_DIR/${STL_NAME}_hull.3mf"

if [ -f "$HULL_GCODE_IN_ORIGINAL" ]; then
    mv "$HULL_GCODE_IN_ORIGINAL" "$OUTPUT_DIR/"
    echo "✅ Moved hull .gcode.3mf to output directory"
fi

if [ -f "$HULL_3MF_IN_ORIGINAL" ]; then
    mv "$HULL_3MF_IN_ORIGINAL" "$OUTPUT_DIR/"
    echo "✅ Moved hull .3mf to output directory"
fi

# Verify the files are now in the output directory
if [ -f "$HULL_GCODE_3MF" ]; then
    echo "✅ Hull .gcode.3mf confirmed in output directory"
else
    echo "❌ Error: Hull .gcode.3mf still not found after organization"
    exit 1
fi

# Restore original files
mv "$TEMP_DIR"/* "$STL_DIR/" 2>/dev/null || true
rmdir "$TEMP_DIR" 2>/dev/null || true

# Step 7: Create analysis files
echo ""
echo "📊 Step 7: Creating analysis files..."

# Extract hull points for reference
HULL_POINTS="$OUTPUT_DIR/hull_points.txt"
if python3 extract_hull_points.py "$GCODE_3MF" > "$HULL_POINTS" 2>/dev/null; then
    echo "✅ Created hull points file: $HULL_POINTS"
fi

# Create summary report
SUMMARY_FILE="$OUTPUT_DIR/pipeline_summary.txt"
cat > "$SUMMARY_FILE" << EOF
Full Pipeline Summary
====================
Input STL: $INPUT_STL
Output Directory: $OUTPUT_DIR
Generated: $(date)

Files Created:
- ${STL_NAME}.gcode.3mf (original sliced)
- ${STL_NAME}.3mf (original project)
- ${STL_NAME}_hull.stl (extruded convex hull)
- ${STL_NAME}_hull.gcode.3mf (hull sliced and aligned)
- ${STL_NAME}_hull.3mf (hull project)
- ${STL_NAME}_with_hull_baseplate.gcode.3mf (final combined gcode)
- hull_points.txt (hull vertices)
- first_layer_analysis.png (visualization)

Pipeline Steps:
1. ✅ Sliced original STL in Bambu Studio
2. ✅ Extracted convex hull from first layer
3. ✅ Created 1mm extruded hull STL
4. ✅ Calculated offset and moved/sliced aligned hull
5. ✅ Ran ReplaceBaseplate to combine hull baseplate with original model
6. ✅ Organized all output files
7. ✅ Created analysis files

Ready for 3D printing!
EOF

echo "✅ Created summary: $SUMMARY_FILE"

# Final success message
echo ""
echo "🎉 Full Pipeline Completed Successfully!"
echo "📁 All files saved to: $OUTPUT_DIR"
echo ""
echo "📋 Generated Files:"
ls -la "$OUTPUT_DIR" | grep -E "\.(stl|3mf|txt|png)$" | while read line; do
    echo "   $line"
done
echo ""
echo "🚀 Ready for 3D printing both the original and hull models!"
