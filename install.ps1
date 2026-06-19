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
$skills = @("knowledge-collector", "learn", "kb", "knowledge-profile")
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
Write-Host "[1/4] Installing skills..." -ForegroundColor Green
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
Write-Host "[2/4] Setting up knowledge base..." -ForegroundColor Green

if (-not (Test-Path $KnowledgeDir)) {
    New-Item -ItemType Directory -Path $KnowledgeDir -Force | Out-Null
}

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

$searchIndexPath = Join-Path $KnowledgeDir "search-index.json"
if (Test-Path $searchIndexPath) {
    Write-Host "      search-index.json already exists, skipping"
} else {
    Copy-Item (Join-Path $templateDir "search-index.json") $searchIndexPath
    Write-Host "      + search-index.json"
}

Write-Host "      Done."
Write-Host ""

# Configure permissions
Write-Host "[3/4] Configuring permissions..." -ForegroundColor Green
$settingsPath = Join-Path $ClaudeDir "settings.json"
$requiredRules = @(
    "Read(~/.claude/knowledge/**)",
    "Write(~/.claude/knowledge/**)",
    "Edit(~/.claude/knowledge/**)",
    "Bash(mkdir:~/.claude/knowledge/*)"
)

if (Test-Path $settingsPath) {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

    if (-not $settings.permissions) {
        $settings | Add-Member -NotePropertyName "permissions" -NotePropertyValue ([PSCustomObject]@{ allow = @() })
    }
    if (-not $settings.permissions.allow) {
        $settings.permissions | Add-Member -NotePropertyName "allow" -NotePropertyValue @()
    }

    $existingAllow = @($settings.permissions.allow)
    $addedCount = 0
    foreach ($rule in $requiredRules) {
        if ($existingAllow -notcontains $rule) {
            $existingAllow += $rule
            Write-Host "      + $rule"
            $addedCount++
        } else {
            Write-Host "      $rule (already exists)"
        }
    }
    $settings.permissions.allow = $existingAllow

    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
    Write-Host "      Done. ($addedCount rules added to settings.json)"
} else {
    Write-Host "      [WARN] settings.json not found, skipping permissions." -ForegroundColor Yellow
    Write-Host "      You may need to manually allow access to ~/.claude/knowledge/"
}
Write-Host ""

# Verify
Write-Host "[4/4] Verifying installation..." -ForegroundColor Green
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
Write-Host "  Skills installed: $installedCount/4"
Write-Host "  Knowledge base:   $KnowledgeDir"
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor Green
Write-Host "  1. Restart Claude Code to load new skills"
Write-Host "  2. Run /kb 评估 to initialize your knowledge profile"
Write-Host "  3. Start coding - use /learn <topic> to collect knowledge!"
Write-Host ""
Write-Host "  Commands:"
Write-Host "    /learn <topic>           - Mark a knowledge point"
Write-Host "    /kb                      - Browse knowledge base"
Write-Host "    /kb <entry>              - View entry details"
Write-Host "    /kb 深入 <entry> [方向]   - Append deep dive"
Write-Host "    /kb 测验 [entry]          - Take a quiz"
Write-Host "    /kb 关联 <A> <B>          - Link two entries"
Write-Host "    /kb 删除 <entry>          - Delete an entry"
Write-Host "    /kb 评估                  - Refresh knowledge profile"
Write-Host "    /kb 修复                  - Rebuild index from files"
Write-Host ""
Write-Host "  Note: If upgrading from a previous version with 技/道 directories," -ForegroundColor Yellow
Write-Host "  run: .\migrate.ps1" -ForegroundColor Yellow
Write-Host ""
