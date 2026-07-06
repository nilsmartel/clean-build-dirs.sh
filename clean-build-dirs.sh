#!/usr/bin/env bash
#
# clean_build_dirs.sh
#
# Recursively finds and removes all "node_modules" directories and all
# Rust "target" directories starting from the current directory.
#
# Usage:
#   ./clean_build_dirs.sh          # show what would be deleted (dry run)
#   ./clean_build_dirs.sh --force  # actually delete
#
# By default this script runs in DRY RUN mode and only prints what it
# would remove. Pass --force (or -f) to actually delete the directories.

set -euo pipefail

ROOT_DIR="."
DRY_RUN=true

for arg in "$@"; do
    case "$arg" in
        --force|-f)
            DRY_RUN=false
            ;;
        --help|-h)
            echo "Usage: $0 [--force]"
            echo "  --force, -f   Actually delete directories (default is dry run)"
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            echo "Usage: $0 [--force]" >&2
            exit 1
            ;;
    esac
done

echo "Searching for node_modules and Rust target directories under: $(pwd)"
if $DRY_RUN; then
    echo "Running in DRY RUN mode. No files will be deleted."
    echo "Re-run with --force to actually delete."
fi
echo

total_size=0
count=0

# Find node_modules directories, and "target" directories that look like
# Rust build output (contain a Cargo.toml in their parent directory).
# -prune keeps find from descending into a matched directory (e.g. into
# nested node_modules inside node_modules, or target dirs), which avoids
# redundant work and accidental matches inside already-matched trees.

while IFS= read -r -d '' dir; do
    base="$(basename "$dir")"
    parent="$(dirname "$dir")"

    is_target_dir=false
    if [[ "$base" == "target" && -f "$parent/Cargo.toml" ]]; then
        is_target_dir=true
    fi

    if [[ "$base" == "node_modules" || "$is_target_dir" == true ]]; then
        size=$(du -sh "$dir" 2>/dev/null | cut -f1)
        count=$((count + 1))
        if $DRY_RUN; then
            echo "[DRY RUN] Would remove: $dir (size: $size)"
        else
            echo "Removing: $dir (size: $size)"
            rm -rf -- "$dir"
        fi
    fi
done < <(find "$ROOT_DIR" \( -type d \( -name node_modules -o -name target \) \) -prune -print0)

echo
echo "Done. $count directories $($DRY_RUN && echo "found (dry run)" || echo "removed")."
