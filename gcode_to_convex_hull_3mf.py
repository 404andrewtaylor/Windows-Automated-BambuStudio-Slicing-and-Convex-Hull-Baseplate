#!/usr/bin/env python3
"""
Standalone script to extract bottom layers from .gcode.3mf, create convex hull,
buffer it, and convert to .3mf file.

This script:
1. Extracts G-code from a .gcode.3mf file
2. Parses the bottom 10 layers
3. Creates a convex hull around those layers
4. Buffers it outward by 2mm
5. Clips it to the 180mm build plate boundaries
6. Converts the hull to STL
7. Converts the STL to .3mf using the same core logic as paint_stl.py
"""

import os
import sys
import tempfile
import shutil
import re
import zipfile
import xml.etree.ElementTree as ET
import numpy as np
from pathlib import Path

try:
    import trimesh
    TRIMESH_AVAILABLE = True
except ImportError:
    TRIMESH_AVAILABLE = False
    print("Warning: trimesh not available. Please install with: pip install trimesh")


def get_script_directory():
    """Get the directory where this script is located."""
    return Path(__file__).parent.absolute()


def extract_gcode_from_3mf(input_3mf, output_gcode):
    """Extract G-code from a 3MF file using Python's zipfile module."""
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        
        # Extract the 3MF file using zipfile
        with zipfile.ZipFile(input_3mf, 'r') as zip_ref:
            zip_ref.extractall(temp_path)
        
        # Find the G-code file
        gcode_file = temp_path / "Metadata" / "plate_1.gcode"
        if not gcode_file.exists():
            raise Exception("Could not find plate_1.gcode in the 3MF file")
        
        # Copy the G-code to output location
        shutil.copy2(gcode_file, output_gcode)


def parse_move(line):
    """Return dict with X,Y,Z,E,F (floats) found in a move line. Returns None if not a motion-like line."""
    move_token_re = re.compile(r'([XYZEFS])([-+]?[0-9]*\.?[0-9]+)')
    if not line.strip().startswith(("G0", "G1")):
        return None
    tokens = dict()
    for m in move_token_re.finditer(line):
        tokens[m.group(1)] = float(m.group(2))
    return tokens


def find_layers_ranges(lines):
    """Return dict layer_index -> (start_line_idx, end_line_idx_exclusive)."""
    layer_lines = {}
    current_layer = None
    for i, ln in enumerate(lines):
        if ln.startswith("; layer num/total_layer_count:"):
            try:
                # Extract layer number from format: "; layer num/total_layer_count: 1/795"
                parts = ln.split(':')[1].strip().split('/')
                current_layer = int(parts[0].strip())
                layer_lines[current_layer] = [i, None]
            except:
                pass
    # fill end indices
    sorted_layers = sorted(layer_lines.items(), key=lambda x: x[0])
    keys = [k for k,_ in sorted_layers]
    for idx, k in enumerate(keys):
        start = layer_lines[k][0]
        if idx+1 < len(keys):
            next_start = layer_lines[keys[idx+1]][0]
            layer_lines[k][1] = next_start
        else:
            layer_lines[k][1] = len(lines)
    # convert values to tuples
    return {k:(v[0], v[1]) for k,v in layer_lines.items()}


def collect_extrusion_points(lines, start, end):
    """Return list of (x,y) for all moves with extrusion E increments in region."""
    pts = []
    # we need to track previous E to decide whether move extrudes
    prevE = None
    prevXY = None
    for i in range(start, end):
        line = lines[i]
        m = parse_move(line)
        if m:
            x = m.get('X', None)
            y = m.get('Y', None)
            e = m.get('E', None)
            if e is not None:
                # absolute E: if prevE is not None and e > prevE + tiny -> extrusion
                if prevE is None:
                    prevE = e
                    if x is not None and y is not None:
                        prevXY = (x,y)
                    continue
                if e > prevE + 1e-8:
                    # extrusion occurred: use current XY if present, else prevXY
                    if x is None or y is None:
                        if prevXY is not None:
                            pts.append(prevXY)
                    else:
                        pts.append((x,y))
                        prevXY = (x,y)
                prevE = e
            else:
                # no E in this move; but might be travel
                if x is not None and y is not None:
                    prevXY = (x,y)
    return pts


