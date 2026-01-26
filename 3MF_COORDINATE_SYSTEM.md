# .3MF File Coordinate System and Printable Zone Reference

## Overview

This document describes the coordinate system and printable zone boundaries for `.3mf` files used with Bambu Studio and 180mm x 180mm build plates.

## Coordinate System

### Origin Location in Generated .3mf Files

**Important**: When creating `.3mf` files from G-code using the convex hull baseplate workflow:

1. **Mesh vertex coordinates** are placed **directly from G-code coordinates** with no transformation
2. **G-code coordinates** use the **front-left corner** as origin `(0, 0)`
3. **Transform matrix** is set to **identity** (`"1 0 0 0 1 0 0 0 1 0 0 0"`), meaning **no translation or rotation**

**Result**: The origin in the generated `.3mf` files is at the **front-left corner** of the build plate, matching the G-code coordinate system.

**Example**:
- If G-code has a point at `(30.5, 45.2)`, the mesh vertex will be at `(30.5, 45.2, 0.0)`
- This point is 30.5mm from the left edge and 45.2mm from the front edge
- The coordinate `(0, 0, 0)` represents the front-left corner of the build plate

**This is NOT center-based**: The origin is NOT at `(90, 90)` (the center of a 180mm plate). It is at `(0, 0)` (the front-left corner).

### Origin Location

The coordinate system origin in `.3mf` files depends on the context:

1. **Mesh Coordinates**: Mesh vertices in the `.3mf` file can use any coordinate system. They are typically defined relative to the model's local origin.

2. **Build Plate Coordinates**: The build plate in Bambu Studio uses a coordinate system where:
   - **Origin (0, 0)**: Typically at the **front-left corner** of the build plate (when viewed from above)
   - **X-axis**: Increases from left to right
   - **Y-axis**: Increases from front to back
   - **Z-axis**: Increases from bottom (build plate surface) upward

### Transform Matrices

Objects in `.3mf` files can be positioned using transform matrices in the `<build><item>` section:

```xml
<item objectid="2" transform="1 0 0 0 1 0 0 0 1 90 90 0" printable="1"/>
```

The transform format is a 16-element matrix in row-major order:
```
a b c d
e f g h
i j k l
m n o p
```

Where:
- Elements `a-i` form a 3x3 rotation matrix
- Elements `m`, `n`, `o` are the X, Y, Z translation (in mm)
- Element `p` is typically 1

**Example**: `transform="1 0 0 0 1 0 0 0 1 90 90 0"` means:
- No rotation (identity matrix)
- Translation: X=90mm, Y=90mm, Z=0mm

## Printable Zone for 180mm x 180mm Build Plate

### Boundaries

For a **180mm x 180mm** build plate, the printable zone is:

- **X-axis**: `[0, 180]` mm (or `[-90, 90]` if centered at origin)
- **Y-axis**: `[0, 180]` mm (or `[-90, 90]` if centered at origin)
- **Z-axis**: `[0, ∞]` mm (Z=0 is the build plate surface)

### Safe Printable Zone

To ensure parts stay within the printable boundaries and account for printer tolerances, it's recommended to use a **margin**:

- **Recommended safe zone**: `[0.5, 179.5]` mm for both X and Y axes
- This provides a 0.5mm margin on all sides

### Coordinate System Variations

Depending on how the model was created and positioned, you may encounter:

1. **Corner-based origin** (0, 0 at front-left):
   - Printable zone: `[0, 180]` x `[0, 180]`
   - Safe zone: `[0.5, 179.5]` x `[0.5, 179.5]`

2. **Center-based origin** (0, 0 at plate center):
   - Printable zone: `[-90, 90]` x `[-90, 90]`
   - Safe zone: `[-89.5, 89.5]` x `[-89.5, 89.5]`

3. **Offset origin** (model-specific positioning):
   - The origin may be offset based on the model's design
   - Always check the actual G-code coordinates to determine the coordinate system

## G-code Coordinate System

