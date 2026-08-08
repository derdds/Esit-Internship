# Esit Internship Project Backup Script
# This script backs up your entire project structure to local and GitHub
# Usage: .\backup-project.ps1

# ============================================================================
# CONFIGURATION - Edit these paths
# ============================================================================
$PROJECT_PATH = "C:\Users\User\Desktop\Esit Internship"  # Your Esit Internship folder
$BACKUP_BASE = "$PROJECT_PATH\backups"                   # Backup folder location
$USE_ZIP = $true                                          # $true for ZIP, $false for RAR
$ALSO_PUSH_GITHUB = $true                                # Push to GitHub after backup

# ============================================================================
# Auto-generated values
# ============================================================================
$DATE = Get-Date -Format "yyyy-MM-dd"
$TIME = Get-Date -Format "HH-mm-ss"
$TIMESTAMP = "$DATE-$TIME"
$BACKUP_FILENAME = "backup-$TIMESTAMP"

if ($USE_ZIP) {
    $BACKUP_FILE = "$BACKUP_BASE\$BACKUP_FILENAME.zip"
} else {
    $BACKUP_FILE = "$BACKUP_BASE\$BACKUP_FILENAME.rar"
}

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Esit Internship Project Backup Tool  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# Validation
# ============================================================================
if (-not (Test-Path $PROJECT_PATH)) {
    Write-Host "ERROR: Project path does not exist: $PROJECT_PATH" -ForegroundColor Red
    exit 1
}

Write-Host "Project Path:    $PROJECT_PATH" -ForegroundColor White
Write-Host "Backup Location: $BACKUP_FILE" -ForegroundColor White
Write-Host "Timestamp:       $TIMESTAMP" -ForegroundColor White
Write-Host ""

# ============================================================================
# Create backup directory if it doesn't exist
# ============================================================================
if (-not (Test-Path $BACKUP_BASE)) {
    Write-Host "Creating backup directory..." -ForegroundColor Yellow
    New-Item -Path $BACKUP_BASE -ItemType Directory -Force | Out-Null
}

# ============================================================================
# Create temporary backup folder
# ============================================================================
$TEMP_BACKUP = Join-Path $BACKUP_BASE "temp-backup-$([guid]::NewGuid().Guid.Substring(0,8))"
Write-Host "Creating temporary backup folder..." -ForegroundColor Yellow
New-Item -Path $TEMP_BACKUP -ItemType Directory -Force | Out-Null

# List of patterns to EXCLUDE from backup
$EXCLUDE_PATTERNS = @(
    "\.git",
    "node_modules",
    ".vscode",
    "\.vs",
    "backups",
    "\.env",
    "\.env.local",
    "\.cache",
    "\.tmp",
    "bin",
    "obj",
    "dist",
    "build"
)

# ============================================================================
# Copy files to temporary backup folder
# ============================================================================
Write-Host "Copying project files..." -ForegroundColor Yellow

Get-ChildItem -Path $PROJECT_PATH -Recurse -Force |
    Where-Object {
        $fullName = $_.FullName
        $relativePath = $fullName.Substring($PROJECT_PATH.Length + 1)
        
        $exclude = $false
        foreach ($pattern in $EXCLUDE_PATTERNS) {
            if ($relativePath -match $pattern) {
                $exclude = $true
                break
            }
        }
        -not $exclude
    } |
    ForEach-Object {
        $relativePath = $_.FullName.Substring($PROJECT_PATH.Length + 1)
        $destPath = Join-Path $TEMP_BACKUP $relativePath
        
        if ($_.PSIsContainer) {
            if (-not (Test-Path $destPath)) {
                New-Item -Path $destPath -ItemType Directory -Force | Out-Null
            }
        } else {
            $destDir = Split-Path $destPath
            if (-not (Test-Path $destDir)) {
                New-Item -Path $destDir -ItemType Directory -Force | Out-Null
            }
            Copy-Item -Path $_.FullName -Destination $destPath -Force
        }
    }

