#!/bin/bash

# Setup script for STL to Hull Baseplate Pipeline
# This script sets up the Python environment and installs dependencies

echo "🚀 Setting up STL to Hull Baseplate Pipeline..."

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is not installed or not in PATH"
    echo "   Please install Python 3.6 or later"
    exit 1
fi

# Check if Bambu Studio is installed
if [ ! -d "/Applications/BambuStudio.app" ]; then
    echo "❌ Error: Bambu Studio not found in /Applications/"
    echo "   Please install Bambu Studio from https://bambulab.com/en/download/studio"
    exit 1
fi

echo "✅ Python 3 found: $(python3 --version)"
echo "✅ Bambu Studio found"

# Create virtual environment
echo "📦 Creating Python virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📥 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt
pip install -r requirements_stl.txt

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "To run the pipeline:"
echo "  ./full_pipeline.sh /path/to/your/model.stl"
echo ""
echo "To activate the virtual environment manually:"
echo "  source venv/bin/activate"