### Relationship to .3mf Coordinates

When extracting G-code from `.gcode.3mf` files:

- G-code coordinates represent the **actual printer coordinates**
- These coordinates are in the **printer's coordinate system**, which typically has:
  - Origin at the front-left corner: `(0, 0)`
  - X-axis: left to right `[0, 180]`
  - Y-axis: front to back `[0, 180]`
  - Z-axis: bottom to top `[0, height]`

### Important Notes

1. **G-code coordinates are absolute**: They represent the actual position on the build plate
2. **No transform needed**: When creating a convex hull from G-code coordinates, use them directly
3. **Transform in .3mf**: When creating a `.3mf` file from G-code coordinates, set the build item transform to identity (`"1 0 0 0 1 0 0 0 1 0 0 0"`) to preserve the coordinate system

## Best Practices

### Creating Baseplates from G-code

This section provides a precise, standalone specification for creating convex hull baseplates from `.gcode.3mf` files. Follow these steps exactly to produce properly oriented `.3mf` files.

#### Step 1: Extract G-code Coordinates

**Function**: `extract_gcode_coordinates(gcode_file, n_layers)`

**Process**:
1. Extract `plate_1.gcode` from the `.gcode.3mf` ZIP archive:
   - Path within ZIP: `Metadata/plate_1.gcode`
   - Read file as text, split into lines

2. Parse G-code lines to find layer boundaries:
   
   **Method A (Preferred)**: Look for layer comment markers:
   - Pattern: `; layer num/total_layer_count: N/M`
   - Extract layer number `N` from each match
   - Map layer number to line index
   - For layers 1 through `n_layers`, collect line ranges
   
   **Method B (Fallback)**: Detect Z-axis changes:
   - Parse `G0`/`G1` commands with regex: `([XYZEFS])([-+]?[0-9]*\.?[0-9]+)`
   - Track Z values: when `|Z_new - Z_current| > 0.1mm`, mark new layer
   - Collect first `n_layers` layer ranges

3. Extract XY coordinates from layer ranges:
   - For each line in layer range, parse `G0`/`G1` commands
   - Extract tokens: `X`, `Y`, `E` (extrusion)
   - **Primary method**: Collect points from moves with extrusion:
     - Track previous `E` value
     - If `E_new > E_prev + 1e-8`, this is an extrusion move
     - Use `(X, Y)` from current line, or previous `(X, Y)` if current lacks XY
   - **Fallback method**: If no extrusion points found, collect any `(X, Y)` pairs from `G0`/`G1` moves

4. Return array of (X, Y) coordinate pairs as numpy array or list

**Important**: 
- Use G-code coordinates **directly** - do NOT apply any coordinate transformation
- G-code coordinates are in printer space: origin at front-left corner, X=[0, 180], Y=[0, 180]
- Preserve the exact coordinate values as they appear in the G-code (floating-point precision)

**Output**: Array of (X, Y) points, e.g., `[(30.5, 45.2), (31.1, 45.8), ...]`

#### Step 2: Compute Convex Hull

**Function**: `compute_convex_hull(points)`