def find_first_n_layers_by_z(lines, n_layers=10):
    """Find first N layers by looking for Z movements."""
    z_levels = []
    current_z = None
    layer_starts = []
    
    for i, line in enumerate(lines):
        m = parse_move(line)
        if m and 'Z' in m:
            z_val = m['Z']
            if current_z is None:
                current_z = z_val
                layer_starts.append(i)
                z_levels.append(z_val)
            elif abs(z_val - current_z) > 0.1:  # Significant Z change indicates new layer
                current_z = z_val
                layer_starts.append(i)
                z_levels.append(z_val)
                
                # Stop after finding N layers
                if len(layer_starts) >= n_layers:
                    break
    
    if len(layer_starts) == 0:
        return 0, len(lines)
    
    # Return the range from first layer start to last layer start (or end of file)
    first_start = layer_starts[0]
    if len(layer_starts) >= n_layers:
        # Find where the Nth layer ends (next Z change or end of file)
        last_start = layer_starts[n_layers - 1]
        last_end = len(lines)
        for i in range(last_start, len(lines)):
            m = parse_move(lines[i])
            if m and 'Z' in m:
                z_val = m['Z']
                if abs(z_val - z_levels[n_layers - 1]) > 0.1:
                    last_end = i
                    break
        return first_start, last_end
    else:
        # If we have fewer than N layers, use all available layers
        return first_start, len(lines)


def parse_gcode_bottom_layers(gcode_content, n_layers=10):
    """Parse the gcode and extract coordinates from the bottom N layers."""
    print(f"[SEARCH] Analyzing bottom {n_layers} layers...")
    
    lines = gcode_content.split('\n')
    
    # Try to find layer ranges using layer comments first
    layer_ranges = find_layers_ranges(lines)
    
    if layer_ranges:
        # Get the first N layers
        sorted_layer_indices = sorted(layer_ranges.keys())
        layers_to_process = sorted_layer_indices[:n_layers]  # First N layers
        
        if len(layers_to_process) == 0:
            raise ValueError("No layers found in G-code")
        
        # Collect points from all layers
        pts = []
        for layer_idx in layers_to_process:
            layer_start, layer_end = layer_ranges[layer_idx]
            print(f"[ANALYSIS] Processing layer {layer_idx} at lines {layer_start}-{layer_end}")
            layer_pts = collect_extrusion_points(lines, layer_start, layer_end)
            
            # If no extrusion points, fallback to any XY moves
            if not layer_pts:
                print(f"[WARNING]  No extrusion points found in layer {layer_idx}, trying fallback...")
                for i in range(layer_start, layer_end):
                    m = parse_move(lines[i])
                    if m and 'X' in m and 'Y' in m:
                        layer_pts.append((m['X'], m['Y']))
            
            pts.extend(layer_pts)
        
        print(f"[ANALYSIS] Processed {len(layers_to_process)} layers (layers {layers_to_process[0]}-{layers_to_process[-1]})")
    else:
        # Fallback: find first N layers by Z movements
        print(f"[WARNING]  No ;LAYER: comments found, using Z-based layer detection...")
        first_n_layers_start, first_n_layers_end = find_first_n_layers_by_z(lines, n_layers)
        
        # Collect points from the first N layers range
        pts = collect_extrusion_points(lines, first_n_layers_start, first_n_layers_end)
        
        # If no extrusion points, fallback to any XY moves
        if not pts:
            print("[WARNING]  No extrusion points found, trying fallback...")
            for i in range(first_n_layers_start, first_n_layers_end):
                m = parse_move(lines[i])
                if m and 'X' in m and 'Y' in m:
                    pts.append((m['X'], m['Y']))
    
    if not pts:
        raise ValueError(f"No XY points found in bottom {n_layers} layers")
    
    print(f"[ANALYSIS] Found {len(pts)} points across bottom {n_layers} layers")
    return np.array(pts)


