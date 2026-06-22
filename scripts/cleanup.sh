#!/usr/bin/env bash
# ============================================================================
# coding-wisdom 自清洁脚本 (bash)
#   - inbox/low/ 中 >7 天的条目 → 直接删除
#   - references/ 中 >90 天未更新的条目 → 在 frontmatter 标记 stale: true
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
INBOX_LOW="$SKILL_DIR/inbox/low"
REFS_DIR="$SKILL_DIR/references"

deleted=0
stale=0

echo "=== coding-wisdom self-cleanup ==="
echo ""

# ── 1. inbox/low/ : delete entries older than 7 days ────────────────────────
if [ -d "$INBOX_LOW" ]; then
    while IFS= read -r -d '' file; do
        echo "  [DEL] $file"
        rm "$file"
        deleted=$((deleted + 1))
    done < <(find "$INBOX_LOW" -name "*.md" -mtime +6 -print0 2>/dev/null || true)

    # Remove empty directories left behind
    find "$INBOX_LOW" -type d -empty -delete 2>/dev/null || true

    echo "  -> Deleted $deleted file(s) (>7 days)"
else
    echo "  [skip] inbox/low/ not found"
fi

echo ""

# ── 2. references/ : mark entries older than 90 days as stale ────────────────
mark_stale() {
    local file="$1"
    # Skip if already marked stale
    if grep -q '^stale: true' "$file" 2>/dev/null; then
        return 1
    fi

    awk '
    BEGIN { in_front = 0; has_stale = 0; front_done = 0 }
    /^---$/ {
        if (!front_done && in_front == 0) { in_front = 1; print; next }
        if (!front_done && in_front == 1 && has_stale == 0) {
            print "stale: true"; front_done = 1; in_front = 0; print; next
        }
        if (!front_done && in_front == 1 && has_stale == 1) {
            front_done = 1; in_front = 0; print; next
        }
        print
        next
    }
    /^stale:/ { if (in_front == 1) has_stale = 1 }
    { print }
    ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    return 0
}

if [ -d "$REFS_DIR" ]; then
    while IFS= read -r -d '' file; do
        if mark_stale "$file"; then
            echo "  [STALE] $file"
            stale=$((stale + 1))
        fi
    done < <(find "$REFS_DIR" -name "*.md" -not -name "_index.md" -mtime +89 -print0 2>/dev/null || true)

    echo "  -> Marked $stale file(s) as stale (>90 days)"
else
    echo "  [skip] references/ not found"
fi

echo ""
echo "Done."