**Algorithm**: Monotone Chain (Andrew's algorithm)

**Process**:
1. Remove duplicate points:
   - Round coordinates to 6 decimal places: `(round(x, 6), round(y, 6))`
   - Use set to remove duplicates, convert back to list

2. Sort points lexicographically:
   - Primary sort: by X coordinate
   - Secondary sort: by Y coordinate (for equal X values)
   - Result: sorted list of unique points

3. Build lower hull:
   - Initialize empty list `lower = []`
   - For each point `p` in sorted points:
     - While `len(lower) >= 2` and cross product `cross(lower[-2], lower[-1], p) <= 0`:
       - Remove last point from `lower` (clockwise turn detected)
     - Append `p` to `lower`
   
   Cross product function: `cross(o, a, b) = (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)`
   - Positive: counter-clockwise turn
   - Zero: collinear
   - Negative: clockwise turn

4. Build upper hull:
   - Initialize empty list `upper = []`
   - For each point `p` in **reversed** sorted points:
     - While `len(upper) >= 2` and `cross(upper[-2], upper[-1], p) <= 0`:
       - Remove last point from `upper`
     - Append `p` to `upper`

5. Combine hulls:
   - Remove last point from `lower` and `upper` (duplicate endpoints)
   - Result: `hull = lower[:-1] + upper[:-1]`
   - Points are in counter-clockwise order

**Edge cases**:
- If `len(points) <= 1`: return points as-is
- If `len(points) == 2`: return both points
- If all points collinear: return endpoints

**Output**: Array of (X, Y) points forming the convex hull boundary in counter-clockwise order

#### Step 3: Buffer Hull Outward

**Function**: `buffer_hull(hull_points, buffer_mm)`

**Algorithm**: Uniform scaling from centroid

**Process**:
1. Calculate centroid (geometric center) of hull:
   ```python
   center_x = mean([p[0] for p in hull_points])
   center_y = mean([p[1] for p in hull_points])
   center = (center_x, center_y)
   ```

2. Calculate distance from center to each vertex:
   ```python
   distances = [sqrt((p[0] - center_x)**2 + (p[1] - center_y)**2) for p in hull_points]
   ```

3. Find minimum distance:
   ```python
   min_dist = min(distances)
   ```
   - This is the closest vertex to the center
   - Ensures the buffer guarantee applies to all edges

4. Calculate scale factor:
   ```python
   scale_factor = 1.0 + (buffer_mm / min_dist)
   ```
   - Example: If `min_dist = 20mm` and `buffer_mm = 4mm`, then `scale_factor = 1.2`
   - This scales the closest point from distance `d` to distance `d + buffer_mm`

5. Scale all points outward from center:
   ```python
   buffered_points = []
   for point in hull_points:
       dx = point[0] - center_x
       dy = point[1] - center_y
       new_x = center_x + dx * scale_factor
       new_y = center_y + dy * scale_factor
       buffered_points.append((new_x, new_y))
   ```

**Mathematical guarantee**: 
- Every point on the buffered hull is at least `buffer_mm` away from the original hull edge
- The buffer is uniform in all directions (isotropic scaling)
- The buffered hull maintains the same shape, just larger

**Output**: Array of buffered (X, Y) points in the same order as input

#### Step 4: Clip to Safe Printable Zone

**Function**: `clip_to_safe_zone(hull_points, plate_size=180.0, margin=0.5)`

**Algorithm**: Point-wise clipping followed by convex hull recomputation

**Process**:
1. Define strict clipping bounds:
   ```python
   x_min = margin  # default: 0.5
   x_max = plate_size - margin  # default: 179.5
   y_min = margin  # default: 0.5
   y_max = plate_size - margin  # default: 179.5
   ```

2. Clip each hull point individually:
   ```python
   clipped_points = []
   for point in hull_points:
       x_clipped = max(x_min, min(point[0], x_max))  # clamp to [x_min, x_max]
       y_clipped = max(y_min, min(point[1], y_max))  # clamp to [y_min, y_max]
       clipped_points.append((x_clipped, y_clipped))
   ```

3. Remove duplicate points created by clipping:
   - Round coordinates to 6 decimal places: `(round(x, 6), round(y, 6))`
   - Use set to track seen points
   - Keep only unique points (preserve order)

4. **Critical**: Recompute convex hull of clipped points:
   - Clipping individual points can create concave regions
   - Apply `compute_convex_hull()` again to ensure result is convex
   - This ensures the final hull is valid and doesn't extend beyond bounds

**Validation**:
- After clipping, verify: `all(x_min <= x <= x_max for (x,y) in clipped_hull)`
- Verify: `all(y_min <= y <= y_max for (x,y) in clipped_hull)`

**Output**: Array of clipped (X, Y) points, all guaranteed within `[0.5, 179.5]` x `[0.5, 179.5]`

#### Step 5: Create 3D Mesh from 2D Hull

**Function**: `create_extruded_mesh(hull_points_2d, height=1.0)`

**Algorithm**: Extrude 2D polygon vertically to create watertight 3D mesh

**Process**:
1. **Ensure counter-clockwise winding** (when viewed from above, Z+):
   - Calculate signed area using shoelace formula:
     ```python
     area = 0.0
     n = len(hull_points_2d)
     for i in range(n):
         j = (i + 1) % n
         area += hull_points_2d[i][0] * hull_points_2d[j][1]
         area -= hull_points_2d[j][0] * hull_points_2d[i][1]
     ```
   - If `area < 0`, reverse the point order (points are clockwise)
   - Counter-clockwise order ensures correct face normals

2. **Create vertices**:
   - Bottom layer (Z=0): `vertices_bottom = [(x, y, 0.0) for (x, y) in hull_points_2d]`
   - Top layer (Z=height): `vertices_top = [(x, y, height) for (x, y) in hull_points_2d]`
   - Total vertices: `2 * n` where `n = len(hull_points_2d)`
   - Vertex indices: bottom vertices `[0, n-1]`, top vertices `[n, 2*n-1]`

3. **Create faces** (triangles):
   
   **Bottom face** (normal points down, -Z):
   - Triangulate polygon by fanning from first vertex
   - For `i` in range `[1, n-2]`:
     ```python
     face = [0, i+1, i]  # Reversed order for downward normal
     ```
   - Total bottom faces: `n - 2`
   
   **Top face** (normal points up, +Z):
   - Same triangulation pattern, but at height and correct winding
   - For `i` in range `[1, n-2]`:
     ```python
     face = [n, n+i, n+i+1]  # CCW order for upward normal
     ```
   - Total top faces: `n - 2`
   
   **Side faces** (connect bottom to top):
   - Each edge of the hull becomes a quad, split into 2 triangles
   - For `i` in range `[0, n-1]`:
     ```python
     next_i = (i + 1) % n
     # Triangle 1: bottom current -> bottom next -> top current
     face1 = [i, next_i, i + n]
     # Triangle 2: bottom next -> top next -> top current
     face2 = [next_i, next_i + n, i + n]
     ```
   - Total side faces: `2 * n`

4. **Total face count**: `(n-2) + (n-2) + (2*n) = 4*n - 4` triangles

5. **Verify mesh properties**:
   - Check watertight: each edge shared by exactly 2 faces
   - Check normals: all face normals point outward
   - Check volume: should be positive (use right-hand rule)

**Output**: 3D mesh object with:
- Vertices: `2*n` vertices as `[(x, y, z), ...]`
- Faces: `(4*n - 4)` triangular faces as `[[v1, v2, v3], ...]`
- Properties: watertight, manifold, positive volume

#### Step 6: Convert Mesh to .3mf File

**Function**: `mesh_to_3mf(mesh, output_path, blank_template_path, transform="1 0 0 0 1 0 0 0 1 0 0 0")`

**Process**:
1. **Extract blank template**:
   - `blank_template.3mf` is a ZIP archive
   - Extract to temporary directory
   - Required file: `3D/3dmodel.model` (XML file)

2. **Parse XML model file**:
   - Use XML parser (e.g., `xml.etree.ElementTree`)
   - Register namespaces:
     ```python
     NS = "http://schemas.microsoft.com/3dmanufacturing/core/2015/02"
     ET.register_namespace('', NS)
     ET.register_namespace('BambuStudio', 'http://schemas.bambulab.com/package/2021')
     ```

3. **Locate mesh element**:
   - Find `<resources>` element
   - Find `<object>` element (typically `id="1"`)
   - Find or create `<mesh>` element within object
   - Find or create `<vertices>` and `<triangles>` elements within mesh

4. **Clear existing geometry**:
   - Remove all child elements from `<vertices>` and `<triangles>`

5. **Add vertices to XML**:
   ```xml
   <vertex x="X" y="Y" z="Z"/>
   ```
   - For each mesh vertex `(x, y, z)`:
     ```python
     vertex_elem = ET.SubElement(vertices_elem, 'vertex')
     vertex_elem.set('x', str(x))
     vertex_elem.set('y', str(y))
     vertex_elem.set('z', str(z))
     ```
   - Use exact mesh coordinates (no transformation)
   - Preserve floating-point precision

6. **Add triangles to XML**:
   ```xml
   <triangle v1="0" v2="1" v3="2"/>
   ```
   - For each mesh face `[v1, v2, v3]`:
     ```python
     triangle_elem = ET.SubElement(triangles_elem, 'triangle')
     triangle_elem.set('v1', str(int(v1)))
     triangle_elem.set('v2', str(int(v2)))
     triangle_elem.set('v3', str(int(v3)))
     ```
   - Use 0-based vertex indices
   - Convert to integers (indices, not coordinates)

7. **Set build item transform** (CRITICAL):
   - Find `<build>` element
   - Find or create `<item>` element
   - Set transform attribute:
     ```xml
     <item objectid="2" transform="1 0 0 0 1 0 0 0 1 0 0 0" printable="1"/>
     ```
   - Format: `"a b c d e f g h i j k l m n o p"` (16 space-separated numbers)
   - Identity transform: `"1 0 0 0 1 0 0 0 1 0 0 0"`
     - Rotation matrix: `[[1,0,0], [0,1,0], [0,0,1]]` (no rotation)
     - Translation: `(0, 0, 0)` (no offset)
   - **This preserves G-code coordinates exactly**

8. **Update metadata**:
   - File: `Metadata/model_settings.config`
   - Update `face_count` to match number of triangles
   - Update in all relevant locations:
     - `<metadata[@face_count]>` attributes
     - `<metadata[@key="face_count"]>` elements
     - `<mesh_stat>` elements

9. **Write XML**:
   ```python
   tree.write(model_path, encoding='utf-8', xml_declaration=True, method='xml')
   ```

10. **Repackage ZIP**:
    - Create new ZIP archive
    - Add all files from temp directory
    - Use `ZIP_DEFLATED` compression
    - Save as `.3mf` file

**Transform Matrix Format**:
```
Row-major 4x4 matrix:
[a  b  c  d ]   [1  0  0  0 ]   Rotation  Translation
[e  f  g  h ] = [0  1  0  0 ]   Matrix    Vector
[i  j  k  l ]   [0  0  1  0 ]
[m  n  o  p ]   [0  0  0  1 ]
```

For identity: `"1 0 0 0 1 0 0 0 1 0 0 0"` (last 4 elements are translation: 0,0,0,1)

**Output**: `.3mf` file with mesh positioned exactly as specified by coordinates

### Complete Standalone Specification

This section provides exact function signatures and implementation requirements for creating convex hull baseplates.

#### Function Signatures

```python
def extract_gcode_coordinates(gcode_3mf_path: str, n_layers: int = 10) -> List[Tuple[float, float]]:
    """
    Extract XY coordinates from bottom N layers of .gcode.3mf file.
    
    Returns:
        List of (X, Y) coordinate pairs in printer space (no transformation applied)
    """

def compute_convex_hull(points: List[Tuple[float, float]]) -> List[Tuple[float, float]]:
    """
    Compute convex hull using monotone chain algorithm.
    
    Returns:
        List of (X, Y) points forming convex hull boundary in counter-clockwise order
    """

def buffer_hull(hull_points: List[Tuple[float, float]], buffer_mm: float) -> List[Tuple[float, float]]:
    """
    Buffer hull outward by uniform scaling from centroid.
    
    Returns:
        List of buffered (X, Y) points in same order as input
    """

def clip_to_safe_zone(hull_points: List[Tuple[float, float]], 
                      plate_size: float = 180.0, 
                      margin: float = 0.5) -> List[Tuple[float, float]]:
    """
    Clip hull to safe printable zone [margin, plate_size-margin] for both axes.
    
    Returns:
        List of clipped (X, Y) points, all within [margin, plate_size-margin]
    """

def create_extruded_mesh(hull_points_2d: List[Tuple[float, float]], 
                         height: float = 1.0) -> Mesh3D:
    """
    Create watertight 3D mesh by extruding 2D hull vertically.
    
    Returns:
        Mesh3D object with:
        - vertices: List[Tuple[float, float, float]]  # (x, y, z)
        - faces: List[Tuple[int, int, int]]  # (v1, v2, v3) vertex indices
    """

def mesh_to_3mf(mesh: Mesh3D, 
                output_path: str, 
                blank_template_path: str,
                transform: str = "1 0 0 0 1 0 0 0 1 0 0 0") -> str:
    """
    Convert 3D mesh to .3mf file format.
    
    Args:
        mesh: Mesh3D object with vertices and faces
        output_path: Path where .3mf file will be created
        blank_template_path: Path to blank_template.3mf file (required)
        transform: Transform matrix string (default: identity)
    
    Returns:
        Path to created .3mf file
    """
```

#### Main Function

```python
def create_convex_hull_baseplate(gcode_3mf_path: str, 
                                 output_3mf_path: str, 
                                 n_layers: int = 10, 
                                 buffer_mm: float = 4.0, 
                                 plate_size: float = 180.0, 
                                 margin: float = 0.5, 
                                 hull_height: float = 1.0, 
                                 blank_template_path: str = None) -> str:
    """
    Standalone function to create convex hull baseplate from .gcode.3mf
    
    Complete workflow:
    1. Extract G-code coordinates (no transformation)
    2. Compute convex hull
    3. Buffer outward
    4. Clip to safe zone
    5. Create 3D mesh
    6. Convert to .3mf with identity transform
    
    Args:
        gcode_3mf_path: Path to input .gcode.3mf file
        output_3mf_path: Path to output .3mf file
        n_layers: Number of bottom layers to analyze
        buffer_mm: Buffer distance in mm
        plate_size: Build plate size in mm
        margin: Safety margin from plate edges in mm
        hull_height: Extrusion height in mm
        blank_template_path: Path to blank_template.3mf (required)
    
    Returns:
        Path to created .3mf file
    
    Raises:
        FileNotFoundError: If input file or blank_template.3mf not found
        ValueError: If insufficient points or invalid geometry
    """
    # Step 1: Extract G-code coordinates (no transformation)
    points_2d = extract_gcode_coordinates(gcode_3mf_path, n_layers)
    
    if len(points_2d) < 3:
        raise ValueError(f"Insufficient points extracted: {len(points_2d)}")
    
    # Step 2: Compute convex hull
    hull_2d = compute_convex_hull(points_2d)
    
    # Step 3: Buffer outward
    buffered_hull = buffer_hull(hull_2d, buffer_mm)
    
    # Step 4: Clip to safe zone [margin, plate_size-margin]
    clipped_hull = clip_to_safe_zone(buffered_hull, plate_size, margin)
    
    # Step 5: Create 3D mesh
    mesh_3d = create_extruded_mesh(clipped_hull, hull_height)
    
    # Step 6: Convert to .3mf with identity transform
    if blank_template_path is None:
        raise ValueError("blank_template_path is required")
    
    mesh_to_3mf(mesh_3d, output_3mf_path, blank_template_path, 
                transform="1 0 0 0 1 0 0 0 1 0 0 0")
    
    return output_3mf_path
```

### XML Structure and Namespace Handling

When modifying `3D/3dmodel.model`, proper namespace handling is critical:

#### Required Namespaces

```python
NS_CORE = "http://schemas.microsoft.com/3dmanufacturing/core/2015/02"
NS_BAMBU = "http://schemas.bambulab.com/package/2021"

# Register namespaces before parsing
ET.register_namespace('', NS_CORE)
ET.register_namespace('BambuStudio', NS_BAMBU)
```

#### XML Element Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<model unit="millimeter" xml:lang="en-US" 
       xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" 
       xmlns:BambuStudio="http://schemas.bambulab.com/package/2021">
  <resources>
    <object id="1" type="model">
      <mesh>
        <vertices>
          <vertex x="X" y="Y" z="Z"/>
          <!-- ... more vertices ... -->
        </vertices>
        <triangles>
          <triangle v1="0" v2="1" v3="2"/>
          <!-- ... more triangles ... -->
        </triangles>
      </mesh>
    </object>
    <object id="2" type="model">
      <components>
        <component objectid="1" transform="1 0 0 0 1 0 0 0 1 0 0 0"/>
      </components>
    </object>
  </resources>
  <build>
    <item objectid="2" transform="1 0 0 0 1 0 0 0 1 0 0 0" printable="1"/>
  </build>
</model>
```

#### Finding Elements (Namespace-Aware)

```python
# Method 1: Try without namespace prefix first
mesh_elem = obj.find('mesh')
if mesh_elem is None:
    # Method 2: Try with namespace prefix
    mesh_elem = obj.find(f'{{{NS_CORE}}}mesh')

# For findall, search both ways
items = build.findall('item') + build.findall(f'{{{NS_CORE}}}item')
```

#### Writing XML

```python
# Use method='xml' to preserve formatting and namespaces
tree.write(model_path, encoding='utf-8', xml_declaration=True, method='xml')
```

### Coordinate System Preservation

**Critical Rule**: Throughout this entire process, **never transform coordinates**. The G-code coordinates are already in the correct printer space coordinate system. Any transformation would misalign the baseplate.

**Transform Matrix**: Always use identity transform `"1 0 0 0 1 0 0 0 1 0 0 0"` in the `<build><item>` element. This ensures:
- No rotation (identity rotation matrix)
- No translation (X=0, Y=0, Z=0)
- Mesh vertices are used exactly as specified

### Validation Checklist

Before using the output `.3mf` file, verify:
- [ ] All mesh X coordinates are within `[0.5, 179.5]`
- [ ] All mesh Y coordinates are within `[0.5, 179.5]`
- [ ] Build item transform is identity: `"1 0 0 0 1 0 0 0 1 0 0 0"`
- [ ] Mesh is watertight (no holes, manifold)
- [ ] Mesh volume is positive (normals point outward)
- [ ] XML namespaces are correctly registered
- [ ] Vertex coordinates match G-code coordinates (no offset)

## Visual Reference

```
Build Plate (180mm x 180mm) - Top View:

Y-axis (back)
↑
│
│  [0, 180] ──────────────── [180, 180]
│     │                           │
│     │                           │
│     │     Printable Zone        │
│     │     [0.5, 179.5]         │
│     │     x [0.5, 179.5]       │
│     │                           │
│  [0, 0] ──────────────── [180, 0]
│
└─────────────────────────────────→ X-axis (right)
Origin (0, 0) = Front-Left Corner
```

## Common Issues and Solutions

### Issue: Model appears offset in Bambu Studio

**Cause**: Transform matrix in `<build><item>` is applying an offset

**Solution**: Set transform to identity: `"1 0 0 0 1 0 0 0 1 0 0 0"`

### Issue: Parts extend beyond printable zone

**Cause**: Coordinates exceed `[0, 180]` boundaries

**Solution**: Clip coordinates to safe zone `[0.5, 179.5]` before creating mesh

### Issue: Negative coordinates

**Cause**: Coordinate system may be centered or offset

**Solution**: 
- Check G-code coordinate bounds
- Clip to appropriate bounds based on coordinate system
- For corner-based system: ensure all coordinates ≥ 0.5
- For center-based system: ensure all coordinates within `[-89.5, 89.5]`

## References

- 3MF Specification: https://3mf.io/specification/
- Bambu Studio 3MF format extensions
- G-code coordinate system documentation