def convex_hull(points):
    """Returns list of points in hull (ccw) or [] if insufficient."""
    pts = sorted(set(points))
    if len(pts) <= 1:
        return pts
    def cross(o, a, b):
        return (a[0]-o[0])*(b[1]-o[1]) - (a[1]-o[1])*(b[0]-o[0])
    lower = []
    for p in pts:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)
    upper = []
    for p in reversed(pts):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)
    hull = lower[:-1] + upper[:-1]
    return hull


def compute_convex_hull(points):
    """Compute the convex hull of the points."""
    print("[HULL] Computing convex hull...")
    
    # Convert numpy array to list of tuples for the algorithm
    point_list = [(p[0], p[1]) for p in points]
    
    hull_points = convex_hull(point_list)
    
    if len(hull_points) < 3:
        # Degenerate hull: expand single point to small square
        if len(hull_points) == 1:
            x, y = hull_points[0]
            hull_points = [(x-0.5, y-0.5), (x+0.5, y-0.5), (x+0.5, y+0.5), (x-0.5, y+0.5)]
        else:
            raise ValueError("Need at least 3 points to compute convex hull")
    
    print(f"[OK] Convex hull computed with {len(hull_points)} vertices")
    return np.array(hull_points)


def offset_hull(hull_points, buffer_mm=2.0):
    """
    Apply buffer/offset to convex hull by scaling it up from its center.
    Ensures the edge of the scaled hull is at least buffer_mm away from the original edge.
    """
    # Validate input
    if len(hull_points) < 3:
        raise ValueError(f"Need at least 3 points for hull, got {len(hull_points)}")
    
    # Ensure hull_points is a numpy array
    hull_points = np.array(hull_points, dtype=np.float64)
    
    # Calculate the center of the hull (centroid)
    center = np.mean(hull_points, axis=0)
    
    # Calculate distance from center to each vertex
    distances_from_center = np.array([np.linalg.norm(point - center) for point in hull_points])
    
    # Find the minimum distance (closest point to center)
    min_distance = np.min(distances_from_center)
    
    if min_distance < 1e-10:
        # Degenerate case: all points at center
        raise ValueError("Hull is degenerate (all points at center)")
    
    # Calculate scale factor to ensure at least buffer_mm distance
    scale_factor = 1.0 + (buffer_mm / min_distance)
    
    # Scale all points outward from center
    buffered_points = center + (hull_points - center) * scale_factor
    
    # Validate output
    if len(buffered_points) < 3:
        raise ValueError(f"Buffered hull has insufficient points: {len(buffered_points)}")
    
    return buffered_points


