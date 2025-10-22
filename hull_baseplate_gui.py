#!/usr/bin/env python3
"""
Hull Baseplate Pipeline - Desktop GUI Application

A user-friendly desktop application for the STL to Hull Baseplate Pipeline.
Provides an intuitive interface for setting up Bambu Studio and running the pipeline.
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

class HullBaseplateApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Hull Baseplate Pipeline")
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
        self.output_folder_path = ""
        self.keep_intermediate_files = tk.BooleanVar(value=True)
        
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
        
        # Start with setup page
        self.notebook.select(0)
    
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
        """Create the file selection page."""
        file_frame = ttk.Frame(self.notebook)
        self.notebook.add(file_frame, text="2. File Selection")
        
        # Title
        title_label = ttk.Label(file_frame, text="Select Files", font=("Arial", 16, "bold"))
        title_label.pack(pady=(20, 10))
        
        # Main content frame
        content_frame = ttk.Frame(file_frame)
        content_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)
        
        # STL file selection
        stl_frame = ttk.LabelFrame(content_frame, text="Input STL File", padding="10")
        stl_frame.pack(fill=tk.X, pady=(0, 20))
        
        self.stl_path_var = tk.StringVar()
        stl_entry = ttk.Entry(stl_frame, textvariable=self.stl_path_var, state="readonly")
        stl_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10))
        
        stl_button = ttk.Button(stl_frame, text="Browse...", command=self.select_stl_file)
        stl_button.pack(side=tk.RIGHT)
        
        # Output folder selection
        output_frame = ttk.LabelFrame(content_frame, text="Output Folder", padding="10")
        output_frame.pack(fill=tk.X, pady=(0, 20))
        
        self.output_path_var = tk.StringVar()
        output_entry = ttk.Entry(output_frame, textvariable=self.output_path_var, state="readonly")
        output_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10))
        
        output_button = ttk.Button(output_frame, text="Browse...", command=self.select_output_folder)
        output_button.pack(side=tk.RIGHT)
        
        # Options frame
        options_frame = ttk.LabelFrame(content_frame, text="Options", padding="10")
        options_frame.pack(fill=tk.X, pady=(0, 20))
        
        # Keep intermediate files checkbox
        keep_files_checkbox = ttk.Checkbutton(options_frame, 
                                            text="Keep intermediate files (STL, hull files, etc.)",
                                            variable=self.keep_intermediate_files)
        keep_files_checkbox.pack(anchor=tk.W)
        
        # Help text
        help_text = """
Intermediate files include:
• Original sliced model (.gcode.3mf, .3mf)
• Hull STL file (.stl)
• Hull sliced files (.gcode.3mf, .3mf)
• Analysis files (.txt, .png)

