#!/usr/bin/env python3
"""
Presliced Baseplate Utilities

Handles presliced baseplate file management, caching, and retrieval.
"""

import os
import shutil
from pathlib import Path


def setup_presliced_baseplate_directories(script_dir):
    """Create directories for presliced baseplates if they don't exist."""
    base_dir = os.path.join(script_dir, "presliced_baseplates")
    single_dir = os.path.join(base_dir, "single_color")
    multi_dir = os.path.join(base_dir, "multicolor")
    
    os.makedirs(single_dir, exist_ok=True)
    os.makedirs(multi_dir, exist_ok=True)
    
    return base_dir, single_dir, multi_dir


def get_presliced_multicolor_baseplate(script_dir):
    """
    Get path to presliced multicolor baseplate (.gcode.3mf format).
    
    Args:
        script_dir: Directory where the script is located
        
    Returns:
        Path to presliced multicolor baseplate .gcode.3mf file
        
    Raises:
        FileNotFoundError: If baseplate file is not found
    """
    # Check root directory first (most common location)
    gcode_3mf_path = os.path.join(script_dir, "presliced_multicolour_baseplate.gcode.3mf")
    
    if os.path.exists(gcode_3mf_path):
        print(f"[PRESLICED] Found multicolor baseplate: {gcode_3mf_path}")
        return gcode_3mf_path
    
    # Check in presliced_baseplates/multicolor/ directory
    multi_dir = os.path.join(script_dir, "presliced_baseplates", "multicolor")
    gcode_3mf_path = os.path.join(multi_dir, "presliced_multicolour_baseplate.gcode.3mf")
    
    if os.path.exists(gcode_3mf_path):
        print(f"[PRESLICED] Found multicolor baseplate: {gcode_3mf_path}")
        return gcode_3mf_path
    
    # File not found
    error_msg = (
        "Presliced multicolor baseplate not found.\n"
        f"Expected locations:\n"
        f"  - {os.path.join(script_dir, 'presliced_multicolour_baseplate.gcode.3mf')}\n"
        f"  - {os.path.join(multi_dir, 'presliced_multicolour_baseplate.gcode.3mf')}"
    )
    raise FileNotFoundError(error_msg)


def create_and_cache_single_color_baseplate(script_dir, width=175, height=175, 
                                           printer_model="A1mini", layers=6):
    """
    Create 175x175mm rectangle baseplate, slice it, and cache the result.
    
    Args:
        script_dir: Directory where the script is located
        width: Width of baseplate in mm (default 175)
        height: Height of baseplate in mm (default 175)
        printer_model: Printer model name (default "A1mini")
        layers: Number of layers to create (default 6)
        
    Returns:
        Path to cached .gcode.3mf file
        
    Raises:
        RuntimeError: If baseplate creation fails
    """
    from create_rectangle_baseplate import create_rectangle_stl
    
    # Setup directories
    _, single_dir, _ = setup_presliced_baseplate_directories(script_dir)
    
    # Create temp directory for this operation
    temp_dir = os.path.join(script_dir, "temp_baseplate_cache")
    os.makedirs(temp_dir, exist_ok=True)
    
    try:
        # Create rectangle STL
        rectangle_stl = os.path.join(temp_dir, "temp_rectangle.stl")
        print(f"[CACHE] Creating {width}x{height}mm rectangle STL...")
        create_rectangle_stl(width, height_mm=height, thickness_mm=1.0, output_path=rectangle_stl)
        
        # Slice it (no movement, at origin)
        cached_name = f"baseplate_{width}x{height}_{printer_model}_{layers}layers.gcode.3mf"
        cached_path = os.path.join(single_dir, cached_name)
        temp_3mf = os.path.join(temp_dir, "temp_rectangle.3mf")
        
        print(f"[CACHE] Slicing rectangle baseplate in Bambu Studio...")
        
        # Use existing import_move_slice_file function
        import platform
        if platform.system() == "Windows":
            from automation_windows import import_move_slice_file
        elif platform.system() == "Darwin":
            from automation_mac import import_move_slice_file
        else:
            raise RuntimeError("Unsupported platform. Only Windows and macOS are supported.")
        
        success = import_move_slice_file(rectangle_stl, 0, 0, cached_path, temp_3mf)
        
        if success and os.path.exists(cached_path):
            print(f"[CACHE] Successfully cached baseplate: {cached_path}")
            return cached_path
        else:
            raise RuntimeError(f"Failed to create cached baseplate. File not found: {cached_path}")
            
    finally:
        # Cleanup temp files
        try:
            if os.path.exists(temp_dir):
                shutil.rmtree(temp_dir)
        except Exception as e:
            print(f"[WARNING] Could not clean up temp directory {temp_dir}: {e}")


def ensure_presliced_single_color_baseplate(script_dir, width=175, height=175, 
                                           printer_model="A1mini", layers=6):
    """
    Ensure presliced single-color baseplate exists, create if needed.
    
    Args:
        script_dir: Directory where the script is located
        width: Width of baseplate in mm (default 175)
        height: Height of baseplate in mm (default 175)
        printer_model: Printer model name (default "A1mini")
        layers: Number of layers (default 6, for consistency with multicolor)
        
    Returns:
        Path to cached .gcode.3mf file
    """
    _, single_dir, _ = setup_presliced_baseplate_directories(script_dir)
    
    cached_name = f"baseplate_{width}x{height}_{printer_model}_{layers}layers.gcode.3mf"
    cached_path = os.path.join(single_dir, cached_name)
    
    if os.path.exists(cached_path):
        print(f"[CACHE] Using cached single-color baseplate: {cached_path}")
        return cached_path
    
    # Create and cache
    print(f"[CACHE] Cached baseplate not found. Creating new one...")
    return create_and_cache_single_color_baseplate(script_dir, width, height, 
                                                  printer_model, layers)


def get_baseplate_file_and_layers(mode, script_dir, **kwargs):
    """
    Get baseplate file path and layer count based on mode.
    
    Args:
        mode: Baseplate mode ("dynamic", "presliced_multicolor", "presliced_single")
        script_dir: Directory where the script is located
        **kwargs: Additional parameters (width, height, printer_model, layers)
        
    Returns:
        tuple: (baseplate_file_path, layers_to_replace)
        
    Raises:
        ValueError: If mode is invalid
        FileNotFoundError: If presliced baseplate not found
    """
    if mode == "presliced_multicolor":
        baseplate_path = get_presliced_multicolor_baseplate(script_dir)
        layers = 6  # Multicolor baseplate always has 6 layers
        return baseplate_path, layers
        
    elif mode == "presliced_single":
        width = kwargs.get('width', 175)
        height = kwargs.get('height', 175)
        printer_model = kwargs.get('printer_model', 'A1mini')
        layers = kwargs.get('layers', 6)
        baseplate_path = ensure_presliced_single_color_baseplate(
            script_dir, width, height, printer_model, layers
        )
        return baseplate_path, layers
        
    elif mode == "dynamic":
        # Dynamic mode - baseplate will be created in pipeline
        # Return None to indicate dynamic generation needed
        layers = kwargs.get('layers', 5)  # Default 5 layers for dynamic
        return None, layers
        
    else:
        raise ValueError(f"Invalid baseplate mode: {mode}. Must be 'dynamic', 'presliced_multicolor', or 'presliced_single'")