def clip_to_build_plate(hull_points, plate_size=180.0, gcode_bounds=None):
    """
    Clip the hull to the build plate boundaries.
    
    Args:
        hull_points: numpy array of (x, y) points forming the convex hull
        plate_size: Build plate size in mm (default: 180.0)
        gcode_bounds: Optional tuple (min_x, min_y, max_x, max_y) from G-code to preserve coordinate system
    
    For Bambu Studio, the build plate typically has origin at front-left corner,
    so coordinates range from (0, 0) to (plate_size, plate_size).
    However, if gcode_bounds shows negative values, we preserve that coordinate system.
    """
    print(f"[CLIP] Clipping hull to {plate_size}mm build plate...")
    
    # Determine clipping bounds - strict bounds [0.5, 179.5] for both axes
    # This ensures we stay well within the 180mm build plate boundaries
    margin = 0.5
    x_min_bound = margin
    x_max_bound = plate_size - margin
    y_min_bound = margin
    y_max_bound = plate_size - margin
    
    if gcode_bounds is not None:
        min_x, min_y, max_x, max_y = gcode_bounds
        print(f"[CLIP] G-code bounds: X=[{min_x:.2f}, {max_x:.2f}], Y=[{min_y:.2f}, {max_y:.2f}]")
    
    print(f"[CLIP] Clipping to strict plate bounds: X=[{x_min_bound:.2f}, {x_max_bound:.2f}], Y=[{y_min_bound:.2f}, {y_max_bound:.2f}]")
    
    # Print hull bounds before clipping
    hull_min_x = np.min(hull_points[:, 0])
    hull_max_x = np.max(hull_points[:, 0])
    hull_min_y = np.min(hull_points[:, 1])
    hull_max_y = np.max(hull_points[:, 1])
    print(f"[CLIP] Hull bounds before clipping: X=[{hull_min_x:.2f}, {hull_max_x:.2f}], Y=[{hull_min_y:.2f}, {hull_max_y:.2f}]")
    
    # Clip each point to boundaries
    clipped_points = []
    for point in hull_points:
        x = np.clip(point[0], x_min_bound, x_max_bound)
        y = np.clip(point[1], y_min_bound, y_max_bound)
        clipped_points.append([x, y])
    
    clipped_points = np.array(clipped_points)
    
    # Remove duplicate points that might have been created by clipping
    # Keep unique points while preserving order
    seen = set()
    unique_points = []
    for point in clipped_points:
        point_tuple = (round(point[0], 6), round(point[1], 6))
        if point_tuple not in seen:
            seen.add(point_tuple)
            unique_points.append(point)
    
    if len(unique_points) < 3:
        raise ValueError(f"After clipping, insufficient points for hull: {len(unique_points)}")
    
    # Recompute convex hull after clipping (in case clipping created concave regions)
    clipped_hull = compute_convex_hull(np.array(unique_points))
    
    # Print hull bounds after clipping
    clipped_min_x = np.min(clipped_hull[:, 0])
    clipped_max_x = np.max(clipped_hull[:, 0])
    clipped_min_y = np.min(clipped_hull[:, 1])
    clipped_max_y = np.max(clipped_hull[:, 1])
    print(f"[CLIP] Hull bounds after clipping: X=[{clipped_min_x:.2f}, {clipped_max_x:.2f}], Y=[{clipped_min_y:.2f}, {clipped_max_y:.2f}]")
    print(f"[OK] Clipped hull has {len(clipped_hull)} vertices")
    return clipped_hull


