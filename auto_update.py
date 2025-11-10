#!/usr/bin/env python3
"""
Auto-Update Module for Hull Baseplate Pipeline

Handles checking for updates from GitHub and installing them automatically.
"""

import os
import sys
import json
import zipfile
import shutil
import tempfile
import time
from pathlib import Path
from urllib.parse import urlparse

# GitHub repository information
GITHUB_OWNER = "404andrewtaylor"
GITHUB_REPO = "Windows-Automated-BambuStudio-Slicing-and-Convex-Hull-Baseplate"
GITHUB_API_URL = f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/releases/latest"


def get_current_version():
    """Read current version from VERSION.txt"""
    version_file = Path(__file__).parent / "VERSION.txt"
    if version_file.exists():
        try:
            with open(version_file, 'r') as f:
                version = f.read().strip()
                return version
        except:
            pass
    return "1.0.0"  # Default version


def compare_versions(current, latest):
    """
    Compare version numbers.
    Returns: -1 if current < latest, 0 if equal, 1 if current > latest
    """
    def version_tuple(v):
        # Remove 'v' prefix if present
        v = v.lstrip('v')
        # Split by dots and convert to integers
        parts = []
        for part in v.split('.'):
            try:
                parts.append(int(part))
            except:
                parts.append(0)
        # Pad with zeros to ensure same length
        while len(parts) < 3:
            parts.append(0)
        return tuple(parts)
    
    current_tuple = version_tuple(current)
    latest_tuple = version_tuple(latest)
    
    if current_tuple < latest_tuple:
        return -1
    elif current_tuple > latest_tuple:
        return 1
    else:
        return 0


def check_for_updates():
    """
    Check GitHub API for latest release.
    
    Returns:
        dict with keys: 'available', 'current_version', 'latest_version', 'release_name', 'release_notes', 'download_url'
        or None if check failed
    """
    try:
        import urllib.request
        import urllib.error
        
        # Make API request
        req = urllib.request.Request(GITHUB_API_URL)
        req.add_header('User-Agent', 'Hull-Baseplate-Pipeline-Updater')
        
        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode())
        
        current_version = get_current_version()
        latest_version = data.get('tag_name', '').lstrip('v')
        release_name = data.get('name', '')
        release_notes = data.get('body', '')
        
        # Get download URL from assets
        download_url = None
        if 'assets' in data and len(data['assets']) > 0:
            # Look for ZIP file
            for asset in data['assets']:
                if asset.get('content_type') == 'application/zip' or asset.get('name', '').endswith('.zip'):
                    download_url = asset.get('browser_download_url')
                    break
            # If no ZIP found, use first asset
            if not download_url and len(data['assets']) > 0:
                download_url = data['assets'][0].get('browser_download_url')
        
        # Fallback: Use GitHub's automatic source code ZIP if no assets found
        # GitHub always provides zipball_url for source code archives
        if not download_url and 'zipball_url' in data:
            download_url = data['zipball_url']
        
        # Compare versions
        version_comparison = compare_versions(current_version, latest_version)
        update_available = version_comparison < 0
        
        return {
            'available': update_available,
            'current_version': current_version,
            'latest_version': latest_version,
            'release_name': release_name,
            'release_notes': release_notes,
            'download_url': download_url,
            'api_data': data
        }
        
    except Exception as e:
        print(f"[ERROR] Failed to check for updates: {e}")
        return None


def backup_current_files(script_dir):
    """Create backup of current installation"""
    try:
        timestamp = time.strftime("%Y%m%d_%H%M%S")
        backup_dir = os.path.join(script_dir, f"backup_{timestamp}")
        os.makedirs(backup_dir, exist_ok=True)
        
        # Files to backup (exclude venv, backups, and output folders)
        exclude_dirs = {'venv', '__pycache__', '.git', 'backup_'}
        exclude_extensions = {'.pyc', '.pyo'}
        
        backed_up_files = []
        for root, dirs, files in os.walk(script_dir):
            # Filter out excluded directories
            dirs[:] = [d for d in dirs if not any(d.startswith(ex) for ex in exclude_dirs)]
            
            for file in files:
                if any(file.endswith(ext) for ext in exclude_extensions):
                    continue
                
                src_path = os.path.join(root, file)
                rel_path = os.path.relpath(src_path, script_dir)
                dst_path = os.path.join(backup_dir, rel_path)
                
                # Create destination directory
                os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                
                # Copy file
                shutil.copy2(src_path, dst_path)
                backed_up_files.append(rel_path)
        
        return backup_dir, backed_up_files
    except Exception as e:
        print(f"[ERROR] Failed to create backup: {e}")
        return None, []


