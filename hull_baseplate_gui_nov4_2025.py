#!/usr/bin/env python3
"""
Hull Baseplate Pipeline - Desktop GUI Application (Nov 4, 2025 Version)

A user-friendly desktop application for the STL to Hull Baseplate Pipeline.
Provides an intuitive interface for setting up Bambu Studio and running the pipeline.

New Features (Nov 4, 2025):
- Support for single STL file OR input folder processing
- Automatic output folder generation option
- Sequential batch processing of STL files in a folder
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
        self.root.title("Hull Baseplate Pipeline (Nov 4, 2025)")
        self.root.geometry("1200x800")
        self.root.resizable(True, True)
        self.root.minsize(1000, 700)  # Set minimum size
        
        # Set application icon (if available)
        try:
            self.root.iconbitmap("icon.ico")
        except:
            pass
        
        # Configuration
        self.config = self.load_config()
        self.stl_file_path = ""
        self.input_folder_path = ""
        self.output_folder_path = ""
        self.keep_intermediate_files = tk.BooleanVar(value=True)
        self.auto_output_folder = tk.BooleanVar(value=False)
        self.create_subfolders = tk.BooleanVar(value=True)  # Create subfolder for each file
        self.input_mode = tk.StringVar(value="single")  # "single" or "folder"
        
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
        about_text = f"""Hull Baseplate Pipeline (Nov 4, 2025 - Advanced)

Version: {current_version}

