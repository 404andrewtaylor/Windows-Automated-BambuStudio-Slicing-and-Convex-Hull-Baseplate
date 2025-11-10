#!/usr/bin/env python3
"""
Hull Baseplate Pipeline - Desktop GUI Application (Nov 10, 2025 Version)

A simplified desktop application for batch processing STL files.
Automatically processes all STL files in a folder sequentially.

Features (Nov 10, 2025):
- Simplified interface: Only input folder selection
- Automatic output folder generation: {input_folder}\slicer_output
- Automatic cleanup: Deletes .3mf and .gcode.3mf files from input folder
- Batch processing: Processes all STL files in folder sequentially
- No intermediate files: Only keeps final .gcode.3mf files
"""

import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
import os
import sys
import threading
import subprocess
import time
from pathlib import Path
import json
import shutil
import glob
from auto_update import check_for_updates, perform_update, get_current_version

class HullBaseplateApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Hull Baseplate Pipeline (Nov 10, 2025 - Simplified)")
        self.root.geometry("1200x800")
        self.root.resizable(True, True)
        self.root.minsize(1000, 700)
        
        # Set application icon (if available)
        try:
            self.root.iconbitmap("icon.ico")
        except:
            pass
        
        # Configuration
        self.config = self.load_config()
        self.input_folder_path = ""
        self.output_folder_path = ""
        
        # Hardcoded settings (simplified version)
        self.keep_intermediate_files = False  # Always False
        self.auto_output_folder = True  # Always True
        self.create_subfolders = False  # Always False
        
        # Create main container
        self.main_frame = ttk.Frame(root, padding="20")
        self.main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configure grid weights
        root.columnconfigure(0, weight=1)
        root.rowconfigure(0, weight=1)
        self.main_frame.columnconfigure(0, weight=1)
        self.main_frame.rowconfigure(1, weight=1)
        
        # Create notebook for pages
        self.notebook = ttk.Notebook(self.main_frame)
        self.notebook.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(0, 20))
        
        # Create pages
        self.create_setup_page()
        self.create_file_selection_page()
        self.create_progress_page()
        
        # Status bar
        self.status_var = tk.StringVar(value="Ready")
        self.status_bar = ttk.Label(self.main_frame, textvariable=self.status_var, relief=tk.SUNKEN, anchor=tk.W)
        self.status_bar.grid(row=1, column=0, sticky=(tk.W, tk.E), pady=(0, 10))
        
        # Add Help menu with Check for Updates
        self.create_menu_bar()
        
        # Start with setup page
        self.notebook.select(0)
        
        # Log version on startup (test update feature - v1.0.1)
        # This message will appear in the log when you go to the progress page
        self.root.after(100, lambda: self._log_startup_version())
    
    def create_menu_bar(self):
        """Create menu bar with Help menu including Check for Updates."""
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)
        
        # Help menu
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="Check for Updates", command=self.check_for_updates)
        help_menu.add_separator()
        help_menu.add_command(label="About", command=self.show_about)
    
    def show_about(self):
        """Show about dialog with version information."""
        current_version = get_current_version()
        about_text = f"""Hull Baseplate Pipeline (Nov 10, 2025 - Simplified)

Version: {current_version}

A simplified desktop application for batch processing STL files.
Automatically processes all STL files in a folder sequentially.

© 2025"""
        messagebox.showinfo("About", about_text)
    
    def check_for_updates(self):
        """Check for updates from GitHub."""
        self.log("Checking for updates...")
        self.status_var.set("Checking for updates...")
        
        # Run update check in separate thread
        update_thread = threading.Thread(target=self._check_for_updates_thread)
        update_thread.daemon = True
        update_thread.start()
    
    def _check_for_updates_thread(self):
        """Check for updates in background thread."""
        try:
            result = check_for_updates()
            
            if result is None:
                self.root.after(0, lambda: messagebox.showerror("Update Check Failed", 
                    "Could not check for updates. Please check your internet connection."))
                self.root.after(0, lambda: self.status_var.set("Ready"))
                return
            
            current_version = result['current_version']
            latest_version = result['latest_version']
            update_available = result['available']
            
            if update_available:
                # Show update dialog
                self.root.after(0, lambda: self._show_update_dialog(result))
            else:
                self.root.after(0, lambda: messagebox.showinfo("No Updates Available", 
                    f"You are running the latest version ({current_version})."))
                self.root.after(0, lambda: self.status_var.set("Ready"))
                
        except Exception as e:
            self.log(f"Error checking for updates: {e}")
            self.root.after(0, lambda: messagebox.showerror("Update Check Failed", 
                f"Error checking for updates: {str(e)}"))
            self.root.after(0, lambda: self.status_var.set("Ready"))
    
    def _show_update_dialog(self, update_info):
        """Show update available dialog."""
        dialog = tk.Toplevel(self.root)
        dialog.title("Update Available")
        dialog.geometry("600x400")
        dialog.transient(self.root)
        dialog.grab_set()
        
        # Center dialog
        dialog.update_idletasks()
        x = (dialog.winfo_screenwidth() // 2) - (dialog.winfo_width() // 2)
        y = (dialog.winfo_screenheight() // 2) - (dialog.winfo_height() // 2)
        dialog.geometry(f"+{x}+{y}")
        
        # Title
        title_label = ttk.Label(dialog, text="Update Available!", font=("Arial", 14, "bold"))
        title_label.pack(pady=10)
        
        # Version info
        version_frame = ttk.Frame(dialog)
        version_frame.pack(pady=10)
        ttk.Label(version_frame, text=f"Current Version: {update_info['current_version']}").pack()
        ttk.Label(version_frame, text=f"Latest Version: {update_info['latest_version']}").pack()
        
        # Release notes
        notes_label = ttk.Label(dialog, text="Release Notes:", font=("Arial", 10, "bold"))
        notes_label.pack(pady=(10, 5))
        
        notes_text = scrolledtext.ScrolledText(dialog, height=10, width=70, wrap=tk.WORD)
        notes_text.pack(padx=10, pady=5, fill=tk.BOTH, expand=True)
        notes_text.insert("1.0", update_info.get('release_notes', 'No release notes available.'))
        notes_text.config(state=tk.DISABLED)
        
        # Buttons
        button_frame = ttk.Frame(dialog)
        button_frame.pack(pady=10)
        
        def on_update():
            dialog.destroy()
            self._perform_update(update_info)
        
        ttk.Button(button_frame, text="Update Now", command=on_update).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Later", command=dialog.destroy).pack(side=tk.LEFT, padx=5)
    
    def _perform_update(self, update_info):
        """Perform the update process."""
        if not update_info.get('download_url'):
            messagebox.showerror("Update Failed", "No download URL available for this update.")
            return
        
        # Confirm update
        response = messagebox.askyesno("Confirm Update", 
            "This will download and install the update.\n"
            "A backup will be created automatically.\n\n"
            "Continue?")
        if not response:
            return
        
        # Go to progress page and show update progress
        self.go_to_progress()
        self.log_text.delete(1.0, tk.END)
        self.log("Starting update process...")
        self.status_var.set("Updating...")
        
        # Run update in separate thread
        update_thread = threading.Thread(target=self._perform_update_thread, args=(update_info,))
        update_thread.daemon = True
        update_thread.start()
    
    def _perform_update_thread(self, update_info):
        """Perform update in background thread."""
        try:
            script_dir = os.path.dirname(os.path.abspath(__file__))
            download_url = update_info['download_url']
            
            def log_callback(msg):
                self.log(msg)
            
            self.log(f"Downloading update from GitHub...")
            result = perform_update(download_url, script_dir, log_callback=log_callback, new_version=update_info['latest_version'])
            
            if result['success']:
                self.log("Update completed successfully!")
                self.root.after(0, lambda: messagebox.showinfo("Update Complete", 
                    "Update installed successfully!\n\nPlease restart the application to use the new version."))
                self.root.after(0, lambda: self.status_var.set("Update complete - Please restart"))
            else:
                self.log(f"Update failed: {result.get('error_message', 'Unknown error')}")
                self.root.after(0, lambda: messagebox.showerror("Update Failed", 
                    f"Update failed: {result.get('error_message', 'Unknown error')}\n\n"
                    f"Your previous version has been restored from backup."))
                self.root.after(0, lambda: self.status_var.set("Update failed"))
                
        except Exception as e:
            self.log(f"Error during update: {e}")
            self.root.after(0, lambda: messagebox.showerror("Update Error", 
                f"An error occurred during update: {str(e)}"))
            self.root.after(0, lambda: self.status_var.set("Update error"))
    
    def load_config(self):
        """Load configuration from config.json if it exists."""
        config_path = "config.json"
        if os.path.exists(config_path):
            try:
                with open(config_path, 'r') as f:
                    return json.load(f)
            except:
                pass
        return {}
    
    def create_scrollable_frame(self, parent):
        """
        Create a scrollable frame with canvas and scrollbars.
        Returns the inner frame where content should be placed.
        """
        # Create canvas with scrollbars
        canvas = tk.Canvas(parent)
        scrollbar_v = ttk.Scrollbar(parent, orient="vertical", command=canvas.yview)
        scrollbar_h = ttk.Scrollbar(parent, orient="horizontal", command=canvas.xview)
        
        # Inner frame that will hold all content
        scrollable_frame = ttk.Frame(canvas)
        
        # Configure canvas scrolling
        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )
        
        # Create window in canvas for the scrollable frame
        canvas_window = canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        
        # Configure canvas scroll command
        canvas.configure(yscrollcommand=scrollbar_v.set, xscrollcommand=scrollbar_h.set)
        
        # Pack scrollbars and canvas
        scrollbar_v.pack(side="right", fill="y")
        scrollbar_h.pack(side="bottom", fill="x")
        canvas.pack(side="left", fill="both", expand=True)
        
        # Bind mousewheel to canvas and scrollable frame (Windows)
        def on_mousewheel(event):
            # Scroll the canvas when mouse wheel is used
            canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")
        
        # Bind mousewheel to both canvas and scrollable frame
        # This ensures scrolling works when hovering over any part of the content
        def bind_mousewheel(widget):
            widget.bind("<MouseWheel>", on_mousewheel)  # Windows
            widget.bind("<Button-4>", lambda e: canvas.yview_scroll(-1, "units"))  # Linux
            widget.bind("<Button-5>", lambda e: canvas.yview_scroll(1, "units"))  # Linux
        
        # Bind to canvas
        bind_mousewheel(canvas)
        # Bind to scrollable frame
        bind_mousewheel(scrollable_frame)
        
        # Also bind to the root window to catch events anywhere in the application
        def on_root_mousewheel(event):
            # Only scroll if mouse is over this canvas area
            try:
                if canvas.winfo_containing(event.x_root, event.y_root):
                    canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")
            except:
                pass  # Ignore errors if widget is destroyed
        
        # Bind to root window
        self.root.bind("<MouseWheel>", on_root_mousewheel)
        
        # Update scroll region when content changes
        def update_scroll_region(event=None):
            canvas.update_idletasks()
            canvas.configure(scrollregion=canvas.bbox("all"))
        
        scrollable_frame.bind("<Configure>", update_scroll_region)
        
        # Make canvas window expand to fill canvas width
        def on_canvas_configure(event):
            canvas_width = event.width
            canvas.itemconfig(canvas_window, width=canvas_width)
        
        canvas.bind("<Configure>", on_canvas_configure)
        
        return scrollable_frame, canvas
    
    def create_setup_page(self):
        """Create the Bambu Studio setup instructions page with deletion warning."""
        setup_frame = ttk.Frame(self.notebook)
        self.notebook.add(setup_frame, text="1. Setup")
        
        # Create scrollable frame
        scrollable_frame, canvas = self.create_scrollable_frame(setup_frame)
        
        # Title
        title_label = ttk.Label(scrollable_frame, text="Bambu Studio Setup", font=("Arial", 16, "bold"))
        title_label.pack(pady=(20, 10))
        
        # Instructions container
        instructions_frame = ttk.Frame(scrollable_frame)
        instructions_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)
        
        # ⚠️ PROMINENT WARNING AT TOP
        warning_frame = ttk.LabelFrame(instructions_frame, text="⚠️ IMPORTANT WARNING", padding="15")
        warning_frame.pack(fill=tk.X, pady=(0, 20))
        
        warning_text = """
⚠️ FILE DELETION WARNING ⚠️

This application will DELETE all .3mf and .gcode.3mf files in your selected input folder.

This deletion is necessary to prevent errors when Bambu Studio tries to save files that already exist.
The application will:
• Delete .3mf and .gcode.3mf files BEFORE processing starts
• Delete .3mf and .gcode.3mf files AFTER processing completes (if successful)

ONLY .stl files will be preserved in the input folder.
All final output files will be saved to: {input_folder}\\slicer_output

⚠️ Make sure you have backups of any important .3mf or .gcode.3mf files before proceeding!
        """
        
        warning_label = ttk.Label(warning_frame, text=warning_text, 
                                 justify=tk.LEFT, wraplength=1000,
                                 foreground="red", font=("Arial", 10, "bold"))
        warning_label.pack(anchor=tk.W)
        
        # Instructions text
        instructions_text = """
IMPORTANT: Before running the pipeline, you MUST complete this Bambu Studio setup:

1. OPEN BAMBU STUDIO
   • Launch Bambu Studio on your computer
   • If not installed, download from: https://bambulab.com/en/download/studio

2. CREATE A NEW PROJECT
   • Click File → New Project (or press Ctrl+N)
   • This ensures you start with a clean project

3. CONFIGURE YOUR PRINTER SETTINGS
   • Select your printer model from the dropdown
   • Choose your filament type and color
   • Set your preferred print settings:
     - Layer height (e.g., 0.2mm)
     - Infill percentage (e.g., 20%)
     - Support settings (if needed)
     - Any other settings you want to use

4. SAVE THE EMPTY PROJECT
   • Click File → Save As (or press Ctrl+S)
   • Save it anywhere (location doesn't matter)
   • This ensures Bambu Studio opens with your preferred settings

WHY THIS IS CRITICAL:
The automation will open Bambu Studio and use whatever settings are currently active.
Without this setup, it will use default settings that may not be suitable for your printer/filament.

Once you've completed these steps, click "Next" to continue.
        """
        
        instructions_label = ttk.Label(instructions_frame, text=instructions_text, 
                                     justify=tk.LEFT, wraplength=1000)
        instructions_label.pack(anchor=tk.W, pady=10)
        
        # Checkbox for completion
        self.setup_complete = tk.BooleanVar()
        setup_checkbox = ttk.Checkbutton(instructions_frame, 
                                       text="I have completed the Bambu Studio setup above and understand the file deletion warning",
                                       variable=self.setup_complete)
        setup_checkbox.pack(anchor=tk.W, pady=10)
        
        # Next button
        next_button = ttk.Button(instructions_frame, text="Next →", 
                               command=self.go_to_file_selection,
                               state=tk.DISABLED)
        next_button.pack(anchor=tk.E, pady=20)
        
        # Enable next button when checkbox is checked
        def on_checkbox_change():
            if self.setup_complete.get():
                next_button.config(state=tk.NORMAL)
            else:
                next_button.config(state=tk.DISABLED)
        
        self.setup_complete.trace('w', lambda *args: on_checkbox_change())
    
    def create_file_selection_page(self):
        """Create the simplified file selection page (only input folder)."""
        file_frame = ttk.Frame(self.notebook)
        self.notebook.add(file_frame, text="2. Select Folder")
        
        # Create scrollable frame
        scrollable_frame, canvas = self.create_scrollable_frame(file_frame)
        
        # Title
        title_label = ttk.Label(scrollable_frame, text="Select Input Folder", font=("Arial", 16, "bold"))
        title_label.pack(pady=(20, 10))
        
        # Main content frame
        content_frame = ttk.Frame(scrollable_frame)
        content_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)
        
        # Input folder selection
        folder_frame = ttk.LabelFrame(content_frame, text="Input Folder (Contains STL Files)", padding="10")
        folder_frame.pack(fill=tk.X, pady=(0, 20))
        
        self.folder_path_var = tk.StringVar()
        self.folder_entry = ttk.Entry(folder_frame, textvariable=self.folder_path_var, state="readonly")
        self.folder_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10))
        
        self.folder_button = ttk.Button(folder_frame, text="Browse...", command=self.select_input_folder)
        self.folder_button.pack(side=tk.RIGHT)
        
        # Info frame
        info_frame = ttk.LabelFrame(content_frame, text="Output Information", padding="10")
        info_frame.pack(fill=tk.X, pady=(0, 20))
        
        info_text = """
Output folder will be automatically created at: {input_folder}\\slicer_output

All STL files in the input folder will be processed sequentially.
Only final .gcode.3mf files will be saved (no intermediate files).
All .3mf and .gcode.3mf files in the input folder will be deleted before and after processing.
        """
        
        info_label = ttk.Label(info_frame, text=info_text, 
                              justify=tk.LEFT, foreground="gray")
        info_label.pack(anchor=tk.W)
        
        # Button frame
        button_frame = ttk.Frame(content_frame)
        button_frame.pack(fill=tk.X, pady=20)
        
        # Back button
        back_button = ttk.Button(button_frame, text="← Back", command=self.go_to_setup)
        back_button.pack(side=tk.LEFT)
        
        # Run button
        self.run_button = ttk.Button(button_frame, text="Run Pipeline", 
                                   command=self.run_pipeline, state=tk.DISABLED)
        self.run_button.pack(side=tk.RIGHT)
        
        # Enable run button when folder is selected
        def on_path_change():
            if self.folder_path_var.get() and os.path.exists(self.folder_path_var.get()):
                self.run_button.config(state=tk.NORMAL)
            else:
                self.run_button.config(state=tk.DISABLED)
        
        self.folder_path_var.trace('w', lambda *args: on_path_change())
    
    def create_progress_page(self):
        """Create the progress tracking page."""
        progress_frame = ttk.Frame(self.notebook)
        self.notebook.add(progress_frame, text="3. Progress")
        
        # Title
        title_label = ttk.Label(progress_frame, text="Pipeline Progress", font=("Arial", 16, "bold"))
        title_label.pack(pady=(20, 10))
        
        # Progress bar
        self.progress_var = tk.DoubleVar()
        self.progress_bar = ttk.Progressbar(progress_frame, variable=self.progress_var, 
                                          maximum=100, length=600)
        self.progress_bar.pack(pady=20)
        
        # Status label
        self.status_label = ttk.Label(progress_frame, text="Ready to start...", 
                                    font=("Arial", 12))
        self.status_label.pack(pady=10)
        
        # Log text area
        log_frame = ttk.LabelFrame(progress_frame, text="Log Output", padding="10")
        log_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)
        
        self.log_text = scrolledtext.ScrolledText(log_frame, height=20, width=100)
        self.log_text.pack(fill=tk.BOTH, expand=True)
        
        # Button frame
        button_frame = ttk.Frame(progress_frame)
        button_frame.pack(fill=tk.X, padx=20, pady=10)
        
        # Back button
        back_button = ttk.Button(button_frame, text="← Back to Folder Selection", 
                               command=self.go_to_file_selection)
        back_button.pack(side=tk.LEFT)
        
        # Open output folder button
        self.open_folder_button = ttk.Button(button_frame, text="Open Output Folder", 
                                           command=self.open_output_folder, state=tk.DISABLED)
        self.open_folder_button.pack(side=tk.RIGHT)
    
    def select_input_folder(self):
        """Open folder dialog to select input directory."""
        folder_path = filedialog.askdirectory(title="Select Input Folder")
        if folder_path:
            self.folder_path_var.set(folder_path)
            self.input_folder_path = folder_path
            
            # Count STL files in folder (remove duplicates - Windows is case-insensitive)
            stl_files = glob.glob(os.path.join(folder_path, "*.stl"))
            stl_files.extend(glob.glob(os.path.join(folder_path, "*.STL")))
            # Remove duplicates
            unique_files = {}
            for f in stl_files:
                normalized = os.path.normpath(os.path.normcase(f))
                if normalized not in unique_files:
                    unique_files[normalized] = f
            stl_files = list(unique_files.values())
            stl_files.sort()
            count = len(stl_files)
            
            self.log(f"Selected input folder: {folder_path}")
            self.log(f"Found {count} STL file(s) in folder")
    
    def go_to_setup(self):
        """Navigate to setup page."""
        self.notebook.select(0)
    
    def go_to_file_selection(self):
        """Navigate to file selection page."""
        self.notebook.select(1)
    
    def go_to_progress(self):
        """Navigate to progress page."""
        self.notebook.select(2)
    
    def _log_startup_version(self):
        """Log version on startup (test update feature)."""
        current_version = get_current_version()
        self.log(f"=== Hull Baseplate Pipeline - Version {current_version} ===")
        self.log("Application ready. Use Help → Check for Updates to check for new versions.")
    
    def log(self, message):
        """Add message to log text area."""
        if hasattr(self, 'log_text') and self.log_text.winfo_exists():
            self.log_text.insert(tk.END, f"{time.strftime('%H:%M:%S')} - {message}\n")
            self.log_text.see(tk.END)
            self.root.update_idletasks()
    
    def update_progress(self, value, status=""):
        """Update progress bar and status."""
        self.progress_var.set(value)
        if status:
            self.status_label.config(text=status)
        self.root.update_idletasks()
    
    def _get_auto_output_folder(self):
        """Generate automatic output folder path."""
        output_folder = os.path.join(self.input_folder_path, "slicer_output")
        return output_folder
    
    def _delete_non_stl_files(self, folder_path):
        """
        Delete all .3mf and .gcode.3mf files from the input folder root.
        Only deletes files directly in the folder, not subdirectories.
        
        Args:
            folder_path: Path to folder to clean
            
        Returns:
            Number of files deleted
        """
        deleted_count = 0
        
        try:
            # Get all files in folder root (not subdirectories)
            if not os.path.exists(folder_path):
                self.log(f"Warning: Folder does not exist: {folder_path}")
                return 0
            
            # List all files in folder root
            for filename in os.listdir(folder_path):
                file_path = os.path.join(folder_path, filename)
                
                # Only process files (not directories)
                if os.path.isfile(file_path):
                    # Check if file is .3mf or .gcode.3mf
                    if filename.lower().endswith('.3mf') or filename.lower().endswith('.gcode.3mf'):
                        try:
                            os.remove(file_path)
                            deleted_count += 1
                            self.log(f"Deleted: {filename}")
                        except Exception as e:
                            self.log(f"Warning: Could not delete {filename}: {e}")
            
            if deleted_count > 0:
                self.log(f"Deleted {deleted_count} file(s) from input folder")
            else:
                self.log("No .3mf or .gcode.3mf files found to delete")
            
            return deleted_count
            
        except Exception as e:
            self.log(f"Error deleting files: {e}")
            return deleted_count
    
    def run_pipeline(self):
        """Run the hull baseplate pipeline."""
        # Determine output folder (auto-generated)
        self.output_folder_path = self._get_auto_output_folder()
        # Create output folder if it doesn't exist
        os.makedirs(self.output_folder_path, exist_ok=True)
        self.log(f"Auto-generated output folder: {self.output_folder_path}")
        
        # Validate input
        if not self.input_folder_path or not os.path.exists(self.input_folder_path):
            messagebox.showerror("Error", "Please select a valid input folder.")
            return
        
        # Go to progress page
        self.go_to_progress()
        
        # Clear log
        self.log_text.delete(1.0, tk.END)
        
        # Disable run button
        self.run_button.config(state=tk.DISABLED)
        
        # Run pipeline in separate thread
        pipeline_thread = threading.Thread(target=self._run_pipeline_thread)
        pipeline_thread.daemon = True
        pipeline_thread.start()
    
    def _run_pipeline_thread(self):
        """Run the pipeline in a separate thread."""
        try:
            # Delete non-STL files BEFORE processing
            self.log("=" * 60)
            self.log("Cleaning input folder (deleting .3mf and .gcode.3mf files)...")
            self.log("=" * 60)
            self._delete_non_stl_files(self.input_folder_path)
            self.log("")
            
            # Process all STL files
            self._process_folder()
        
        except Exception as e:
            self.log(f"Error: {str(e)}")
            self.update_progress(0, "Error occurred!")
            self.root.after(0, lambda: messagebox.showerror("Error", f"An error occurred: {str(e)}"))
        
        finally:
            # Re-enable buttons in main thread
            self.root.after(0, lambda: self.run_button.config(state=tk.NORMAL))
            self.root.after(0, lambda: self.open_folder_button.config(state=tk.NORMAL))
    
    def _process_folder(self):
        """Process all STL files in a folder sequentially."""
        # Find all STL files in the input folder (remove duplicates - Windows is case-insensitive)
        stl_files = glob.glob(os.path.join(self.input_folder_path, "*.stl"))
        stl_files.extend(glob.glob(os.path.join(self.input_folder_path, "*.STL")))
        # Remove duplicates
        unique_files = {}
        for f in stl_files:
            normalized = os.path.normpath(os.path.normcase(f))
            if normalized not in unique_files:
                unique_files[normalized] = f
        stl_files = list(unique_files.values())
        stl_files.sort()  # Sort for consistent order
        
        if not stl_files:
            self.root.after(0, lambda: messagebox.showerror("Error", "No STL files found in the selected folder."))
            return
        
        total_files = len(stl_files)
        self.log(f"Found {total_files} STL file(s) to process")
        self.log("=" * 60)
        
        # Check if full_pipeline.py exists
        script_dir = os.path.dirname(os.path.abspath(__file__))
        pipeline_script = os.path.join(script_dir, "full_pipeline.py")
        
        if not os.path.exists(pipeline_script):
            raise FileNotFoundError("full_pipeline.py not found in the application directory")
        
        # Determine which Python to use (prefer virtual environment)
        python_exe = self._get_python_executable(script_dir)
        
        # Verify dependencies are installed before starting batch processing
        self.log("Verifying dependencies before batch processing...")
        if not self._verify_dependencies(python_exe):
            self.log("ERROR: Critical dependencies are missing. Batch processing may fail.")
            self.root.after(0, lambda: messagebox.showwarning("Dependency Warning", 
                "Some critical dependencies could not be installed.\nBatch processing may fail. Check the log for details."))
        
        successful_files = 0
        failed_files = 0
        
        # Process each file sequentially
        for idx, stl_file in enumerate(stl_files, 1):
            file_name = os.path.basename(stl_file)
            self.log("")
            self.log("=" * 60)
            self.log(f"Processing file {idx}/{total_files}: {file_name}")
            self.log("=" * 60)
            
            # Calculate progress: reserve 5% for initialization, 95% for files
            progress_start = 5 + (idx - 1) * (95 / total_files)
            progress_end = 5 + idx * (95 / total_files)
            
            self.update_progress(progress_start, f"Processing {file_name} ({idx}/{total_files})...")
            
            # Prepare command
            cmd = [python_exe, pipeline_script, stl_file]
            
            self.log(f"Running command: {' '.join(cmd)}")
            
            # Run the pipeline
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                cwd=script_dir
            )
            
            # Read output line by line
            for line in process.stdout:
                line = line.strip()
                if line:
                    self.log(f"  {line}")
            
            # Wait for process to complete
            return_code = process.wait()
            
            if return_code == 0:
                successful_files += 1
                self.log(f"✓ Successfully processed: {file_name}")
                
                # Move final output to specified folder
                self._move_output_files(stl_file)
                
                # Update progress to middle of this file's range
                self.update_progress((progress_start + progress_end) / 2, 
                                    f"Completed {file_name} ({idx}/{total_files})")
            else:
                failed_files += 1
                self.log(f"✗ Failed to process: {file_name} (return code: {return_code})")
        
        # Final summary
        self.log("")
        self.log("=" * 60)
        self.log(f"Batch Processing Complete!")
        self.log(f"  Total files: {total_files}")
        self.log(f"  Successful: {successful_files}")
        self.log(f"  Failed: {failed_files}")
        self.log("=" * 60)
        
        self.update_progress(100, f"Completed {successful_files}/{total_files} files")
        
        # Only clean up if all files processed successfully
        if failed_files == 0:
            # Delete non-STL files AFTER processing (only if successful)
            self.log("")
            self.log("=" * 60)
            self.log("Cleaning input folder (deleting .3mf and .gcode.3mf files)...")
            self.log("=" * 60)
            self._delete_non_stl_files(self.input_folder_path)
            self.log("")
            
            # Schedule success messagebox in main thread
            self.root.after(0, lambda: messagebox.showinfo("Success", 
                             f"All {total_files} file(s) processed successfully!\nCheck the output folder for your files."))
        else:
            # Schedule warning messagebox in main thread
            self.root.after(0, lambda: messagebox.showwarning("Partial Success", 
                                 f"Processed {successful_files}/{total_files} file(s) successfully.\n{failed_files} file(s) failed. Check the log for details.\n\nInput folder was NOT cleaned up due to failures."))
    
    def _move_output_files(self, stl_file_path):
        """Move final output file to the output folder (no intermediate files, no subfolders)."""
        try:
            # Find the generated pipeline folder
            stl_dir = os.path.dirname(stl_file_path)
            stl_name = os.path.splitext(os.path.basename(stl_file_path))[0]
            pipeline_dir = os.path.join(stl_dir, f"{stl_name}_pipeline")
            
            if not os.path.exists(pipeline_dir):
                self.log(f"Warning: Pipeline output directory not found: {pipeline_dir}")
                return
            
            # Find the final output file
            final_output = os.path.join(pipeline_dir, f"{stl_name}_with_hull_baseplate.gcode.3mf")
            
            if not os.path.exists(final_output):
                self.log(f"Warning: Final output file not found: {final_output}")
                return
            
            # Place files directly in output folder (no subfolders)
            output_destination = self.output_folder_path
            self.log(f"Placing final output in: {output_destination}")
            
            # Keep only final output - copy just the final file
            self.log(f"Copying final output to {output_destination}...")
            final_filename = os.path.basename(final_output)
            dest_path = os.path.join(output_destination, final_filename)
            
            # Check for filename conflicts
            if os.path.exists(dest_path):
                # Add number suffix to avoid overwriting
                if final_filename.endswith('.gcode.3mf'):
                    base = final_filename[:-10]  # Remove '.gcode.3mf'
                    ext = '.gcode.3mf'
                else:
                    base, ext = os.path.splitext(final_filename)
                counter = 1
                while os.path.exists(dest_path):
                    new_name = f"{base}_{counter}{ext}"
                    dest_path = os.path.join(output_destination, new_name)
                    counter += 1
                self.log(f"  Warning: File exists, renaming to: {os.path.basename(dest_path)}")
            
            shutil.copy2(final_output, dest_path)
            self.log(f"  Final output copied to: {dest_path}")
            
            # Remove the entire pipeline folder since we only want the final output
            shutil.rmtree(pipeline_dir)
            self.log(f"Pipeline folder removed (only final output kept): {pipeline_dir}")
        
        except Exception as e:
            self.log(f"Error managing output files: {str(e)}")
    
    def _verify_dependencies(self, venv_python):
        """Verify that critical dependencies are installed in the venv."""
        try:
            venv_pip = os.path.join(os.path.dirname(venv_python), "pip.exe")
            
            # Check if pip exists
            if not os.path.exists(venv_pip):
                self.log(f"Error: pip.exe not found at {venv_pip}")
                return False
            
            # List of critical packages to check: (package_name, import_test_command)
            # import_test_command is the Python code to test the import
            critical_packages = [
                ("pyautogui", "import pyautogui"),
                ("pydirectinput", "import pydirectinput"),
                ("numpy-stl", "import stl"),  # numpy-stl provides the 'stl' module
            ]
            
            missing_packages = []
            
            # Check each package individually
            for package_name, import_test in critical_packages:
                result = subprocess.run([venv_python, "-c", import_test], 
                                      capture_output=True, text=True, timeout=5)
                if result.returncode != 0:
                    missing_packages.append((package_name, import_test))
                    self.log(f"Warning: {package_name} module not found or import failed")
                    if result.stderr:
                        self.log(f"  Import error: {result.stderr.strip()}")
            
            # Install any missing packages
            if missing_packages:
                self.log(f"Installing missing packages: {', '.join([p[0] for p in missing_packages])}...")
                failed_installations = []
                
                for package_name, import_test in missing_packages:
                    self.log(f"Installing {package_name}...")
                    result = subprocess.run([venv_pip, "install", package_name], 
                                         capture_output=True, text=True, timeout=120)
                    if result.returncode != 0:
                        self.log(f"Error: Failed to install {package_name}: {result.stderr}")
                        failed_installations.append(package_name)
                    else:
                        # Wait a moment for installation to complete
                        import time
                        time.sleep(1)
                        # Verify installation succeeded by trying to import again
                        verify_result = subprocess.run([venv_python, "-c", import_test], 
                                                      capture_output=True, text=True, timeout=10)
                        if verify_result.returncode == 0:
                            self.log(f"Successfully installed and verified {package_name}")
                        else:
                            error_msg = verify_result.stderr.strip() if verify_result.stderr else "Unknown error"
                            self.log(f"Warning: {package_name} installed but import still fails: {error_msg}")
                            failed_installations.append(package_name)
                
                if failed_installations:
                    self.log(f"Error: Failed to install critical packages: {', '.join(failed_installations)}")
                    return False
                else:
                    self.log("All missing packages installed successfully")
                    return True
            else:
                self.log("All critical dependencies are installed")
                return True
        except subprocess.TimeoutExpired:
            self.log(f"Error: Timeout while verifying/installing dependencies")
            return False
        except Exception as e:
            self.log(f"Warning: Could not verify dependencies: {e}")
            return False
    
    def _get_python_executable(self, script_dir):
        """Get the appropriate Python executable (create venv if needed)."""
        # Check for virtual environment first
        venv_python = os.path.join(script_dir, "venv", "Scripts", "python.exe")
        if os.path.exists(venv_python):
            self.log(f"Using virtual environment Python: {venv_python}")
            self._verify_dependencies(venv_python)
            return venv_python
        
        # Check for venv in current directory
        venv_python = os.path.join(os.getcwd(), "venv", "Scripts", "python.exe")
        if os.path.exists(venv_python):
            self.log(f"Using virtual environment Python: {venv_python}")
            self._verify_dependencies(venv_python)
            return venv_python
        
        # Create virtual environment if it doesn't exist
        self.log("Virtual environment not found. Creating one...")
        if self._create_virtual_environment(script_dir):
            venv_python = os.path.join(script_dir, "venv", "Scripts", "python.exe")
            if os.path.exists(venv_python):
                self.log(f"Using newly created virtual environment: {venv_python}")
                return venv_python
        
        # Fall back to system Python
        self.log(f"Using system Python: {sys.executable}")
        self.log("Warning: Virtual environment not found. Some dependencies may be missing.")
        return sys.executable
    
    def _create_virtual_environment(self, script_dir):
        """Create virtual environment and install dependencies."""
        try:
            self.log("Creating virtual environment...")
            venv_path = os.path.join(script_dir, "venv")
            
            # Create virtual environment
            result = subprocess.run([sys.executable, "-m", "venv", venv_path], 
                                  capture_output=True, text=True)
            if result.returncode != 0:
                self.log(f"Failed to create virtual environment: {result.stderr}")
                return False
            
            self.log("Virtual environment created successfully")
            
            # Install dependencies
            self.log("Installing dependencies...")
            venv_python = os.path.join(venv_path, "Scripts", "python.exe")
            venv_pip = os.path.join(venv_path, "Scripts", "pip.exe")
            
            # Install requirements
            requirements_files = ["requirements.txt", "requirements_gui.txt"]
            for req_file in requirements_files:
                if os.path.exists(req_file):
                    self.log(f"Installing {req_file}...")
                    result = subprocess.run([venv_pip, "install", "-r", req_file], 
                                          capture_output=True, text=True)
                    if result.returncode != 0:
                        self.log(f"Warning: Failed to install {req_file}: {result.stderr}")
                    else:
                        self.log(f"Successfully installed {req_file}")
            
            # Install additional packages (critical for pipeline)
            additional_packages = ["numpy-stl", "pydirectinput", "pyautogui", "pygetwindow", "pywinauto", "pywin32"]
            for package in additional_packages:
                self.log(f"Installing {package}...")
                result = subprocess.run([venv_pip, "install", package], 
                                      capture_output=True, text=True)
                if result.returncode != 0:
                    self.log(f"Warning: Failed to install {package}: {result.stderr}")
                else:
                    self.log(f"Successfully installed {package}")
            
            self.log("Dependencies installation completed")
            
            # Verify dependencies after installation (as per developer guide)
            self.log("Verifying installed dependencies...")
            if not self._verify_dependencies(venv_python):
                self.log("Warning: Some dependencies may not be properly installed")
                # Don't fail here - verification will happen again before processing
            
            return True
            
        except Exception as e:
            self.log(f"Error creating virtual environment: {str(e)}")
            return False
    
    def open_output_folder(self):
        """Open the output folder in file explorer."""
        try:
            if os.name == 'nt':  # Windows
                os.startfile(self.output_folder_path)
            elif os.name == 'posix':  # macOS and Linux
                subprocess.run(['open' if sys.platform == 'darwin' else 'xdg-open', self.output_folder_path])
        except Exception as e:
            self.log(f"Error opening folder: {str(e)}")

def main():
    """Main function to run the application."""
    root = tk.Tk()
    app = HullBaseplateApp(root)
    
    # Center the window on screen
    root.update_idletasks()
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    window_width = 1200
    window_height = 800
    
    x = (screen_width - window_width) // 2
    y = (screen_height - window_height) // 2
    
    root.geometry(f"{window_width}x{window_height}+{x}+{y}")
    
    root.mainloop()

if __name__ == "__main__":
    main()

