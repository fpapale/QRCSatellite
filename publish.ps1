# Quick publish script for QRCSatellite to GitHub (PowerShell)

$ErrorActionPreference = "Stop"

Write-Host "`n========================================"
Write-Host "  Publishing QRCSatellite to GitHub"
Write-Host "========================================`n" -ForegroundColor Cyan

# Check directory
if (-not (Test-Path "qrcsatellite.yaml")) {
    Write-Host "[ERROR] Not in QRCSatellite directory" -ForegroundColor Red
    pause
    exit 1
}

# Init git if needed
if (-not (Test-Path ".git")) {
    Write-Host "[STEP 1] Initializing git repository..." -ForegroundColor Yellow
    git init
}

# Add files
Write-Host "[STEP 2] Adding files..." -ForegroundColor Yellow
git add .

# Commit
$commitMsg = Read-Host "Enter commit message (or press Enter for default)"
if ([string]::IsNullOrWhiteSpace($commitMsg)) {
    $commitMsg = "Initial release v1.0.0 - WiFi QR Display for ATOM S3"
}

Write-Host "[STEP 3] Committing..." -ForegroundColor Yellow
git commit -m $commitMsg

# Check gh CLI
$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue

if ($ghInstalled) {
    Write-Host "`n[SUCCESS] GitHub CLI detected" -ForegroundColor Green
    
    # Auth check
    Write-Host "[STEP 4] Checking authentication..." -ForegroundColor Yellow
    gh auth status 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARNING] Not authenticated" -ForegroundColor Yellow
        Write-Host "Please run: gh auth login" -ForegroundColor Cyan
        pause
        exit 1
    }
    
    # Create repository
    Write-Host "[STEP 5] Creating repository fpapale/QRCSatellite..." -ForegroundColor Yellow
    gh repo create fpapale/QRCSatellite --public --source=. --remote=origin --push 2>&1
    
    # Metadata
    Write-Host "[STEP 6] Setting metadata..." -ForegroundColor Yellow
    gh repo edit fpapale/QRCSatellite --description "WiFi QR Code Display for M5Stack ATOM S3 - ESPHome & QRCService Integration"
    gh repo edit fpapale/QRCSatellite --add-topic esphome
    gh repo edit fpapale/QRCSatellite --add-topic atom-s3
    gh repo edit fpapale/QRCSatellite --add-topic m5stack
    gh repo edit fpapale/QRCSatellite --add-topic qr-code
    gh repo edit fpapale/QRCSatellite --add-topic wifi
    gh repo edit fpapale/QRCSatellite --add-topic home-assistant
    
    # Tag and release
    Write-Host "[STEP 7] Creating tag v1.0.0..." -ForegroundColor Yellow
    git tag -a v1.0.0 -m "Release v1.0.0"
    git push origin v1.0.0
    
    Write-Host "[STEP 8] Creating release..." -ForegroundColor Yellow
    $releaseNotes = @"
## Features
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
See README.md for setup instructions
"@
    
    gh release create v1.0.0 --title "v1.0.0 - Initial Release" --notes $releaseNotes
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  Published successfully!" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    Write-Host "Repository: https://github.com/fpapale/QRCSatellite`n" -ForegroundColor Cyan
}
else {
    Write-Host "`n[WARNING] GitHub CLI not found" -ForegroundColor Yellow
    Write-Host "Installing via winget...`n"
    
    try {
        winget install --id GitHub.cli
        Write-Host "`n[SUCCESS] Installed. Restart PowerShell and run again." -ForegroundColor Green
    }
    catch {
        Write-Host "`n[INFO] Manual steps:" -ForegroundColor Yellow
        Write-Host "1. Install GitHub CLI: https://cli.github.com/"
        Write-Host "2. Or push manually to GitHub`n"
    }
}

pause
