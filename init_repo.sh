#!/bin/bash

# OKC-SFT Dataset Repository Initialization Script
# This script initializes the Git repository and prepares it for GitHub

set -e

echo "=== OKC-SFT Dataset Repository Initialization ==="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed. Please install Git first."
    exit 1
fi

# Initialize git repository
echo "1. Initializing Git repository..."
git init

# Add all files
echo "2. Adding files to repository..."
git add .

# Create initial commit
echo "3. Creating initial commit..."
git commit -m "Initial commit: OKC-SFT Dataset

- OKC-SFT training samples (611 samples)
- QA-SFT baseline training samples (858 samples)
- Test set (61 samples)
- Raw materials and evaluation criteria
- Documentation and usage guide"

echo ""
echo "=== Repository initialized successfully! ==="
echo ""
echo "Next steps:"
echo "1. Create a new repository on GitHub"
echo "2. Add the remote origin:"
echo "   git remote add origin https://github.com/YOUR_USERNAME/OKC-SFT-Dataset.git"
echo "3. Push to GitHub:"
echo "   git push -u origin main"
echo ""
echo "Repository structure:"
find . -type f -not -path './.git/*' | sort | head -20
echo ""
echo "Total files: $(find . -type f -not -path './.git/*' | wc -l)"
echo "Total size: $(du -sh . --exclude=.git 2>/dev/null | cut -f1 || echo 'N/A')"