def create_stl_from_hull(hull_points, height=1.0):
    """
    Create an STL mesh from a convex hull by extruding it vertically.
    
    Args:
        hull_points: numpy array of (x, y) points forming the convex hull
        height: Height of extrusion in mm (default: 1.0)
    
    Returns:
        trimesh.Trimesh object
    """
    if not TRIMESH_AVAILABLE:
        raise ImportError("trimesh is required. Install with: pip install trimesh")
    
    print(f"[HULL] Creating STL mesh from convex hull with {len(hull_points)} vertices...")
    print(f"[MEASURE] Extrusion height: {height}mm")
    
    # Ensure hull points are in counter-clockwise order (required for proper face orientation)
    # Calculate signed area to check winding order
    n_points = len(hull_points)
    area = 0.0
    for i in range(n_points):
        j = (i + 1) % n_points
        area += hull_points[i][0] * hull_points[j][1]
        area -= hull_points[j][0] * hull_points[i][1]
    
    # If area is negative, reverse the order (we want CCW)
    if area < 0:
        hull_points = hull_points[::-1]
        print("[HULL] Reversed hull point order to ensure counter-clockwise winding")
    
    # Manual creation with proper winding order
    n_points = len(hull_points)
    
    # Create vertices: bottom and top layers
    vertices = []
    
    # Bottom vertices (z=0)
    for point in hull_points:
        vertices.append([point[0], point[1], 0.0])
    
    # Top vertices (z=height)
    for point in hull_points:
        vertices.append([point[0], point[1], height])
    
    vertices = np.array(vertices)
    
    # Create faces
    faces = []
    
    # Bottom face (triangulate the convex hull) - CCW order when viewed from below (normal points down)
    for i in range(1, n_points - 1):
        faces.append([0, i + 1, i])  # Reversed for downward normal
    
    # Top face (same triangulation but at height, CCW order when viewed from above for upward normal)
    base_idx = n_points
    for i in range(1, n_points - 1):
        faces.append([base_idx, base_idx + i, base_idx + i + 1])  # CCW for upward normal
    
    # Side faces (connecting bottom to top) - ensure consistent winding
    for i in range(n_points):
        next_i = (i + 1) % n_points
        
        # Each side face is a quad split into two triangles
        # Triangle 1: bottom current -> bottom next -> top current (CCW from outside)
        faces.append([i, next_i, i + n_points])
        # Triangle 2: bottom next -> top next -> top current (CCW from outside)
        faces.append([next_i, next_i + n_points, i + n_points])
    
    faces = np.array(faces)
    
    # Create trimesh object from manually created faces
    mesh_obj = trimesh.Trimesh(vertices=vertices, faces=faces)
    
    # Ensure the mesh is manifold and fix any issues
    if not mesh_obj.is_watertight:
        print("[WARN] Mesh is not watertight, attempting to fix...")
        # Try to fix non-manifold edges
        mesh_obj.fill_holes()
        mesh_obj.remove_duplicate_faces()
        mesh_obj.remove_unreferenced_vertices()
    
    # Verify mesh is valid and fix normals if needed
    if mesh_obj.is_volume:
        volume = mesh_obj.volume
        print(f"[MESH] Mesh volume: {volume:.2f} mm³")
    else:
        print("[WARN] Mesh has zero or negative volume, checking normals...")
        # Try inverting normals
        mesh_obj.invert()
        if mesh_obj.is_volume:
            print("[MESH] Fixed by inverting normals")
        else:
            print("[WARN] Mesh still has issues after inverting normals")
    
    # Check for non-manifold edges
    if hasattr(mesh_obj, 'edges') and len(mesh_obj.edges) > 0:
        # Count edges that are shared by more than 2 faces (non-manifold)
        edge_count = {}
        for face in mesh_obj.faces:
            for i in range(3):
                edge = tuple(sorted([face[i], face[(i+1)%3]]))
                edge_count[edge] = edge_count.get(edge, 0) + 1
        
        non_manifold_edges = [e for e, count in edge_count.items() if count != 2]
        if non_manifold_edges:
            print(f"[WARN] Found {len(non_manifold_edges)} non-manifold edges, attempting repair...")
            # Try to repair
            mesh_obj.remove_duplicate_faces()
            mesh_obj.remove_unreferenced_vertices()
    
    print(f"[OK] Created STL mesh with {len(mesh_obj.vertices)} vertices and {len(mesh_obj.faces)} faces")
    return mesh_obj


