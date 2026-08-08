# Esit Internship - Folder Structure Setup
# This script creates the recommended folder organization
# Usage: .\setup-folder-structure.ps1

# ============================================================================
# CONFIGURATION
# ============================================================================
$PROJECT_PATH = "C:\Users\User\Desktop\Esit Internship"

Write-Host "╔═════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Esit Internship Folder Structure Setup     ║" -ForegroundColor Cyan
Write-Host "╚═════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# Validate project exists
# ============================================================================
if (-not (Test-Path $PROJECT_PATH)) {
    Write-Host "ERROR: Project path does not exist: $PROJECT_PATH" -ForegroundColor Red
    Write-Host "Creating project root folder..." -ForegroundColor Yellow
    New-Item -Path $PROJECT_PATH -ItemType Directory -Force | Out-Null
    Write-Host "✓ Created: $PROJECT_PATH" -ForegroundColor Green
}

Write-Host "Project Path: $PROJECT_PATH" -ForegroundColor White
Write-Host ""

# ============================================================================
# Define folder structure
# ============================================================================
$FOLDERS = @(
    "active projects\Kedi Savar",
    "active projects\Bike Power Meter",
    "active projects\Mushroom Pastorization System",
    "Resources",
    "backups"
)

Write-Host "Creating folder structure..." -ForegroundColor Yellow
Write-Host ""

# ============================================================================
# Create folders
# ============================================================================
foreach ($folder in $FOLDERS) {
    $fullPath = Join-Path $PROJECT_PATH $folder
    
    if (-not (Test-Path $fullPath)) {
        New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
        Write-Host "✓ Created: $folder" -ForegroundColor Green
    } else {
        Write-Host "→ Exists: $folder" -ForegroundColor Gray
    }
}

# ============================================================================
# Create README files for each project
# ============================================================================
Write-Host ""
Write-Host "Creating README files..." -ForegroundColor Yellow
Write-Host ""

$PROJECTS = @(
    @{Name="Kedi Savar"; Path="active projects\Kedi Savar"},
    @{Name="Bike Power Meter"; Path="active projects\Bike Power Meter"},
    @{Name="Mushroom Pastorization System"; Path="active projects\Mushroom Pastorization System"}
)

foreach ($project in $PROJECTS) {
    $readmePath = Join-Path $PROJECT_PATH $project.Path "README.md"
    
    if (-not (Test-Path $readmePath)) {
        $content = @"
# $($project.Name)

## Project Description
Add your project description here.

## Status
- Active/In Progress/Completed

## Key Files
- List important files here

## Notes
- Add any relevant notes

## Links
- Add links to documentation, repos, etc.
"@
        Set-Content -Path $readmePath -Value $content
        Write-Host "✓ Created: $($project.Path)\README.md" -ForegroundColor Green
    }
}

# ============================================================================
# Create Resources README
# ============================================================================
$resourcesReadme = Join-Path $PROJECT_PATH "Resources" "README.md"
if (-not (Test-Path $resourcesReadme)) {
    $content = @"
# Resources

## Organization
This folder contains shared resources for the Esit Internship projects:

### Subdirectories
- **Documentation** - Shared documentation files
- **References** - Reference materials and guides
- **Tools** - Shared tools and scripts
- **Assets** - Images, diagrams, and other assets

## Usage
Place project-independent resources here for easy access by all projects.

### Kedi Savar
- Links to related resources

### Bike Power Meter
- Links to related resources

### Mushroom Pastorization System
- Links to related resources
"@
    Set-Content -Path $resourcesReadme -Value $content
    Write-Host "✓ Created: Resources\README.md" -ForegroundColor Green
}

# ============================================================================
# Create .gitignore for backups folder
# ============================================================================
$backupsGitignore = Join-Path $PROJECT_PATH "backups" ".gitignore"
if (-not (Test-Path $backupsGitignore)) {
    $content = @"
# Ignore all backup files (don't commit to Git)
*.zip
*.rar
*.tar
*.gz

# But keep this .gitignore file
!.gitignore
"@
    Set-Content -Path $backupsGitignore -Value $content
    Write-Host "✓ Created: backups\.gitignore" -ForegroundColor Green
}

# ============================================================================
# Summary
# ============================================================================
Write-Host ""
Write-Host "╔═════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Folder Structure Setup Complete! ✓      ║" -ForegroundColor Green
Write-Host "╚═════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "Folder Structure:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Esit Internship\" -ForegroundColor White
Write-Host "├── active projects\" -ForegroundColor Cyan
Write-Host "│   ├── Kedi Savar\" -ForegroundColor White
Write-Host "│   │   └── README.md" -ForegroundColor Gray
Write-Host "│   ├── Bike Power Meter\" -ForegroundColor White
Write-Host "│   │   └── README.md" -ForegroundColor Gray
Write-Host "│   └── Mushroom Pastorization System\" -ForegroundColor White
Write-Host "│       └── README.md" -ForegroundColor Gray
Write-Host "├── Resources\" -ForegroundColor Cyan
Write-Host "│   ├── README.md" -ForegroundColor Gray
Write-Host "│   ├── Documentation\" -ForegroundColor Gray
Write-Host "│   ├── References\" -ForegroundColor Gray
Write-Host "│   ├── Tools\" -ForegroundColor Gray
Write-Host "│   └── Assets\" -ForegroundColor Gray
Write-Host "└── backups\" -ForegroundColor Cyan
Write-Host "    ├── backup-2026-08-04-17-30-00.zip" -ForegroundColor Gray
Write-Host "    ├── backup-2026-08-04-18-00-00.zip" -ForegroundColor Gray
Write-Host "    └── .gitignore" -ForegroundColor Gray
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Navigate to your projects and add your code files" -ForegroundColor White
Write-Host "2. Run backup-project.ps1 to create backups daily" -ForegroundColor White
Write-Host "3. Backups are stored in: backups\ folder" -ForegroundColor White
Write-Host "4. Each backup includes timestamp: backup-YYYY-MM-DD-HH-mm-ss.zip" -ForegroundColor White
Write-Host ""