A full-featured desktop application for the STL to Hull Baseplate Pipeline.
Provides an intuitive interface for setting up Bambu Studio and running the pipeline.

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
    
    def create_setup_page(self):
        """Create the Bambu Studio setup instructions page."""
        setup_frame = ttk.Frame(self.notebook)
        self.notebook.add(setup_frame, text="1. Setup")
        
        # Title
        title_label = ttk.Label(setup_frame, text="Bambu Studio Setup", font=("Arial", 16, "bold"))
        title_label.pack(pady=(20, 10))
        
        # Instructions container
        instructions_frame = ttk.Frame(setup_frame)
        instructions_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)
        
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
                                       text="I have completed the Bambu Studio setup above",
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
        """Create the file selection page with input mode selection."""
        file_frame = ttk.Frame(self.notebook)
        self.notebook.add(file_frame, text="2. File Selection")
        
        # Title
        title_label = ttk.Label(file_frame, text="Select Files", font=("Arial", 16, "bold"))
        title_label.pack(pady=(20, 10))
        
        # Main content frame
        content_frame = ttk.Frame(file_frame)
        content_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)
        
        # Input mode selection frame
        mode_frame = ttk.LabelFrame(content_frame, text="Input Mode", padding="10")
        mode_frame.pack(fill=tk.X, pady=(0, 20))
        
        single_radio = ttk.Radiobutton(mode_frame, text="Single STL File", 
                                      variable=self.input_mode, value="single",
                                      command=self._on_input_mode_change)
        single_radio.pack(side=tk.LEFT, padx=10)
        
        folder_radio = ttk.Radiobutton(mode_frame, text="Input Folder (Process All STLs)", 
                                      variable=self.input_mode, value="folder",
                                      command=self._on_input_mode_change)
        folder_radio.pack(side=tk.LEFT, padx=10)
        
        # Single STL file selection (initially visible)
        self.stl_frame = ttk.LabelFrame(content_frame, text="Input STL File", padding="10")
        self.stl_frame.pack(fill=tk.X, pady=(0, 20))
        
        self.stl_path_var = tk.StringVar()
        self.stl_entry = ttk.Entry(self.stl_frame, textvariable=self.stl_path_var, state="readonly")
        self.stl_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10))
        
        self.stl_button = ttk.Button(self.stl_frame, text="Browse...", command=self.select_stl_file)
        self.stl_button.pack(side=tk.RIGHT)
        
        # Input folder selection (initially hidden)
        self.folder_frame = ttk.LabelFrame(content_frame, text="Input Folder", padding="10")
        # Don't pack initially - will be shown/hidden based on mode
        
        self.folder_path_var = tk.StringVar()
        self.folder_entry = ttk.Entry(self.folder_frame, textvariable=self.folder_path_var, state="readonly")
        self.folder_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10))
        
        self.folder_button = ttk.Button(self.folder_frame, text="Browse...", command=self.select_input_folder)
        self.folder_button.pack(side=tk.RIGHT)
        
        # Auto output folder option
        auto_output_frame = ttk.LabelFrame(content_frame, text="Output Options", padding="10")
        auto_output_frame.pack(fill=tk.X, pady=(0, 20))
        
        self.auto_output_checkbox = ttk.Checkbutton(auto_output_frame, 
                                                   text="Automatically generate output folder",
                                                   variable=self.auto_output_folder,
                                                   command=self._on_auto_output_change)
        self.auto_output_checkbox.pack(anchor=tk.W)
        
        help_text_auto = """
When enabled: Creates output folder at "{input_folder}\\slicer_output"
This option is particularly useful for batch processing.
        """
        help_label_auto = ttk.Label(auto_output_frame, text=help_text_auto, 
                                   justify=tk.LEFT, foreground="gray")
        help_label_auto.pack(anchor=tk.W, pady=(10, 0))
        
        # Output folder selection (initially visible)
        self.output_frame = ttk.LabelFrame(content_frame, text="Output Folder", padding="10")
        self.output_frame.pack(fill=tk.X, pady=(0, 20))
        
        self.output_path_var = tk.StringVar()
        self.output_entry = ttk.Entry(self.output_frame, textvariable=self.output_path_var, state="readonly")
        self.output_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10))
        
        self.output_button = ttk.Button(self.output_frame, text="Browse...", command=self.select_output_folder)
        self.output_button.pack(side=tk.RIGHT)
        
        # Options frame
        options_frame = ttk.LabelFrame(content_frame, text="Options", padding="10")
        options_frame.pack(fill=tk.X, pady=(0, 20))
        
        # Keep intermediate files checkbox
        keep_files_checkbox = ttk.Checkbutton(options_frame, 
                                            text="Keep intermediate files (STL, hull files, etc.)",
                                            variable=self.keep_intermediate_files)
        keep_files_checkbox.pack(anchor=tk.W, pady=(0, 10))
        
        # Create subfolders checkbox
        subfolder_checkbox = ttk.Checkbutton(options_frame, 
                                            text="Create subfolder for each file",
                                            variable=self.create_subfolders)
        subfolder_checkbox.pack(anchor=tk.W)
        
        # Help text
        help_text = """
Intermediate files include:
• Original sliced model (.gcode.3mf, .3mf)
• Hull STL file (.stl)
• Hull sliced files (.gcode.3mf, .3mf)
• Analysis files (.txt, .png)

Uncheck "Keep intermediate files" to save disk space - only the final combined model will be kept.

Uncheck "Create subfolder for each file" to place all final .gcode.3mf files directly in the output folder (useful for batch processing).
        """
        
        help_label = ttk.Label(options_frame, text=help_text, 
                              justify=tk.LEFT, foreground="gray")
        help_label.pack(anchor=tk.W, pady=(10, 0))
        
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
        
        # Initial UI state
        self._on_input_mode_change()
        self._on_auto_output_change()
        
        # Enable run button based on validation
        def on_path_change():
            self._validate_and_update_run_button()
        
        self.stl_path_var.trace('w', lambda *args: on_path_change())
        self.folder_path_var.trace('w', lambda *args: on_path_change())
        self.output_path_var.trace('w', lambda *args: on_path_change())
        self.auto_output_folder.trace('w', lambda *args: on_path_change())
    
    def _on_input_mode_change(self):
        """Handle input mode change (single file vs folder)."""
        if self.input_mode.get() == "single":
            # Show single STL frame, hide folder frame
            self.folder_frame.pack_forget()
            if not self.stl_frame.winfo_ismapped():  # Only pack if not already visible
                self.stl_frame.pack(fill=tk.X, pady=(0, 20))
        else:
            # Show folder frame, hide single STL frame
            self.stl_frame.pack_forget()
            if not self.folder_frame.winfo_ismapped():  # Only pack if not already visible
                self.folder_frame.pack(fill=tk.X, pady=(0, 20))
        
        # Update output frame visibility based on auto output setting
        self._on_auto_output_change()
        
        self._validate_and_update_run_button()
    
    def _on_auto_output_change(self):
        """Handle auto output folder checkbox change."""
        if self.auto_output_folder.get():
            # Hide manual output folder selection
            if self.output_frame.winfo_ismapped():  # Only pack_forget if currently visible
                self.output_frame.pack_forget()
        else:
            # Show manual output folder selection - pack it if not already visible
            if not self.output_frame.winfo_ismapped():  # Only pack if not already visible
                self.output_frame.pack(fill=tk.X, pady=(0, 20))
        
        self._validate_and_update_run_button()
    
    def _validate_and_update_run_button(self):
        """Validate inputs and enable/disable run button."""
        is_valid = False
        
        if self.input_mode.get() == "single":
            # Single file mode: need STL file
            if self.stl_path_var.get() and os.path.exists(self.stl_path_var.get()):
                if self.auto_output_folder.get():
                    # Auto output: only need input file
                    is_valid = True
                else:
                    # Manual output: need output folder too
                    if self.output_path_var.get() and os.path.exists(self.output_path_var.get()):
                        is_valid = True
        else:
            # Folder mode: need input folder
            if self.folder_path_var.get() and os.path.exists(self.folder_path_var.get()):
                if self.auto_output_folder.get():
                    # Auto output: only need input folder
                    is_valid = True
                else:
                    # Manual output: need output folder too
                    if self.output_path_var.get() and os.path.exists(self.output_path_var.get()):
                        is_valid = True
        
        if is_valid:
            self.run_button.config(state=tk.NORMAL)
        else:
            self.run_button.config(state=tk.DISABLED)
    
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
        back_button = ttk.Button(button_frame, text="← Back to File Selection", 
                               command=self.go_to_file_selection)
        back_button.pack(side=tk.LEFT)
        
        # Open output folder button
        self.open_folder_button = ttk.Button(button_frame, text="Open Output Folder", 
                                           command=self.open_output_folder, state=tk.DISABLED)
        self.open_folder_button.pack(side=tk.RIGHT)
    
    def select_stl_file(self):
        """Open file dialog to select STL file."""
        file_path = filedialog.askopenfilename(
            title="Select STL File",
            filetypes=[("STL files", "*.stl"), ("All files", "*.*")]
        )
        if file_path:
            self.stl_path_var.set(file_path)
            self.stl_file_path = file_path
            self.log(f"Selected STL file: {os.path.basename(file_path)}")
            self._validate_and_update_run_button()
    
    def select_input_folder(self):
        """Open folder dialog to select input directory."""
        folder_path = filedialog.askdirectory(title="Select Input Folder")
        if folder_path:
            self.folder_path_var.set(folder_path)
            self.input_folder_path = folder_path
            
            # Count STL files in folder (remove duplicates - Windows is case-insensitive)
            stl_files = glob.glob(os.path.join(folder_path, "*.stl"))
            stl_files.extend(glob.glob(os.path.join(folder_path, "*.STL")))
            # Remove duplicates (case-insensitive file systems can match same files twice)
            # Use dictionary to preserve order while removing duplicates
            unique_files = {}
            for f in stl_files:
                normalized = os.path.normpath(os.path.normcase(f))
                if normalized not in unique_files:
                    unique_files[normalized] = f
            stl_files = list(unique_files.values())
            stl_files.sort()  # Sort for consistent order
            count = len(stl_files)
            
            self.log(f"Selected input folder: {folder_path}")
            self.log(f"Found {count} STL file(s) in folder")
            self._validate_and_update_run_button()
    
    def select_output_folder(self):
        """Open folder dialog to select output directory."""
        folder_path = filedialog.askdirectory(title="Select Output Folder")
        if folder_path:
            self.output_path_var.set(folder_path)
            self.output_folder_path = folder_path
            self.log(f"Selected output folder: {folder_path}")
            self._validate_and_update_run_button()
    
    def go_to_setup(self):
        """Navigate to setup page."""
        self.notebook.select(0)
    
    def go_to_file_selection(self):
        """Navigate to file selection page."""
        self.notebook.select(1)
    
    def go_to_progress(self):
        """Navigate to progress page."""
        self.notebook.select(2)
    
    def log(self, message):
        """Add message to log text area."""
        # Safe to call even if log_text doesn't exist yet
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
        """Generate automatic output folder path based on input."""
        if self.input_mode.get() == "single":
            # For single file: create output folder in same directory as input file
            input_dir = os.path.dirname(self.stl_file_path)
            output_folder = os.path.join(input_dir, "slicer_output")
        else:
            # For folder mode: create output folder inside input folder
            output_folder = os.path.join(self.input_folder_path, "slicer_output")
        
        return output_folder
    
    def run_pipeline(self):
        """Run the hull baseplate pipeline."""
        # Determine output folder
        if self.auto_output_folder.get():
            self.output_folder_path = self._get_auto_output_folder()
            # Create output folder if it doesn't exist
            os.makedirs(self.output_folder_path, exist_ok=True)
            self.log(f"Auto-generated output folder: {self.output_folder_path}")
        
        # Validate inputs
        if self.input_mode.get() == "single":
            if not self.stl_file_path or not os.path.exists(self.stl_file_path):
                messagebox.showerror("Error", "Please select a valid STL file.")
                return
        else:
            if not self.input_folder_path or not os.path.exists(self.input_folder_path):
                messagebox.showerror("Error", "Please select a valid input folder.")
                return
        
        if not self.auto_output_folder.get():
            if not self.output_folder_path or not os.path.exists(self.output_folder_path):
                messagebox.showerror("Error", "Please select a valid output folder.")
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
            if self.input_mode.get() == "single":
                # Single file mode
                self._process_single_file()
            else:
                # Folder mode - process all STL files sequentially
                self._process_folder()
        
        except Exception as e:
            self.log(f"Error: {str(e)}")
            self.update_progress(0, "Error occurred!")
            # Schedule messagebox in main thread
            self.root.after(0, lambda: messagebox.showerror("Error", f"An error occurred: {str(e)}"))
        
        finally:
            # Re-enable buttons in main thread
            self.root.after(0, lambda: self.run_button.config(state=tk.NORMAL))
            self.root.after(0, lambda: self.open_folder_button.config(state=tk.NORMAL))
    
    def _process_single_file(self):
        """Process a single STL file."""
        self.log("Starting Hull Baseplate Pipeline (Single File Mode)...")
        self.update_progress(5, "Initializing...")
        
        # Check if full_pipeline.py exists
        script_dir = os.path.dirname(os.path.abspath(__file__))
        pipeline_script = os.path.join(script_dir, "full_pipeline.py")
        
        if not os.path.exists(pipeline_script):
            raise FileNotFoundError("full_pipeline.py not found in the application directory")
        
        # Determine which Python to use (prefer virtual environment)
        python_exe = self._get_python_executable(script_dir)
        
        # Verify dependencies are installed before processing
        self.log("Verifying dependencies before processing...")
        if not self._verify_dependencies(python_exe):
            self.log("ERROR: Critical dependencies are missing. Pipeline may fail.")
            # Schedule messagebox in main thread
            self.root.after(0, lambda: messagebox.showwarning("Dependency Warning", 
                "Some critical dependencies could not be installed.\nThe pipeline may fail. Check the log for details."))
        
        # Prepare command
        cmd = [python_exe, pipeline_script, self.stl_file_path]
        
        self.log(f"Running command: {' '.join(cmd)}")
        self.update_progress(10, "Starting pipeline...")
        
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
                self.log(line)
                # Update progress based on certain keywords
                if "Step 1" in line:
                    self.update_progress(20, "Slicing original STL...")
                elif "Step 2" in line:
                    self.update_progress(40, "Extracting hull...")
                elif "Step 3" in line:
                    self.update_progress(60, "Creating hull STL...")
                elif "Step 4" in line:
                    self.update_progress(80, "Processing hull...")
                elif "Step 5" in line:
                    self.update_progress(90, "Combining files...")
        
        # Wait for process to complete
        return_code = process.wait()
        
        if return_code == 0:
            self.update_progress(100, "Pipeline completed successfully!")
            self.log("Pipeline completed successfully!")
            
            # Move final output to specified folder
            self._move_output_files(self.stl_file_path)
            
            # Schedule messagebox in main thread
            self.root.after(0, lambda: messagebox.showinfo("Success", "Pipeline completed successfully!\nCheck the output folder for your files."))
        else:
            self.update_progress(0, "Pipeline failed!")
            self.log(f"Pipeline failed with return code: {return_code}")
            # Schedule messagebox in main thread
            self.root.after(0, lambda: messagebox.showerror("Error", "Pipeline failed. Check the log for details."))
    
    def _process_folder(self):
        """Process all STL files in a folder sequentially."""
        # Find all STL files in the input folder (remove duplicates - Windows is case-insensitive)
        stl_files = glob.glob(os.path.join(self.input_folder_path, "*.stl"))
        stl_files.extend(glob.glob(os.path.join(self.input_folder_path, "*.STL")))
        # Remove duplicates (case-insensitive file systems can match same files twice)
        # Use dictionary to preserve order while removing duplicates
        unique_files = {}
        for f in stl_files:
            normalized = os.path.normpath(os.path.normcase(f))
            if normalized not in unique_files:
                unique_files[normalized] = f
        stl_files = list(unique_files.values())
        stl_files.sort()  # Sort for consistent order
        
        if not stl_files:
            # Schedule messagebox in main thread
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
            # Schedule messagebox in main thread
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
        
        # Schedule messageboxes in main thread
        if failed_files == 0:
            self.root.after(0, lambda: messagebox.showinfo("Success", 
                             f"All {total_files} file(s) processed successfully!\nCheck the output folder for your files."))
        else:
            self.root.after(0, lambda: messagebox.showwarning("Partial Success", 
                                 f"Processed {successful_files}/{total_files} file(s) successfully.\n{failed_files} file(s) failed. Check the log for details."))
    
    def _move_output_files(self, stl_file_path):
        """Move files to the specified output folder based on user preferences."""
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
            
            # Determine output destination based on subfolder option
            if self.create_subfolders.get():
                # Create subfolder in output directory for this file
                output_destination = os.path.join(self.output_folder_path, stl_name)
                os.makedirs(output_destination, exist_ok=True)
                self.log(f"Using subfolder: {output_destination}")
            else:
                # Place files directly in output folder
                output_destination = self.output_folder_path
                self.log(f"Placing files directly in output folder: {output_destination}")
            
            if self.keep_intermediate_files.get():
                # Keep all files - copy everything to output destination
                self.log(f"Keeping all files - copying to {output_destination}...")
                for file in os.listdir(pipeline_dir):
                    src_path = os.path.join(pipeline_dir, file)
                    if os.path.isfile(src_path):
                        dest_path = os.path.join(output_destination, file)
                        # Check for filename conflicts if not using subfolders
                        if not self.create_subfolders.get() and os.path.exists(dest_path):
                            # Add number suffix to avoid overwriting
                            # Handle .gcode.3mf extension specially
                            if file.endswith('.gcode.3mf'):
                                base = file[:-10]  # Remove '.gcode.3mf'
                                ext = '.gcode.3mf'
                            else:
                                base, ext = os.path.splitext(file)
                            counter = 1
                            while os.path.exists(dest_path):
                                new_name = f"{base}_{counter}{ext}"
                                dest_path = os.path.join(output_destination, new_name)
                                counter += 1
                            self.log(f"  Warning: File exists, renaming to: {os.path.basename(dest_path)}")
                        shutil.copy2(src_path, dest_path)
                        self.log(f"  Copied: {os.path.basename(dest_path)}")
                
                # Remove the original pipeline folder since we've copied everything
                shutil.rmtree(pipeline_dir)
                self.log(f"Original pipeline folder removed: {pipeline_dir}")
                
            else:
                # Keep only final output - copy just the final file
                self.log(f"Keeping only final output - copying to {output_destination}...")
                final_filename = os.path.basename(final_output)
                dest_path = os.path.join(output_destination, final_filename)
                
                # Check for filename conflicts if not using subfolders
                if not self.create_subfolders.get() and os.path.exists(dest_path):
                    # Add number suffix to avoid overwriting
                    # Handle .gcode.3mf extension specially
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
            # Verify critical dependencies are installed
            self._verify_dependencies(venv_python)
            return venv_python
        
        # Check for venv in current directory
        venv_python = os.path.join(os.getcwd(), "venv", "Scripts", "python.exe")
        if os.path.exists(venv_python):
            self.log(f"Using virtual environment Python: {venv_python}")
            # Verify critical dependencies are installed
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
            import subprocess
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