def stl_to_3mf(mesh_obj, output_path, blank_template_path=None):
    """
    Convert a trimesh mesh to .3mf file using the same core logic as paint_stl.py.
    
    Args:
        mesh_obj: trimesh.Trimesh object
        output_path: Path for output .3mf file
        blank_template_path: Path to blank_template.3mf. If None, uses default location.
    
    Returns:
        Path to the created .3mf file
    """
    # Get blank template path
    if blank_template_path is None:
        script_dir = get_script_directory()
        blank_template_path = script_dir / "blank_template.3mf"
    
    if not os.path.exists(blank_template_path):
        raise FileNotFoundError(f"Blank template not found: {blank_template_path}")
    
    output_path = Path(output_path)
    
    # Extract blank template to temp directory
    print("Extracting blank template...")
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        
        # Extract .3mf file
        with zipfile.ZipFile(blank_template_path, 'r') as zip_ref:
            zip_ref.extractall(temp_path)
        
        # Load and modify 3dmodel.model
        model_path = temp_path / "3D" / "3dmodel.model"
        
        print("Reading 3dmodel.model...")
        # Register namespaces to preserve them
        ET.register_namespace('', 'http://schemas.microsoft.com/3dmanufacturing/core/2015/02')
        ET.register_namespace('BambuStudio', 'http://schemas.bambulab.com/package/2021')
        
        tree = ET.parse(model_path)
        root = tree.getroot()
        
        # Find the mesh element - try both with and without namespace prefix
        mesh_elem = None
        for obj in root.findall('.//object') + root.findall('.//{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}object'):
            mesh_elem = obj.find('mesh')
            if mesh_elem is None:
                mesh_elem = obj.find('{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}mesh')
            if mesh_elem is not None:
                break
        
        if mesh_elem is None:
            raise ValueError("Could not find mesh element in 3dmodel.model")
        
        # Find or create vertices and triangles elements
        vertices_elem = mesh_elem.find('vertices')
        if vertices_elem is None:
            vertices_elem = mesh_elem.find('{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}vertices')
        if vertices_elem is None:
            vertices_elem = ET.SubElement(mesh_elem, 'vertices')
        
        triangles_elem = mesh_elem.find('triangles')
        if triangles_elem is None:
            triangles_elem = mesh_elem.find('{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}triangles')
        if triangles_elem is None:
            triangles_elem = ET.SubElement(mesh_elem, 'triangles')
        
        # Clear existing geometry
        vertices_elem.clear()
        triangles_elem.clear()
        
        # Add vertices
        print(f"Adding {len(mesh_obj.vertices)} vertices...")
        for vertex in mesh_obj.vertices:
            vertex_elem = ET.SubElement(vertices_elem, 'vertex')
            vertex_elem.set('x', str(vertex[0]))
            vertex_elem.set('y', str(vertex[1]))
            vertex_elem.set('z', str(vertex[2]))
        
        # Add triangles
        print(f"Adding {len(mesh_obj.faces)} triangles...")
        for face in mesh_obj.faces:
            triangle_elem = ET.SubElement(triangles_elem, 'triangle')
            triangle_elem.set('v1', str(int(face[0])))
            triangle_elem.set('v2', str(int(face[1])))
            triangle_elem.set('v3', str(int(face[2])))
        
        # Update metadata - update face_count in model_settings.config
        model_settings_path = temp_path / "Metadata" / "model_settings.config"
        if model_settings_path.exists():
            print("Updating model_settings.config...")
            settings_tree = ET.parse(model_settings_path)
            settings_root = settings_tree.getroot()
            
            # Update face_count
            for obj in settings_root.findall('.//object'):
                face_count_elem = obj.find('.//metadata[@face_count]')
                if face_count_elem is None:
                    # Try to find it in part
                    for part in obj.findall('.//part'):
                        mesh_stat = part.find('mesh_stat')
                        if mesh_stat is not None:
                            mesh_stat.set('face_count', str(len(mesh_obj.faces)))
                else:
                    face_count_elem.set('face_count', str(len(mesh_obj.faces)))
                
                # Also update in metadata
                for metadata in obj.findall('.//metadata[@key="face_count"]'):
                    metadata.set('value', str(len(mesh_obj.faces)))
                
                # Update mesh_stat
                for part in obj.findall('.//part'):
                    mesh_stat = part.find('mesh_stat')
                    if mesh_stat is not None:
                        mesh_stat.set('face_count', str(len(mesh_obj.faces)))
        
        # Set build item transform to identity (no translation) to preserve G-code coordinates
        # The blank template may have a transform that centers objects, but we want to use
        # the exact G-code coordinate system without any offset
        NS = "http://schemas.microsoft.com/3dmanufacturing/core/2015/02"
        build = root.find('build')
        if build is None:
            build = root.find(f'{{{NS}}}build')
        if build is None:
            build = ET.SubElement(root, 'build')
        
        # Find or create build items
        items = build.findall('item') + build.findall(f'{{{NS}}}item')
        if len(items) == 0:
            # Create a build item if none exists
            # First, find the object ID (should be 1 or 2)
            resources = root.find('resources')
            if resources is None:
                resources = root.find(f'{{{NS}}}resources')
            obj_ids = []
            if resources is not None:
                for obj in resources.findall('object') + resources.findall(f'{{{NS}}}object'):
                    oid = obj.get('id')
                    if oid:
                        obj_ids.append(int(oid))
            
            # Use the highest object ID, or default to 1
            object_id = max(obj_ids) if obj_ids else 1
            item = ET.SubElement(build, 'item')
            item.set('objectid', str(object_id))
            item.set('printable', '1')
            items = [item]
        
        # Set transform to identity (no translation) - format: "1 0 0 0 1 0 0 0 1 0 0 0"
        identity_transform = "1 0 0 0 1 0 0 0 1 0 0 0"
        for item in items:
            item.set('transform', identity_transform)
        print(f"[TRANSFORM] Set build item transform to identity (preserving G-code coordinates)")
        
        # Write modified 3dmodel.model
        print("Writing modified 3dmodel.model...")
        # Use method='xml' to preserve formatting and namespaces
        tree.write(model_path, encoding='utf-8', xml_declaration=True, method='xml')
        
        # Create .3mf file
        print(f"Creating .3mf file: {output_path}")
        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for root_dir, dirs, files in os.walk(temp_path):
                for file in files:
                    file_path = Path(root_dir) / file
                    arcname = file_path.relative_to(temp_path)
                    zipf.write(file_path, arcname)
        
        print(f"Successfully created .3mf file: {output_path}")
        return output_path