Uncheck this to save disk space - only the final combined model will be kept.
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
        
        # Enable run button when both paths are selected
        def on_path_change():
            if self.stl_path_var.get() and self.output_path_var.get():
                self.run_button.config(state=tk.NORMAL)
            else:
                self.run_button.config(state=tk.DISABLED)
        
        self.stl_path_var.trace('w', lambda *args: on_path_change())
        self.output_path_var.trace('w', lambda *args: on_path_change())
    
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
    
    def select_output_folder(self):
        """Open folder dialog to select output directory."""
        folder_path = filedialog.askdirectory(title="Select Output Folder")
        if folder_path:
            self.output_path_var.set(folder_path)
            self.output_folder_path = folder_path
            self.log(f"Selected output folder: {folder_path}")
    
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
        self.log_text.insert(tk.END, f"{time.strftime('%H:%M:%S')} - {message}\n")
        self.log_text.see(tk.END)
        self.root.update_idletasks()
    
    def update_progress(self, value, status=""):
        """Update progress bar and status."""
        self.progress_var.set(value)
        if status:
            self.status_label.config(text=status)
        self.root.update_idletasks()
    
    def run_pipeline(self):
        """Run the hull baseplate pipeline."""
        # Validate inputs
        if not self.stl_file_path or not os.path.exists(self.stl_file_path):
            messagebox.showerror("Error", "Please select a valid STL file.")
            return
        
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
            self.log("Starting Hull Baseplate Pipeline...")
            self.update_progress(5, "Initializing...")
            
            # Check if full_pipeline.py exists
            script_dir = os.path.dirname(os.path.abspath(__file__))
            pipeline_script = os.path.join(script_dir, "full_pipeline.py")
            
            if not os.path.exists(pipeline_script):
                raise FileNotFoundError("full_pipeline.py not found in the application directory")
            
            # Determine which Python to use (prefer virtual environment)
            python_exe = self._get_python_executable(script_dir)
            
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
                
                # Move final output to specified folder (handles cleanup based on user preference)
                self._move_output_files()
                
                # Enable open folder button
                self.open_folder_button.config(state=tk.NORMAL)
                
                messagebox.showinfo("Success", "Pipeline completed successfully!\nCheck the output folder for your files.")
                
            else:
                self.update_progress(0, "Pipeline failed!")
                self.log(f"Pipeline failed with return code: {return_code}")
                messagebox.showerror("Error", "Pipeline failed. Check the log for details.")
        
        except Exception as e:
            self.log(f"Error: {str(e)}")
            self.update_progress(0, "Error occurred!")
            messagebox.showerror("Error", f"An error occurred: {str(e)}")
        
        finally:
            # Re-enable run button
            self.run_button.config(state=tk.NORMAL)
    
    def _move_output_files(self):
        """Move files to the specified output folder based on user preferences."""
        try:
            # Find the generated pipeline folder
            stl_dir = os.path.dirname(self.stl_file_path)
            stl_name = os.path.splitext(os.path.basename(self.stl_file_path))[0]
            pipeline_dir = os.path.join(stl_dir, f"{stl_name}_pipeline")
            
            if not os.path.exists(pipeline_dir):
                self.log("Warning: Pipeline output directory not found")
                return
            
            # Find the final output file
            final_output = os.path.join(pipeline_dir, f"{stl_name}_with_hull_baseplate.gcode.3mf")
            
            if not os.path.exists(final_output):
                self.log("Warning: Final output file not found")
                return
            
            if self.keep_intermediate_files.get():
                # Keep all files - move everything to output folder
                self.log("Keeping all files - copying to output folder...")
                for file in os.listdir(pipeline_dir):
                    src_path = os.path.join(pipeline_dir, file)
                    if os.path.isfile(src_path):
                        dest_path = os.path.join(self.output_folder_path, file)
                        shutil.copy2(src_path, dest_path)
                        self.log(f"Copied: {file}")
                
                # Remove the original pipeline folder since we've copied everything
                shutil.rmtree(pipeline_dir)
                self.log("Original pipeline folder removed")
                
            else:
                # Keep only final output - move just the final file
                self.log("Keeping only final output - copying to output folder...")
                dest_path = os.path.join(self.output_folder_path, os.path.basename(final_output))
                shutil.copy2(final_output, dest_path)
                self.log(f"Final output copied to: {dest_path}")
                
                # Remove the entire pipeline folder since we only want the final output
                shutil.rmtree(pipeline_dir)
                self.log("Pipeline folder removed (only final output kept)")
        
        except Exception as e:
            self.log(f"Error managing output files: {str(e)}")
    
    def _cleanup_intermediate_files(self):
        """This method is no longer needed - cleanup is handled in _move_output_files."""
        # This method is kept for compatibility but does nothing
        # All cleanup logic is now in _move_output_files
        pass
    
    def _get_python_executable(self, script_dir):
        """Get the appropriate Python executable (create venv if needed)."""
        # Check for virtual environment first
        venv_python = os.path.join(script_dir, "venv", "Scripts", "python.exe")
        if os.path.exists(venv_python):
            self.log(f"Using virtual environment Python: {venv_python}")
            return venv_python
        
        # Check for venv in current directory
        venv_python = os.path.join(os.getcwd(), "venv", "Scripts", "python.exe")
        if os.path.exists(venv_python):
            self.log(f"Using virtual environment Python: {venv_python}")
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
            
            # Install additional packages
            additional_packages = ["numpy-stl", "pydirectinput"]
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
