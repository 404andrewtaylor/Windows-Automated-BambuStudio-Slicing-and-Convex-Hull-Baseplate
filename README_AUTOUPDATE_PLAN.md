# Auto-Update Feature - Implementation Plan

## 📋 Overview

This document outlines the plan for implementing an automatic update system that allows users to update the application directly from GitHub without manually downloading and replacing files.

## 🎯 Goals

1. **Automatic Version Checking** - Check GitHub for new releases
2. **One-Click Updates** - Download and install updates with minimal user interaction
3. **Safe Updates** - Backup current files and rollback on failure
4. **User Control** - Optional updates with user confirmation
5. **Seamless Experience** - Update without disrupting workflow

## 🔧 Implementation Plan

### Phase 1: Version Tracking

#### 1.1 Create Version File
- **File**: `VERSION.txt`
- **Format**: Semantic versioning (e.g., `1.0.0`)
- **Location**: Root directory
- **Purpose**: Track current application version

**Example:**
```
1.0.0
```

#### 1.2 Version Constants
- Add version constants to GUI applications
- Store version in `VERSION.txt` for easy access
- Include version in application title/status bar

### Phase 2: Auto-Update Module

#### 2.1 Create `auto_update.py`
- **Location**: Root directory
- **Purpose**: Core update functionality

**Key Functions:**

```python
def get_current_version():
    """Read current version from VERSION.txt"""
    pass

def check_for_updates():
    """Check GitHub API for latest release"""
    pass

def compare_versions(current, latest):
    """Compare version numbers"""
    pass

def download_update(release_url):
    """Download update ZIP from GitHub"""
    pass

def install_update(zip_path):
    """Extract and install update files"""
    pass

def backup_current_files():
    """Create backup of current installation"""
    pass

def rollback_update():
    """Restore previous version on failure"""
    pass
```

#### 2.2 GitHub API Integration
- Use GitHub Releases API: `https://api.github.com/repos/{owner}/{repo}/releases/latest`
- Fetch latest release information
- Compare version tags
- Get download URL for release ZIP

**API Endpoint:**
```
GET https://api.github.com/repos/404andrewtaylor/Windows-Automated-BambuStudio-Slicing-and-Convex-Hull-Baseplate/releases/latest
```

**Response Fields:**
- `tag_name`: Version tag (e.g., "v1.0.1")
- `name`: Release name
- `body`: Release notes
- `assets[0].browser_download_url`: ZIP download URL

### Phase 3: GUI Integration

#### 3.1 Add Update Menu/Button
- **Location**: Main window menu bar or status bar
- **Text**: "Check for Updates" or "Update Available"
- **Behavior**: 
  - Check for updates on click
  - Show update dialog if available
  - Display current version

#### 3.2 Update Dialog
- **Components**:
  - Current version display
  - Latest version display
  - Release notes preview
  - Update button
  - Cancel button
  - Progress bar (during download/install)

**Dialog Layout:**
```
┌─────────────────────────────────────┐
│ Update Available                    │
├─────────────────────────────────────┤
│ Current Version: 1.0.0              │
│ Latest Version:  1.0.1              │
│                                     │
│ Release Notes:                      │
│ - Fixed Shapely import issue        │
│ - Added scrollbars to GUI           │
│ - Improved error handling           │
│                                     │
│ [Update Now]  [Later]  [Cancel]    │
└─────────────────────────────────────┘
```

#### 3.3 Update Progress Window
- Show download progress
- Show installation progress
- Display status messages
- Allow cancellation (with rollback)

### Phase 4: Update Process

#### 4.1 Update Workflow

1. **Check for Updates**
   - User clicks "Check for Updates"
   - Query GitHub API
   - Compare versions
   - Show dialog if update available

2. **User Confirmation**
   - Display update information
   - Show release notes
   - User confirms or cancels

3. **Backup Current Files**
   - Create backup directory: `backup_{timestamp}/`
   - Copy all application files
   - Save backup location

4. **Download Update**
   - Download ZIP from GitHub release
   - Save to temp directory
   - Verify download integrity (optional: checksum)

5. **Install Update**
   - Extract ZIP to temp directory
   - Replace application files
   - Preserve user config files
   - Preserve virtual environment (venv)
   - Update VERSION.txt

6. **Verification**
   - Verify critical files exist
   - Test import of main modules
   - If verification fails: rollback

7. **Restart Application** (Optional)
   - Close current instance
   - Launch updated version
   - Show "Update successful" message

#### 4.2 Files to Update

**Files to Replace:**
- All `.py` files
- All `.bat` files
- `requirements.txt`
- `requirements_gui.txt`
- `README.md` and other documentation
- `VERSION.txt`

**Files to Preserve:**
- `venv/` (virtual environment)
- `config.json` (user configuration)
- User data files
- Output folders

**Files to Merge (if needed):**
- `config.json` (merge new defaults with user settings)

### Phase 5: Safety Features

#### 5.1 Backup System
- **Backup Location**: `backup_{timestamp}/`
- **Backup Contents**: All application files
- **Backup Format**: Full directory copy
- **Backup Retention**: Keep last 3 backups

#### 5.2 Rollback Mechanism
- **Trigger**: Update verification fails
- **Process**: 
  1. Restore files from backup
  2. Restore VERSION.txt
  3. Show error message
  4. Log rollback reason

#### 5.3 Error Handling
- **Network Errors**: Retry with exponential backoff
- **Download Errors**: Show error, allow retry
- **Installation Errors**: Automatic rollback
- **Verification Errors**: Automatic rollback