def download_update(download_url, output_path=None):
    """Download update ZIP from GitHub"""
    try:
        import urllib.request
        
        if output_path is None:
            output_path = os.path.join(tempfile.gettempdir(), f"update_{int(time.time())}.zip")
        
        print(f"[INFO] Downloading update from: {download_url}")
        print(f"[INFO] Saving to: {output_path}")
        
        # Download file
        req = urllib.request.Request(download_url)
        req.add_header('User-Agent', 'Hull-Baseplate-Pipeline-Updater')
        
        with urllib.request.urlopen(req, timeout=60) as response:
            total_size = int(response.headers.get('Content-Length', 0))
            downloaded = 0
            
            with open(output_path, 'wb') as f:
                while True:
                    chunk = response.read(8192)
                    if not chunk:
                        break
                    f.write(chunk)
                    downloaded += len(chunk)
                    if total_size > 0:
                        percent = (downloaded / total_size) * 100
                        print(f"\r[INFO] Download progress: {percent:.1f}%", end='', flush=True)
            
            print()  # New line after progress
        
        print(f"[OK] Download complete: {output_path}")
        return output_path
        
    except Exception as e:
        print(f"[ERROR] Failed to download update: {e}")
        return None


def install_update(zip_path, script_dir, preserve_files=None):
    """
    Extract and install update files.
    
    Args:
        zip_path: Path to downloaded ZIP file
        script_dir: Directory where application is installed
        preserve_files: List of files/patterns to preserve (e.g., ['venv', 'config.json'])
    
    Returns:
        True if successful, False otherwise
    """
    if preserve_files is None:
        preserve_files = ['venv', 'config.json', 'backup_']
    
    try:
        print(f"[INFO] Installing update from: {zip_path}")
        
        # Create temp directory for extraction
        with tempfile.TemporaryDirectory() as temp_dir:
            # Extract ZIP
            print(f"[INFO] Extracting update...")
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(temp_dir)
            
            # Find the root directory in the extracted files
            extracted_files = os.listdir(temp_dir)
            if len(extracted_files) == 1 and os.path.isdir(os.path.join(temp_dir, extracted_files[0])):
                # ZIP contains a single directory (common for GitHub releases)
                extract_root = os.path.join(temp_dir, extracted_files[0])
            else:
                # Files are directly in temp_dir
                extract_root = temp_dir
            
            # Copy files from extracted directory to script directory
            print(f"[INFO] Installing files...")
            installed_files = []
            
            for root, dirs, files in os.walk(extract_root):
                # Filter out excluded directories
                dirs[:] = [d for d in dirs if not any(d.startswith(ex) for ex in preserve_files)]
                
                for file in files:
                    # Skip certain files
                    if file.endswith('.pyc') or file.endswith('.pyo'):
                        continue
                    
                    src_path = os.path.join(root, file)
                    rel_path = os.path.relpath(src_path, extract_root)
                    dst_path = os.path.join(script_dir, rel_path)
                    
                    # Skip if file should be preserved
                    should_preserve = False
                    for preserve_pattern in preserve_files:
                        if preserve_pattern in rel_path or preserve_pattern in file:
                            should_preserve = True
                            break
                    
                    if should_preserve and os.path.exists(dst_path):
                        print(f"[INFO] Preserving existing file: {rel_path}")
                        continue
                    
                    # Create destination directory
                    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                    
                    # Copy file
                    shutil.copy2(src_path, dst_path)
                    installed_files.append(rel_path)
            
            print(f"[OK] Installed {len(installed_files)} files")
            
            # Update VERSION.txt if it was updated
            # Try to find version from release info or keep current
            return True
            
    except Exception as e:
        print(f"[ERROR] Failed to install update: {e}")
        return False


