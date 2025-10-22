# Windows Migration Plan - STL to Hull Baseplate Pipeline

## Overview
This document outlines the comprehensive plan to make the STL to Hull Baseplate Pipeline work on Windows while maintaining Mac compatibility.

## Current State Analysis
The pipeline currently works on macOS and uses:
- Shell scripts (.sh files) for automation
- AppleScript (.scpt) for Bambu Studio control
- Mac-specific commands and paths
- Unix utilities (unzip, zip, md5)

## Migration Strategy

### 1. Cross-Platform Automation Module
**Goal**: Replace OS-specific automation with unified Python approach

**Structure**:
```
automation/
├── __init__.py          # OS detection and routing
├── mac.py              # Keep existing AppleScript logic
└── windows.py          # New pyautogui-based automation
```

**Features**:
- Dynamic Bambu Studio path detection
- JSON/YAML config for UI sequences
- Window focus and keystroke automation
- Fallback to manual intervention mode

### 2. Convert Shell Scripts to Python
**Goal**: Replace all shell scripts with cross-platform Python equivalents

**Files to Convert**:
- `full_pipeline.sh` → `full_pipeline.py`
- `slice_bambu.sh` → `slice_bambu.py` 
- `import_move_slice.sh` → `import_move_slice.py`
- `setup.sh` → `setup.py`

**Benefits**:
- Cross-platform compatibility
- Unified codebase
- Better error handling
- No shell script dependencies

### 3. Update Dependencies
**Add to requirements.txt**:
```
pyautogui>=0.9.54        # Cross-platform automation
pygetwindow>=0.0.9       # Window detection
pywinauto>=0.6.8         # Windows UI automation (backup)
```

**Replace Unix Commands**:
- `unzip` → `zipfile` module
- `md5` → `hashlib.md5()`
- `source venv/bin/activate` → Python venv activation

### 4. OS Detection and Routing
**Create**: `utils/platform.py` for OS detection

**Logic**:
```python
import platform

if platform.system() == "Darwin":
    from automation.mac import run_bambu_studio
elif platform.system() == "Windows":
    from automation.windows import run_bambu_studio
```

### 5. Windows-Specific Setup
**Create**: `setup_windows.py` for Windows installation

**Features**:
- Bambu Studio path detection
- Python virtual environment setup
- Dependency installation
- Permission setup guidance

### 6. Configuration Management
**Create**: `config/` directory

**Files**:
- `config/automation_sequences.json` - UI interaction sequences
- `config/paths.json` - OS-specific paths
- `config/settings.json` - General settings

### 7. Updated Documentation
**Modify**: `README.md` and `HOW_TO_USE_GUIDE.md`

**Add**:
- Windows-specific instructions
- Troubleshooting for Windows issues
- Cross-platform usage examples

## Technical Implementation Details

### Bambu Studio Automation
**Mac**: Keep existing AppleScript approach
**Windows**: pyautogui with window detection
**Fallback**: Manual intervention mode for both platforms

### File Operations
- Replace shell commands with Python equivalents
- Use `pathlib` for cross-platform paths
- Implement proper error handling and logging

### Virtual Environment
- Cross-platform venv activation
- Automatic dependency installation
- Platform-specific activation scripts

### Path Handling
- Dynamic Bambu Studio detection
- Configurable paths per OS
- Proper Windows path handling with backslashes

## File Structure After Migration

### New Files to Create
```
automation/
├── __init__.py
├── mac.py
└── windows.py

utils/
└── platform.py

config/
├── automation_sequences.json
├── paths.json
└── settings.json

full_pipeline.py
slice_bambu.py
import_move_slice.py
setup.py
setup_windows.py
```

### Files to Modify
- `requirements.txt` (add Windows dependencies)
- `README.md` (add Windows instructions)
- `HOW_TO_USE_GUIDE.md` (add Windows setup)

### Files to Preserve
- All existing Python scripts (`.py` files)
- `ReplaceBaseplate/` directory
- Mac-specific files (`.sh`, `.scpt`) for backward compatibility

## Implementation Priority

1. **Phase 1**: Create automation module and OS detection
2. **Phase 2**: Convert shell scripts to Python
3. **Phase 3**: Update dependencies and configuration
4. **Phase 4**: Create Windows setup and documentation
5. **Phase 5**: Testing and refinement

## Benefits of This Approach

1. **Maintains Mac Compatibility**: Existing Mac users continue to work
2. **Adds Windows Support**: Full Windows functionality
3. **Future-Proof**: Easy to add Linux support later
4. **Unified Codebase**: Single codebase for all platforms
5. **Better Error Handling**: Python provides better error management
6. **Easier Distribution**: No shell script dependencies

## Testing Strategy

1. **Mac Testing**: Ensure existing functionality still works
2. **Windows Testing**: Test all pipeline steps on Windows
3. **Cross-Platform Testing**: Verify OS detection works correctly
4. **Error Handling**: Test fallback modes and error scenarios
5. **Documentation**: Verify all instructions work on both platforms

## Success Criteria

- [ ] Pipeline works on both Mac and Windows
- [ ] No shell script dependencies
- [ ] Bambu Studio automation works on both platforms
- [ ] All existing functionality preserved
- [ ] Clear documentation for both platforms
- [ ] Easy setup process for new users

---

**Created**: December 2024  
**Status**: Planning Phase  
**Next Steps**: Begin Phase 1 implementation