Write-Host "✓ Files copied to temporary folder" -ForegroundColor Green

# ============================================================================
# Compress backup
# ============================================================================
Write-Host "Creating compressed backup..." -ForegroundColor Yellow

if ($USE_ZIP) {
    # Create ZIP file
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if (Test-Path $BACKUP_FILE) {
        Remove-Item $BACKUP_FILE -Force
    }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($TEMP_BACKUP, $BACKUP_FILE)
    Write-Host "✓ Created ZIP backup" -ForegroundColor Green
} else {
    # For RAR - requires WinRAR to be installed
    $WINRAR_PATH = "C:\Program Files\WinRAR\rar.exe"
    if (-not (Test-Path $WINRAR_PATH)) {
        Write-Host "WARNING: WinRAR not found at $WINRAR_PATH" -ForegroundColor Yellow
        Write-Host "Using ZIP instead of RAR" -ForegroundColor Yellow
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        if (Test-Path $BACKUP_FILE) {
            Remove-Item $BACKUP_FILE -Force
        }
        $BACKUP_FILE = $BACKUP_FILE -replace "\.rar$", ".zip"
        [System.IO.Compression.ZipFile]::CreateFromDirectory($TEMP_BACKUP, $BACKUP_FILE)
        Write-Host "✓ Created ZIP backup (RAR unavailable)" -ForegroundColor Green
    } else {
        & $WINRAR_PATH a -r "$BACKUP_FILE" "$TEMP_BACKUP\"
        Write-Host "✓ Created RAR backup" -ForegroundColor Green
    }
}

# ============================================================================
# Clean up temporary folder
# ============================================================================
Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
Remove-Item $TEMP_BACKUP -Recurse -Force
Write-Host "✓ Temporary files removed" -ForegroundColor Green

# ============================================================================
# Get backup info
# ============================================================================
$BACKUP_SIZE = (Get-Item $BACKUP_FILE).Length / 1MB
$BACKUP_COUNT = (Get-ChildItem "$BACKUP_BASE\backup-*.zip", "$BACKUP_BASE\backup-*.rar" 2>/dev/null | Measure-Object).Count

# ============================================================================
# Push to GitHub (optional)
# ============================================================================
if ($ALSO_PUSH_GITHUB) {
    Write-Host ""
    Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
    
    Push-Location $PROJECT_PATH
    
    # Check if it's a git repo
    if (Test-Path "$PROJECT_PATH\.git") {
        git add -A 2>&1 | Out-Null
        $commitMsg = "Daily backup: $TIMESTAMP"
        git commit -m $commitMsg 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            $pushOutput = git push origin main 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Pushed to GitHub" -ForegroundColor Green
            } else {
                Write-Host "⚠ GitHub push had issues (but local backup succeeded)" -ForegroundColor Yellow
                Write-Host $pushOutput -ForegroundColor Gray
            }
        } else {
            Write-Host "ℹ No changes to commit (local backup created)" -ForegroundColor Gray
        }
    } else {
        Write-Host "⚠ Not a git repository (initialize with: git init)" -ForegroundColor Yellow
    }
    
    Pop-Location
}

# ============================================================================
# Summary
# ============================================================================
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Backup Complete! ✓            ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backup File:     $(Split-Path $BACKUP_FILE -Leaf)" -ForegroundColor White
Write-Host "Size:            $([Math]::Round($BACKUP_SIZE, 2)) MB" -ForegroundColor White
Write-Host "Total Backups:   $BACKUP_COUNT" -ForegroundColor White
Write-Host "Timestamp:       $TIMESTAMP" -ForegroundColor White
Write-Host ""
Write-Host "Active Projects:" -ForegroundColor Cyan
Write-Host "  • Kedi Savar" -ForegroundColor Gray
Write-Host "  • Bike Power Meter" -ForegroundColor Gray
Write-Host "  • Mushroom Pastorization System" -ForegroundColor Gray
Write-Host ""
Write-Host "Resources folder also backed up!" -ForegroundColor Green
Write-Host ""
