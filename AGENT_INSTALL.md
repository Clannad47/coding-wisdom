# Agent Install Protocol

Choose shell: try bash first, fall back to PowerShell if bash unavailable.

## 1. Detect tools

### bash

```bash
HAS_NPM=$(command -v npm >/dev/null 2>&1 && echo 1 || echo 0)
HAS_GIT=$(command -v git >/dev/null 2>&1 && echo 1 || echo 0)
HAS_NODE=$(command -v node >/dev/null 2>&1 && echo 1 || echo 0)
echo "npm=$HAS_NPM git=$HAS_GIT node=$HAS_NODE"
```

### PowerShell

```powershell
$HAS_NPM = if (Get-Command npm -ErrorAction SilentlyContinue) {1} else {0}
$HAS_GIT = if (Get-Command git -ErrorAction SilentlyContinue) {1} else {0}
$HAS_NODE = if (Get-Command node -ErrorAction SilentlyContinue) {1} else {0}
Write-Host "npm=$HAS_NPM git=$HAS_GIT node=$HAS_NODE"
```

## 2. Detect platforms & confirm

### bash

```bash
CLAUDE_EXISTS=0; CODEX_EXISTS=0
test -d "$HOME/.claude" && CLAUDE_EXISTS=1
test -d "$HOME/.codex"  && CODEX_EXISTS=1
echo "claude=$CLAUDE_EXISTS codex=$CODEX_EXISTS"
```

### PowerShell

```powershell
$CLAUDE_EXISTS = if (Test-Path "$env:USERPROFILE\.claude") {1} else {0}
$CODEX_EXISTS  = if (Test-Path "$env:USERPROFILE\.codex")  {1} else {0}
Write-Host "claude=$CLAUDE_EXISTS codex=$CODEX_EXISTS"
```

### Confirmation rule

| claude | codex | action |
|--------|-------|--------|
| 1 | 1 | 向用户确认：检测到 Claude Code 和 Codex CLI，安装到哪个？ 1) 都要 2) 仅 Claude Code 3) 仅 Codex CLI |
| 1 | 0 | `TARGETS="claude"` (no prompt) |
| 0 | 1 | `TARGETS="codex"` (no prompt) |
| 0 | 0 | `TARGETS="claude"` (no prompt, default) |

Set `TARGETS` based on result before proceeding to install.

## 3. Install

Pick the first usable path. npm → Path A. git only → Path B. neither → Path C.

### Path A — npm (implies node via npx, cross-platform)

```bash
npx coding-wisdom
```

### Path B — git, no npm

```bash
git clone https://github.com/Clannad47/coding-wisdom.git /tmp/coding-wisdom
node /tmp/coding-wisdom/install.js
rm -rf /tmp/coding-wisdom
```

If node missing, run Manual install below with `$SRC=/tmp/coding-wisdom`, then rm.

PowerShell:
```powershell
git clone https://github.com/Clannad47/coding-wisdom.git $env:TEMP/coding-wisdom
node $env:TEMP/coding-wisdom/install.js
Remove-Item -Recurse -Force $env:TEMP/coding-wisdom
```

If node missing, run Manual install (PowerShell) below with `$SRC=$env:TEMP/coding-wisdom`, then Remove-Item.

### Path C — no npm, no git

bash:
```bash
curl -sL https://github.com/Clannad47/coding-wisdom/archive/refs/heads/main.zip -o /tmp/cw.zip
unzip -q /tmp/cw.zip -d /tmp/ 2>/dev/null \
  || python -c "import zipfile; zipfile.ZipFile('/tmp/cw.zip').extractall('/tmp/')"
node /tmp/coding-wisdom-main/install.js
rm -rf /tmp/coding-wisdom-main /tmp/cw.zip
```

PowerShell:
```powershell
Invoke-WebRequest -Uri https://github.com/Clannad47/coding-wisdom/archive/refs/heads/main.zip -OutFile $env:TEMP/cw.zip
Expand-Archive -Path $env:TEMP/cw.zip -DestinationPath $env:TEMP/
node $env:TEMP/coding-wisdom-main/install.js
Remove-Item -Recurse -Force $env:TEMP/coding-wisdom-main, $env:TEMP/cw.zip
```

If node missing, run Manual install below first, then cleanup.

### Manual install — pure shell, no node

bash:
```bash
for t in $TARGETS; do
  case $t in
    claude) DEST="$HOME/.claude/skills/coding-wisdom" ;;
    codex) DEST="$HOME/.codex/skills/coding-wisdom" ;;
  esac
  mkdir -p "$DEST/inbox/high" "$DEST/inbox/low"
  mkdir -p "$DEST/references/architecture/data-flow" "$DEST/references/architecture/system-design"
  mkdir -p "$DEST/references/coding/python" "$DEST/references/mindset" "$DEST/references/techstack/llm"
  cp "$SRC/SKILL.md" "$DEST/"
  cp -r "$SRC/guides" "$SRC/templates" "$SRC/scripts" "$DEST/"
  echo "[OK] $t (manual)"
done
```

PowerShell:
```powershell
foreach ($t in $TARGETS) {
  $DEST = if ($t -eq "claude") { "$env:USERPROFILE\.claude\skills\coding-wisdom" }
          else                  { "$env:USERPROFILE\.codex\skills\coding-wisdom" }
  New-Item -Force -ItemType Directory "$DEST/inbox/high", "$DEST/inbox/low" | Out-Null
  New-Item -Force -ItemType Directory "$DEST/references/architecture/data-flow", "$DEST/references/architecture/system-design" | Out-Null
  New-Item -Force -ItemType Directory "$DEST/references/coding/python", "$DEST/references/mindset", "$DEST/references/techstack/llm" | Out-Null
  Copy-Item "$SRC/SKILL.md" "$DEST/"
  Copy-Item "$SRC/guides", "$SRC/templates", "$SRC/scripts" -Recurse -Destination "$DEST/"
  Write-Host "[OK] $t (manual)"
}
```

## 4. Verify

bash:
```bash
test -f "$HOME/.claude/skills/coding-wisdom/SKILL.md" && echo "[OK] Claude Code" || echo "[MISS] Claude Code"
test -f "$HOME/.codex/skills/coding-wisdom/SKILL.md"  && echo "[OK] Codex CLI"  || echo "[MISS] Codex CLI"
```

PowerShell:
```powershell
if (Test-Path "$env:USERPROFILE\.claude\skills\coding-wisdom\SKILL.md") { Write-Host "[OK] Claude Code" } else { Write-Host "[MISS] Claude Code" }
if (Test-Path "$env:USERPROFILE\.codex\skills\coding-wisdom\SKILL.md")  { Write-Host "[OK] Codex CLI" }  else { Write-Host "[MISS] Codex CLI" }
```

## 5. Report

Summarize [OK] / [MISS] per platform. One sentence to user: install done, restart the platform(s).