def rollback_update(backup_dir, script_dir):
    """Restore previous version from backup"""
    try:
        print(f"[INFO] Rolling back to previous version from: {backup_dir}")
        
        if not os.path.exists(backup_dir):
            print(f"[ERROR] Backup directory not found: {backup_dir}")
            return False
        
        # Restore files from backup
        restored_files = []
        for root, dirs, files in os.walk(backup_dir):
            for file in files:
                src_path = os.path.join(root, file)
                rel_path = os.path.relpath(src_path, backup_dir)
                dst_path = os.path.join(script_dir, rel_path)
                
                # Create destination directory
                os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                
                # Restore file
                shutil.copy2(src_path, dst_path)
                restored_files.append(rel_path)
        
        print(f"[OK] Restored {len(restored_files)} files from backup")
        return True
        
    except Exception as e:
        print(f"[ERROR] Failed to rollback update: {e}")
        return False


def update_version_file(script_dir, new_version):
    """Update VERSION.txt with new version"""
    try:
        version_file = os.path.join(script_dir, "VERSION.txt")
        with open(version_file, 'w') as f:
            f.write(new_version)
        print(f"[OK] Updated VERSION.txt to {new_version}")
        return True
    except Exception as e:
        print(f"[ERROR] Failed to update VERSION.txt: {e}")
        return False


def perform_update(download_url, script_dir, log_callback=None, new_version=None):
    """
    Perform complete update process: backup, download, install, verify.
    
    Args:
        download_url: URL to download update ZIP
        script_dir: Directory where application is installed
        log_callback: Optional callback function for logging (takes message string)
        new_version: Optional new version string to update VERSION.txt
    
    Returns:
        dict with keys: 'success', 'backup_dir', 'error_message'
    """
    def log(msg):
        if log_callback:
            log_callback(msg)
        else:
            print(msg)
    
    backup_dir = None
    try:
        # Step 1: Create backup
        log("[UPDATE] Step 1: Creating backup...")
        backup_dir, backed_up_files = backup_current_files(script_dir)
        if not backup_dir:
            return {'success': False, 'backup_dir': None, 'error_message': 'Failed to create backup'}
        log(f"[OK] Backup created: {backup_dir} ({len(backed_up_files)} files)")
        
        # Step 2: Download update
        log("[UPDATE] Step 2: Downloading update...")
        zip_path = download_update(download_url)
        if not zip_path:
            return {'success': False, 'backup_dir': backup_dir, 'error_message': 'Failed to download update'}
        
        # Step 3: Install update
        log("[UPDATE] Step 3: Installing update...")
        success = install_update(zip_path, script_dir, preserve_files=['venv', 'config.json', 'backup_'])
        if not success:
            # Rollback on failure
            log("[UPDATE] Installation failed, rolling back...")
            rollback_update(backup_dir, script_dir)
            return {'success': False, 'backup_dir': backup_dir, 'error_message': 'Failed to install update'}
        
        # Step 4: Update VERSION.txt if new version provided
        if new_version:
            log(f"[UPDATE] Step 4: Updating version to {new_version}...")
            update_version_file(script_dir, new_version)
        
        # Step 5: Cleanup
        try:
            os.remove(zip_path)
        except:
            pass
        
        log("[OK] Update installed successfully!")
        return {'success': True, 'backup_dir': backup_dir, 'error_message': None}
        
    except Exception as e:
        log(f"[ERROR] Update process failed: {e}")
        # Rollback on exception
        if backup_dir:
            try:
                log("[UPDATE] Rolling back due to error...")
                rollback_update(backup_dir, script_dir)
            except:
                pass
        return {'success': False, 'backup_dir': backup_dir, 'error_message': str(e)}


if __name__ == "__main__":
    # Test update check
    print("Checking for updates...")
    result = check_for_updates()
    if result:
        print(f"Current version: {result['current_version']}")
        print(f"Latest version: {result['latest_version']}")
        print(f"Update available: {result['available']}")
        if result['available']:
            print(f"Release name: {result['release_name']}")
            print(f"Download URL: {result['download_url']}")
    else:
        print("Failed to check for updates")

