$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $repoRoot
try {
    $paths = @(
        "OVERVIEW.md",
        "references/architecture/_index.md",
        "references/coding/_index.md",
        "references/mindset/_index.md",
        "references/techstack/_index.md"
    )

    foreach ($path in $paths) {
        if (Test-Path -LiteralPath $path) {
            git update-index --skip-worktree -- $path
            Write-Host "skip-worktree: $path"
        }
        else {
            Write-Warning "missing: $path"
        }
    }

    Write-Host "Local personal files are now protected from normal git commits."
}
finally {
    Pop-Location
}