def gcode_to_convex_hull_3mf(input_gcode_3mf, output_3mf, n_layers=10, buffer_mm=4.0, 
                              plate_size=180.0, hull_height=1.0, blank_template_path=None):
    """
    Main function: Extract bottom layers from .gcode.3mf, create convex hull, buffer, and convert to .3mf.
    
    Args:
        input_gcode_3mf: Path to input .gcode.3mf file
        output_3mf: Path to output .3mf file
        n_layers: Number of bottom layers to analyze (default: 10)
        buffer_mm: Buffer distance in mm (default: 2.0)
        plate_size: Build plate size in mm (default: 180.0)
        hull_height: Height of extruded hull in mm (default: 1.0)
        blank_template_path: Path to blank_template.3mf. If None, uses default location.
    
    Returns:
        Path to the created .3mf file
    """
    print(f"[START] Processing {input_gcode_3mf}")
    print(f"[PARAMS] Layers: {n_layers}, Buffer: {buffer_mm}mm, Plate: {plate_size}mm, Height: {hull_height}mm")
    
    # Step 1: Extract G-code
    print("\n[STEP 1] Extracting G-code from .gcode.3mf...")
    with tempfile.NamedTemporaryFile(suffix='.gcode', delete=False) as temp_gcode:
        temp_gcode_path = temp_gcode.name
    
    try:
        extract_gcode_from_3mf(input_gcode_3mf, temp_gcode_path)
        
        # Read the extracted gcode
        with open(temp_gcode_path, 'r') as f:
            gcode_content = f.read()
        
        print("[OK] G-code extracted successfully")
        
        # Step 2: Parse bottom layers
        print("\n[STEP 2] Parsing bottom layers...")
        bottom_layer_points = parse_gcode_bottom_layers(gcode_content, n_layers=n_layers)
        
        # Calculate G-code bounds for coordinate system preservation
        gcode_min_x = np.min(bottom_layer_points[:, 0])
        gcode_max_x = np.max(bottom_layer_points[:, 0])
        gcode_min_y = np.min(bottom_layer_points[:, 1])
        gcode_max_y = np.max(bottom_layer_points[:, 1])
        gcode_bounds = (gcode_min_x, gcode_min_y, gcode_max_x, gcode_max_y)
        print(f"[COORDS] G-code coordinate bounds: X=[{gcode_min_x:.2f}, {gcode_max_x:.2f}], Y=[{gcode_min_y:.2f}, {gcode_max_y:.2f}]")
        
        # Step 3: Compute convex hull
        print("\n[STEP 3] Computing convex hull...")
        hull_points = compute_convex_hull(bottom_layer_points)
        
        # Print hull bounds
        hull_min_x = np.min(hull_points[:, 0])
        hull_max_x = np.max(hull_points[:, 0])
        hull_min_y = np.min(hull_points[:, 1])
        hull_max_y = np.max(hull_points[:, 1])
        print(f"[COORDS] Convex hull bounds: X=[{hull_min_x:.2f}, {hull_max_x:.2f}], Y=[{hull_min_y:.2f}, {hull_max_y:.2f}]")
        
        # Step 4: Buffer the hull
        print(f"\n[STEP 4] Buffering hull by {buffer_mm}mm...")
        buffered_hull = offset_hull(hull_points, buffer_mm=buffer_mm)
        
        # Print buffered hull bounds
        buffered_min_x = np.min(buffered_hull[:, 0])
        buffered_max_x = np.max(buffered_hull[:, 0])
        buffered_min_y = np.min(buffered_hull[:, 1])
        buffered_max_y = np.max(buffered_hull[:, 1])
        print(f"[COORDS] Buffered hull bounds: X=[{buffered_min_x:.2f}, {buffered_max_x:.2f}], Y=[{buffered_min_y:.2f}, {buffered_max_y:.2f}]")
        
        # Step 5: Clip to build plate
        print(f"\n[STEP 5] Clipping to {plate_size}mm build plate...")
        clipped_hull = clip_to_build_plate(buffered_hull, plate_size=plate_size, gcode_bounds=gcode_bounds)
        
        # Step 6: Convert hull to STL mesh
        print(f"\n[STEP 6] Converting hull to STL mesh (height: {hull_height}mm)...")
        # Print final hull coordinates for verification
        print(f"[COORDS] Final hull vertices:")
        for i, point in enumerate(clipped_hull):
            print(f"  Vertex {i+1}: ({point[0]:.2f}, {point[1]:.2f})")
        stl_mesh = create_stl_from_hull(clipped_hull, height=hull_height)
        
        # Verify mesh coordinates match hull
        mesh_min_x = np.min(stl_mesh.vertices[:, 0])
        mesh_max_x = np.max(stl_mesh.vertices[:, 0])
        mesh_min_y = np.min(stl_mesh.vertices[:, 1])
        mesh_max_y = np.max(stl_mesh.vertices[:, 1])
        print(f"[COORDS] STL mesh bounds: X=[{mesh_min_x:.2f}, {mesh_max_x:.2f}], Y=[{mesh_min_y:.2f}, {mesh_max_y:.2f}], Z=[0.00, {hull_height:.2f}]")
        
        # Step 7: Convert STL to .3mf
        print(f"\n[STEP 7] Converting STL to .3mf...")
        output_path = stl_to_3mf(stl_mesh, output_3mf, blank_template_path=blank_template_path)
        
        print(f"\n[SUCCESS] Created convex hull .3mf file: {output_path}")
        return output_path
        
    finally:
        # Clean up temp file
        if os.path.exists(temp_gcode_path):
            os.unlink(temp_gcode_path)