#### 5.4 Logging
- Log all update operations
- Log errors and warnings
- Save log to: `update_log.txt`
- Include timestamps and version info

### Phase 6: User Experience

#### 6.1 Update Notifications
- **On Startup**: Optional silent check
- **Manual Check**: "Check for Updates" button
- **Update Available**: Notification in status bar
- **Update Complete**: Success message

#### 6.2 Update Options
- **Automatic Check**: Check on startup (optional)
- **Update Frequency**: Daily, weekly, or manual
- **Auto-Install**: Install updates automatically (optional)
- **Skip Version**: Skip specific versions

#### 6.3 Update Settings
- Store in `config.json`:
  ```json
  {
    "updates": {
      "check_on_startup": true,
      "check_frequency": "daily",
      "auto_install": false,
      "skipped_versions": []
    }
  }
  ```

## 📁 File Structure

```
project_root/
├── VERSION.txt                    # Current version
├── auto_update.py                 # Update module
├── update_log.txt                 # Update history log
├── backup_20250101_120000/       # Backup directory
│   ├── *.py
│   ├── *.bat
│   └── ...
└── ...
```

## 🔌 Dependencies

### Required Python Packages
- `requests` - For GitHub API calls and downloads
- `zipfile` - For extracting update ZIP (standard library)
- `json` - For API responses (standard library)
- `shutil` - For file operations (standard library)

### Add to `requirements.txt`:
```
requests>=2.28.0
```

## 🚀 Implementation Steps

### Step 1: Create Version Tracking
1. Create `VERSION.txt` with current version
2. Add version constant to GUI applications
3. Display version in application title/status

### Step 2: Create Auto-Update Module
1. Create `auto_update.py`
2. Implement GitHub API integration
3. Implement version comparison
4. Implement download and installation

### Step 3: Add GUI Integration
1. Add "Check for Updates" button to Nov 10 GUI
2. Add "Check for Updates" button to Nov 4 GUI
3. Create update dialog window
4. Create progress window

### Step 4: Implement Safety Features
1. Implement backup system
2. Implement rollback mechanism
3. Add error handling
4. Add logging

### Step 5: Testing
1. Test version checking
2. Test download process
3. Test installation process
4. Test rollback mechanism
5. Test error handling

### Step 6: Documentation
1. Update main README with update feature
2. Add update instructions
3. Document update process
4. Document troubleshooting

## 🎨 GUI Integration Examples

### Nov 10 GUI Integration

**Add to menu bar:**
```python
# In __init__ method
menubar = tk.Menu(self.root)
help_menu = tk.Menu(menubar, tearoff=0)
help_menu.add_command(label="Check for Updates", command=self.check_for_updates)
help_menu.add_separator()
help_menu.add_command(label="About", command=self.show_about)
menubar.add_cascade(label="Help", menu=help_menu)
self.root.config(menu=menubar)
```

**Or add to status bar:**
```python
# Status bar with update indicator
update_button = ttk.Button(self.status_bar, text="Check for Updates", 
                           command=self.check_for_updates)
update_button.pack(side=tk.RIGHT, padx=10)
```

### Nov 4 GUI Integration

Same as Nov 10 GUI - add to menu bar or status bar.

## 🔒 Security Considerations

1. **Verify Download Source**: Only download from official GitHub repository
2. **Verify ZIP Integrity**: Check file size and basic validation
3. **Sandbox Installation**: Install to temp directory first, then verify
4. **User Confirmation**: Always require user confirmation before updating
5. **Backup Before Update**: Always create backup before modifying files

## 📝 Future Enhancements

1. **Delta Updates**: Only download changed files (not full ZIP)
2. **Background Updates**: Download updates in background
3. **Scheduled Updates**: Schedule automatic updates
4. **Update Channels**: Support beta/stable channels
5. **Update Notifications**: System tray notifications
6. **Update History**: View update history and release notes
7. **Version Pinning**: Pin to specific version
8. **Rollback UI**: GUI for selecting backup to restore

## 🐛 Troubleshooting

### Common Issues

1. **Network Errors**
   - Check internet connection
   - Retry update
   - Check firewall settings

2. **Download Failures**
   - Check disk space
   - Check write permissions
   - Retry download

3. **Installation Failures**
   - Automatic rollback should occur
   - Check error log
   - Restore from backup manually

4. **Version Mismatch**
   - Clear update cache
   - Re-check for updates
   - Manual update if needed

## 📚 References

- **GitHub Releases API**: https://docs.github.com/en/rest/releases/releases
- **Semantic Versioning**: https://semver.org/
- **Python requests library**: https://requests.readthedocs.io/

## ✅ Implementation Checklist

- [ ] Create `VERSION.txt`
- [ ] Create `auto_update.py` module
- [ ] Implement GitHub API integration
- [ ] Implement version comparison
- [ ] Implement download functionality
- [ ] Implement installation functionality
- [ ] Implement backup system
- [ ] Implement rollback mechanism
- [ ] Add GUI integration (Nov 10)
- [ ] Add GUI integration (Nov 4)
- [ ] Add error handling
- [ ] Add logging
- [ ] Add update settings to config
- [ ] Test update process
- [ ] Test rollback process
- [ ] Update documentation
- [ ] Add to requirements.txt

---

**Status**: 📋 Planned - Not yet implemented

**Priority**: Medium

**Estimated Effort**: 2-3 days

**Dependencies**: None (can be implemented independently)

