#!/usr/bin/env bash
# Generate OVERVIEW.md from references/*/_index.md files.
# Single source of truth: each _index.md under references/.
# OVERVIEW.md is derived — never edit it by hand.
#
# Usage:
#   bash scripts/sync-overview.sh [--root /path/to/coding-wisdom]
#
# Works on macOS, Linux, and Windows (Git Bash / WSL).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [ "${1:-}" = "--root" ] && [ -n "${2:-}" ]; then
    ROOT="$(cd "$2" && pwd)"
fi

REFS_DIR="$ROOT/references"
OVERVIEW="$ROOT/OVERVIEW.md"

if [ ! -d "$REFS_DIR" ]; then
    echo "Error: references/ not found at $REFS_DIR" >&2
    exit 1
fi

# ---- helpers ----

count_entries() {
    local dir="$1"
    local n=0
    for f in "$dir"/*.md; do
        [ -f "$f" ] || continue
        case "$(basename "$f")" in
            _index.md) ;;
            *) n=$((n + 1)) ;;
        esac
    done
    echo "$n"
}

count_entries_recursive() {
    local dir="$1"
    local n=0
    while IFS= read -r f; do
        case "$(basename "$f")" in
            _index.md) ;;
            *) n=$((n + 1)) ;;
        esac
    done < <(find "$dir" -name "*.md" -type f 2>/dev/null)
    echo "$n"
}

index_title() {
    # first "# " line
    grep -m1 '^# ' "$1" 2>/dev/null | sed 's/^# //' || true
}

index_description() {
    # first "> " line
    grep -m1 '^> ' "$1" 2>/dev/null | sed 's/^> //' || true
}

# Extract entries (lines starting with "- **" or "- ") under a given section heading
# Usage: extract_section_entries FILE HEADING
# Returns all "- " lines from the given ##/### heading until next heading or EOF
extract_section() {
    local file="$1"
    local heading="$2"
    awk -v h="$heading" '
        BEGIN { in_section=0 }
        /^## / || /^### / {
            if (in_section) exit
            if ($0 ~ h) { in_section=1; next }
        }
        in_section && /^- / { print }
    ' "$file"
}

# Get all entries regardless of section (used when no section heading is specified)
extract_all_entries() {
    local file="$1"
    awk '/^- / { print }' "$file"
}

# ---- collect domains ----

declare -A DOMAIN_LABELS
DOMAIN_LABELS[architecture]="架构"
DOMAIN_LABELS[coding]="编码"
DOMAIN_LABELS[mindset]="思维"
DOMAIN_LABELS[techstack]="技术栈"

# Build temp output
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

NOW=$(date '+%Y-%m-%d %H:%M' 2>/dev/null || date 2>/dev/null || echo "")

{
    echo "# 知识版图"
    echo ""
    echo "> 自动生成于 ${NOW}。编辑 \`references/*/_index.md\` 来更新此文件。"

    GRAND_TOTAL=0
    PARTS=()

    # Iterate top-level domain dirs in sorted order
    for domain_dir in $(find "$REFS_DIR" -maxdepth 1 -mindepth 1 -type d | sort); do
        dname=$(basename "$domain_dir")
        idx_file="$domain_dir/_index.md"

        title="$dname"
        desc=""
        if [ -f "$idx_file" ]; then
            title=$(index_title "$idx_file")
            [ -z "$title" ] && title="$dname"
            desc=$(index_description "$idx_file")
        fi

        total=$(count_entries_recursive "$domain_dir")
        GRAND_TOTAL=$((GRAND_TOTAL + total))
        label="${DOMAIN_LABELS[$dname]:-$dname}"
        PARTS+=("${label} ${total}")

        echo ""
        echo "## ${title} (${dname}/) — ${total} 条"
        [ -n "$desc" ] && echo "> ${desc}"

        # Collect subdomain names for filtering top-level sections
        subdomain_names=""
        for sub_dir in $(find "$domain_dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort); do
            subname=$(basename "$sub_dir")
            sub_count=$(count_entries "$sub_dir")
            if [ "$sub_count" -gt 0 ] || [ -f "$sub_dir/_index.md" ]; then
                subdomain_names="$subdomain_names $subname"
            fi
        done

        # ---- meta sections from top-level index ----
        if [ -f "$idx_file" ]; then
            current_section=""
            while IFS= read -r line; do
                case "$line" in
                    "### "*)
                        h="${line#\#\#\# }"
                        current_section="$h"
                        echo "**${h}**："
                        ;;
                    "## "*)
                        h="${line#\#\# }"
                        # Check if this heading names a subdomain
                        skip=0
                        for sn in $subdomain_names; do
                            case "$h" in
                                "$sn/"*|"$sn —"*) skip=1; break ;;
                            esac
                        done
                        current_section="$h"
                        if [ "$skip" -eq 0 ] && [ "$h" != "核心关注" ] && [ "$h" != "已沉淀" ]; then
                            echo "**${h}**："
                        fi
                        ;;
                    "- "*|"* "*)
                        if [ -n "$current_section" ]; then
                            # Check if current section is a subdomain section (skip)
                            skip=0
                            for sn in $subdomain_names; do
                                case "$current_section" in
                                    "$sn/"*|"$sn —"*) skip=1; break ;;
                                esac
                            done
                            if [ "$skip" -eq 0 ]; then
                                echo "$line"
                            fi
                        fi
                        ;;
                esac
            done < "$idx_file"
            echo ""
        fi

        # ---- subdomains ----
        for sub_dir in $(find "$domain_dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort); do
            subname=$(basename "$sub_dir")
            sub_idx="$sub_dir/_index.md"
            sub_count=$(count_entries "$sub_dir")

            if [ "$sub_count" -eq 0 ] && [ ! -f "$sub_idx" ]; then
                continue
            fi

            stitle="$subname"
            if [ -f "$sub_idx" ]; then
                stitle=$(index_title "$sub_idx")
                [ -z "$stitle" ] && stitle="$subname"
            fi

            echo ""
            echo "### ${stitle} (${dname}/${subname}/) — ${sub_count} 条"

            if [ -f "$sub_idx" ]; then
                # Emit entries grouped by ### headings
                current_section=""
                while IFS= read -r line; do
                    case "$line" in
                        "### "*)
                            h="${line#\#\#\# }"
                            echo "**${h}**："
                            current_section="$h"
                            ;;
                        "- "*|"* "*)
                            echo "$line"
                            ;;
                    esac
                done < "$sub_idx"
            fi
            echo ""
        done
    done

    echo "---"
    echo ""
    echo "*上次生成：${NOW}*"
    echo "*总条目：${GRAND_TOTAL} 条（${PARTS[*]}）*"

} > "$TMP"

# Compare with existing — only write if changed
if [ -f "$OVERVIEW" ] && cmp -s "$TMP" "$OVERVIEW"; then
    echo "OVERVIEW.md is current (no changes)"
    rm -f "$TMP"
    exit 0
fi

mv "$TMP" "$OVERVIEW"
echo "OVERVIEW.md regenerated — $(wc -l < "$OVERVIEW") lines"