def main():
    """Command-line interface."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description='Extract bottom layers from .gcode.3mf, create convex hull, buffer, and convert to .3mf'
    )
    parser.add_argument('input_gcode_3mf', type=str, help='Path to input .gcode.3mf file')
    parser.add_argument('-o', '--output', type=str, help='Output .3mf file path')
    parser.add_argument('--layers', type=int, default=10, help='Number of bottom layers to analyze (default: 10)')
    parser.add_argument('--buffer', type=float, default=4.0, help='Buffer distance in mm (default: 4.0)')
    parser.add_argument('--plate-size', type=float, default=180.0, help='Build plate size in mm (default: 180.0)')
    parser.add_argument('--hull-height', type=float, default=1.0, help='Height of extruded hull in mm (default: 1.0)')
    parser.add_argument('-t', '--template', type=str, help='Path to blank_template.3mf (default: ./blank_template.3mf)')
    
    args = parser.parse_args()
    
    # Generate output path if not provided
    if args.output is None:
        input_path = Path(args.input_gcode_3mf)
        output_path = input_path.parent / f"{input_path.stem}_convex_hull.3mf"
    else:
        output_path = args.output
    
    try:
        output = gcode_to_convex_hull_3mf(
            input_gcode_3mf=args.input_gcode_3mf,
            output_3mf=output_path,
            n_layers=args.layers,
            buffer_mm=args.buffer,
            plate_size=args.plate_size,
            hull_height=args.hull_height,
            blank_template_path=args.template
        )
        print(f"\n✓ Success! Output file: {output}")
    except Exception as e:
        print(f"\n✗ Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
