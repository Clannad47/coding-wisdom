#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

paths=(
  "OVERVIEW.md"
  "references/architecture/_index.md"
  "references/coding/_index.md"
  "references/mindset/_index.md"
  "references/techstack/_index.md"
)

for path in "${paths[@]}"; do
  if [[ -e "$path" ]]; then
    git update-index --skip-worktree -- "$path"
    printf 'skip-worktree: %s\n' "$path"
  else
    printf 'missing: %s\n' "$path" >&2
  fi
done

printf 'Local personal files are now protected from normal git commits.\n'
