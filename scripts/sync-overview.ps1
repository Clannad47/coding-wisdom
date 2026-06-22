<#
.SYNOPSIS
Generate OVERVIEW.md from references/*/_index.md files.
Single source of truth: each _index.md under references/.
OVERVIEW.md is derived -- never edit it by hand.

.USAGE
powershell -ExecutionPolicy Bypass -File scripts/sync-overview.ps1
powershell -ExecutionPolicy Bypass -File scripts/sync-overview.ps1 -Root C:\path\to\coding-wisdom

Works on Windows PowerShell 5.1+ and PowerShell Core 6+.
#>

param(
    [string]$Root = ""
)

$ErrorActionPreference = "Stop"

# Determine root directory
if (-not $Root) {
    $Root = Split-Path -Parent $PSScriptRoot
}
$Root = (Resolve-Path $Root).Path

$RefsDir = Join-Path $Root "references"
$OverviewPath = Join-Path $Root "OVERVIEW.md"

if (-not (Test-Path $RefsDir)) {
    Write-Error "references/ not found at $RefsDir"
    exit 1
}

# ---- helper functions ----

function Count-Entries($Dir) {
    $n = 0
    if (Test-Path $Dir) {
        Get-ChildItem $Dir -Filter "*.md" -File | ForEach-Object {
            if ($_.Name -ne "_index.md") { $n++ }
        }
    }
    return $n
}

function Count-EntriesRecursive($Dir) {
    $n = 0
    if (Test-Path $Dir) {
        Get-ChildItem $Dir -Filter "*.md" -File -Recurse | ForEach-Object {
            if ($_.Name -ne "_index.md") { $n++ }
        }
    }
    return $n
}

function Get-IndexTitle($File) {
    if (-not (Test-Path $File)) { return "" }
    $line = Get-Content $File -Encoding UTF8 -TotalCount 20 | Where-Object { $_ -match '^# ' } | Select-Object -First 1
    if ($line) { return $line -replace '^# ', '' }
    return ""
}

function Get-IndexDescription($File) {
    if (-not (Test-Path $File)) { return "" }
    $line = Get-Content $File -Encoding UTF8 -TotalCount 20 | Where-Object { $_ -match '^> ' } | Select-Object -First 1
    if ($line) { return $line -replace '^> ', '' }
    return ""
}

# Read all lines from a file as UTF-8, returning an empty array if missing
function Read-Utf8Lines($File) {
    if (Test-Path $File) {
        return @(Get-Content $File -Encoding UTF8)
    }
    return @()
}

# ---- domain display labels ----
$DomainLabels = @{
    "architecture" = "架构"
    "coding"       = "编码"
    "mindset"      = "思维"
    "techstack"    = "技术栈"
}

# Build domain labels from _index.md titles instead of hardcoding
$Now = Get-Date -Format "yyyy-MM-dd HH:mm"
$Lines = [System.Collections.Generic.List[string]]::new()

$Lines.Add("# 知识版图")
$Lines.Add("")
$Lines.Add("> 自动生成于 ${Now}。编辑 references/*/_index.md 来更新此文件。")

$GrandTotal = 0
$Parts = [System.Collections.Generic.List[string]]::new()

$DomainDirs = Get-ChildItem $RefsDir -Directory | Sort-Object Name

foreach ($domainDir in $DomainDirs) {
    $dname = $domainDir.Name
    $idxFile = Join-Path $domainDir.FullName "_index.md"

    $title = Get-IndexTitle $idxFile
    if (-not $title) { $title = $dname }
    $desc = Get-IndexDescription $idxFile

    $total = Count-EntriesRecursive $domainDir.FullName
    $GrandTotal += $total
    $label = if ($DomainLabels.ContainsKey($dname)) { $DomainLabels[$dname] } else { $dname }
    $Parts.Add("${label} ${total}")

    $Lines.Add("")
    $Lines.Add("## ${title} (${dname}/) -- ${total} 条")
    if ($desc) { $Lines.Add("> ${desc}") }

    # Collect subdomain names and data
    $subDirs = Get-ChildItem $domainDir.FullName -Directory -ErrorAction SilentlyContinue | Sort-Object Name
    $subdomainNames = [System.Collections.Generic.List[string]]::new()
    $subdomainList = [System.Collections.Generic.List[hashtable]]::new()
    foreach ($subDir in $subDirs) {
        $subCount = Count-Entries $subDir.FullName
        $subIdx = Join-Path $subDir.FullName "_index.md"
        if ($subCount -gt 0 -or (Test-Path $subIdx)) {
            $subdomainNames.Add($subDir.Name)
            $subdomainList.Add(@{ Name = $subDir.Name; Path = $subDir.FullName; Count = $subCount })
        }
    }

    # ---- meta sections from top-level index ----
    $inSubdomainSection = $false
    foreach ($line in (Read-Utf8Lines $idxFile)) {
        if ($line -match '^### ') {
            $h = $line -replace '^### ', ''
            $Lines.Add("**${h}** :")
            $inSubdomainSection = $false
        }
        elseif ($line -match '^## ') {
            $h = $line -replace '^## ', ''
            $inSubdomainSection = $false
            foreach ($sn in $subdomainNames) {
                if ($h.StartsWith("${sn}/") -or $h.StartsWith("${sn} ")) {
                    $inSubdomainSection = $true
                    break
                }
            }
            if (-not $inSubdomainSection -and $h -ne "已沉淀") {
                $Lines.Add("**${h}** :")
            }
        }
        elseif (($line -match '^- ' -or $line -match '^\* ') -and -not $inSubdomainSection) {
            $Lines.Add($line)
        }
    }
    $Lines.Add("")

    # ---- subdomains ----
    foreach ($sub in $subdomainList) {
        $subname = $sub.Name
        $subIdx = Join-Path $sub.Path "_index.md"
        $subCount = $sub.Count

        $stitle = Get-IndexTitle $subIdx
        if (-not $stitle) { $stitle = $subname }

        $Lines.Add("")
        $Lines.Add("### ${stitle} (${dname}/${subname}/) -- ${subCount} 条")

        foreach ($line in (Read-Utf8Lines $subIdx)) {
            if ($line -match '^### ') {
                $h = $line -replace '^### ', ''
                $Lines.Add("**${h}** :")
            }
            elseif ($line -match '^- ' -or $line -match '^\* ') {
                $Lines.Add($line)
            }
        }
        $Lines.Add("")
    }
}

$Lines.Add("---")
$Lines.Add("")
$Lines.Add("*上次生成: ${Now}*")
$Lines.Add("*总条目: ${GrandTotal} 条 ($($Parts -join ' + '))*")

$NewContent = $Lines -join "`r`n"

# Only write if changed
if (Test-Path $OverviewPath) {
    $Existing = Get-Content $OverviewPath -Encoding UTF8 -Raw
    if ($Existing -eq $NewContent) {
        Write-Host "OVERVIEW.md is current (no changes)"
        exit 0
    }
}

[System.IO.File]::WriteAllText($OverviewPath, $NewContent, [System.Text.UTF8Encoding]::new($false))
$lineCount = $Lines.Count
Write-Host "OVERVIEW.md regenerated -- ${lineCount} lines"
