# ============================================================================
# coding-wisdom self-cleanup script (PowerShell 5.1+)
#   - inbox/low/ entries older than 7 days: deleted
#   - references/ entries older than 90 days: marked stale in frontmatter
# ============================================================================
param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir  = Split-Path -Parent $ScriptDir
$InboxLow  = Join-Path $SkillDir "inbox\low"
$RefsDir   = Join-Path $SkillDir "references"

$deleted = 0
$stale   = 0

Write-Host "=== coding-wisdom self-cleanup ==="
Write-Host ""

# -- 1. inbox/low/ : delete entries older than 7 days -----------------------
if (Test-Path $InboxLow) {
    $cutoff7 = (Get-Date).AddDays(-7)
    $oldFiles = Get-ChildItem -Path $InboxLow -Filter "*.md" -File -ErrorAction SilentlyContinue |
                Where-Object { $_.LastWriteTime -lt $cutoff7 }

    foreach ($f in $oldFiles) {
        Write-Host "  [DEL] $($f.FullName)"
        if (-not $DryRun) {
            Remove-Item $f.FullName -Force
        }
        $deleted++
    }

    # Remove empty directories
    if (-not $DryRun) {
        Get-ChildItem -Path $InboxLow -Directory -Recurse -ErrorAction SilentlyContinue |
            Where-Object { @(Get-ChildItem $_.FullName -Force).Count -eq 0 } |
            ForEach-Object { Remove-Item $_.FullName -Force }
    }

    Write-Host "  -> Deleted $deleted file(s) (>7 days)"
}
else {
    Write-Host "  [skip] inbox/low/ not found"
}

Write-Host ""

# -- 2. references/ : mark entries older than 90 days as stale --------------
function Mark-Stale {
    param([string]$Path, [bool]$DryRun = $false)
    # Returns $true if stale was actually added, $false if skipped

    $lines = Get-Content $Path -Encoding UTF8
    $frontStart = -1
    $frontEnd   = -1

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq '---') {
            if ($frontStart -eq -1) { $frontStart = $i }
            elseif ($frontEnd -eq -1) { $frontEnd = $i; break }
        }
    }

    if ($frontEnd -le $frontStart) { return $false }

    # Check if stale already present
    $hasStale = $false
    for ($j = $frontStart + 1; $j -lt $frontEnd; $j++) {
        if ($lines[$j] -match '^stale:') { $hasStale = $true; break }
    }
    if ($hasStale) { return $false }

    if (-not $DryRun) {
        $newLines = $lines[0..($frontEnd - 1)] + @('stale: true') + $lines[$frontEnd..($lines.Count - 1)]
        Set-Content $Path $newLines -Encoding UTF8
    }
    return $true
}

if (Test-Path $RefsDir) {
    $cutoff90 = (Get-Date).AddDays(-90)
    $oldRefs = Get-ChildItem -Path $RefsDir -Filter "*.md" -File -Recurse -ErrorAction SilentlyContinue |
               Where-Object { $_.Name -ne "_index.md" -and $_.LastWriteTime -lt $cutoff90 }

    foreach ($f in $oldRefs) {
        if (Mark-Stale $f.FullName -DryRun:$DryRun) {
            Write-Host "  [STALE] $($f.FullName)"
            $stale++
        }
    }

    Write-Host "  -> Marked $stale file(s) as stale (>90 days)"
}
else {
    Write-Host "  [skip] references/ not found"
}

Write-Host ""
Write-Host "Done."
