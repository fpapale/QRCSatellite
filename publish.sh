#!/bin/bash
# Quick publish script for QRCSatellite to GitHub

set -e

echo "🚀 Publishing QRCSatellite to GitHub..."

# Check directory
if [ ! -f "qrcsatellite.yaml" ]; then
    echo "❌ Error: Not in QRCSatellite directory"
    exit 1
fi

# Init git if needed
if [ ! -d ".git" ]; then
    echo "📦 Initializing git repository..."
    git init
fi

# Add files
echo "📝 Adding files..."
git add .

# Commit
read -p "Enter commit message (default: 'Initial release v1.0.0'): " commit_msg
commit_msg=${commit_msg:-"Initial release v1.0.0 - WiFi QR Display for ATOM S3"}
git commit -m "$commit_msg"

# Check gh CLI
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI detected"
    
    # Create repository
    echo "🔨 Creating GitHub repository fpapale/QRCSatellite..."
    gh repo create fpapale/QRCSatellite --public --source=. --remote=origin --push || echo "Repository might already exist"
    
    # Add description and topics
    echo "📋 Setting repository metadata..."
    gh repo edit fpapale/QRCSatellite \
        --description "WiFi QR Code Display for M5Stack ATOM S3 - ESPHome & QRCService Integration" \
        --add-topic esphome \
        --add-topic atom-s3 \
        --add-topic m5stack \
        --add-topic qr-code \
        --add-topic wifi \
        --add-topic home-assistant \
        --add-topic iot
    
    # Create release
    echo "🏷️  Creating release v1.0.0..."
    gh release create v1.0.0 \
        --title "v1.0.0 - Initial Release" \
        --notes "## Features
- Display WiFi QR codes on M5Stack ATOM S3
- Integration with QRCService (Home Assistant)
- Modular configuration with packages
- Button controls for network selection
- Auto QR download and display

## Hardware
- M5Stack ATOM S3
- ST7789V 128x128 LCD
- Button on GPIO41

## Installation
See README.md for setup instructions"
    
    echo "✅ Published successfully!"
    echo "📍 Repository: https://github.com/fpapale/QRCSatellite"
    
else
    echo "⚠️  GitHub CLI not found. Using manual method..."
    
    # Add remote if needed
    if ! git remote | grep -q origin; then
        echo "🔗 Adding remote origin..."
        git remote add origin https://github.com/fpapale/QRCSatellite.git
    fi
    
    # Push
    echo "📤 Pushing to GitHub..."
    git branch -M main
    git push -u origin main
    
    # Create tag
    echo "🏷️  Creating tag v1.0.0..."
    git tag -a v1.0.0 -m "Release v1.0.0"
    git push origin v1.0.0
    
    echo "✅ Code pushed!"
    echo "⚠️  Manual steps:"
    echo "1. Create release at https://github.com/fpapale/QRCSatellite/releases/new"
fi
