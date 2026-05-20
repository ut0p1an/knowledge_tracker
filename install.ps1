# Knowledge Tracker Plugin - Install Script (PowerShell)
# For Windows users running PowerShell

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$SkillsDir = Join-Path $ClaudeDir "skills"
$KnowledgeDir = Join-Path $ClaudeDir "knowledge"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Knowledge Tracker Plugin - Installer" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if .claude directory exists
if (-not (Test-Path $ClaudeDir)) {
    Write-Host "[!] ~/.claude directory not found." -ForegroundColor Red
    Write-Host "    Please make sure Claude Code is installed first."
    exit 1
}

# Check for existing skills
$skills = @("knowledge-collector", "learn", "kb-list", "kb-detail", "kb-delete", "kb-simplify", "kb-deep", "kb-assess", "knowledge-profile")
$existingCount = 0
foreach ($skill in $skills) {
    if (Test-Path (Join-Path $SkillsDir $skill)) {
        $existingCount++
    }
}

if ($existingCount -gt 0) {
    Write-Host "[!] Found $existingCount existing knowledge-tracker skills." -ForegroundColor Yellow
    $confirm = Read-Host "    Overwrite? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "    Installation cancelled."
        exit 0
    }
    Write-Host ""
}

# Install skills
Write-Host "[1/3] Installing skills..." -ForegroundColor Green
if (-not (Test-Path $SkillsDir)) {
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
}

$skillDirs = Get-ChildItem -Path (Join-Path $ScriptDir "skills") -Directory
foreach ($skillDir in $skillDirs) {
    $targetDir = Join-Path $SkillsDir $skillDir.Name
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
    Copy-Item (Join-Path $skillDir.FullName "SKILL.md") (Join-Path $targetDir "SKILL.md") -Force
    Write-Host "      + $($skillDir.Name)"
}

Write-Host "      Done. ($($skillDirs.Count) skills installed)"
Write-Host ""

# Install knowledge base template
Write-Host "[2/3] Setting up knowledge base..." -ForegroundColor Green

$jiDir = Join-Path $KnowledgeDir ([char]0x6280)  # 技
$daoDir = Join-Path $KnowledgeDir ([char]0x9053)  # 道

if (-not (Test-Path $jiDir)) { New-Item -ItemType Directory -Path $jiDir -Force | Out-Null }
if (-not (Test-Path $daoDir)) { New-Item -ItemType Directory -Path $daoDir -Force | Out-Null }

$templateDir = Join-Path $ScriptDir "knowledge-template"

$indexPath = Join-Path $KnowledgeDir "INDEX.md"
if (Test-Path $indexPath) {
    Write-Host "      INDEX.md already exists, skipping"
} else {
    Copy-Item (Join-Path $templateDir "INDEX.md") $indexPath
    Write-Host "      + INDEX.md"
}

$profilePath = Join-Path $KnowledgeDir "profile.md"
if (Test-Path $profilePath) {
    Write-Host "      profile.md already exists, skipping"
} else {
    Copy-Item (Join-Path $templateDir "profile.md") $profilePath
    Write-Host "      + profile.md"
}

$historyPath = Join-Path $KnowledgeDir "assess-history.json"
if (Test-Path $historyPath) {
    Write-Host "      assess-history.json already exists, skipping"
} else {
    Copy-Item (Join-Path $templateDir "assess-history.json") $historyPath
    Write-Host "      + assess-history.json"
}

Write-Host "      Done."
Write-Host ""

# Verify
Write-Host "[3/3] Verifying installation..." -ForegroundColor Green
$installedCount = 0
foreach ($skill in $skills) {
    $skillFile = Join-Path $SkillsDir "$skill\SKILL.md"
    if (Test-Path $skillFile) {
        $installedCount++
    } else {
        Write-Host "      [WARN] $skill not found!" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Installation complete!" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Skills installed: $installedCount/9"
Write-Host "  Knowledge base:   $KnowledgeDir"
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor Green
Write-Host "  1. Restart Claude Code to load new skills"
Write-Host "  2. Run /kb-assess to initialize your knowledge profile"
Write-Host "  3. Start coding - knowledge collection is automatic!"
Write-Host ""
Write-Host "  Commands:"
Write-Host "    /learn <topic>       - Mark a knowledge point"
Write-Host "    /kb-list             - View knowledge catalog"
Write-Host "    /kb-detail <entry>   - View entry details"
Write-Host "    /kb-simplify <entry> - Simplified explanation"
Write-Host "    /kb-deep <entry>     - Deep dive explanation"
Write-Host "    /kb-delete <entry>   - Delete an entry"
Write-Host "    /kb-assess           - Run self-assessment"
Write-Host ""
