#!/usr/bin/env bash
# Sweep static/imgs/ and optimize every JPEG in place.
# Shrinks anything wider than 1200px, re-encodes at Q=80, keeps the
# result only when it is smaller than the original. Skips static/imgs/thumbs/.
#
# Usage:
#   ./scripts/optimize-imgs.sh [path ...]
#
# Without arguments, sweeps static/imgs/. With arguments, optimizes each
# given file or directory (directories are walked recursively).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/optimize.sh
source "${SCRIPT_DIR}/lib/optimize.sh"

TARGETS=("$@")
if [[ ${#TARGETS[@]} -eq 0 ]]; then
  TARGETS=("static/imgs")
fi

count=0
shrunk=0
kept=0

process_file() {
  local f="$1"
  case "$f" in
    */thumbs/*) return 0 ;;
  esac
  local before after
  before=$(stat -f%z "$f")
  if ! optimize_image_in_place "$f"; then
    return 0
  fi
  after=$(stat -f%z "$f")
  count=$((count + 1))
  if [[ "$after" -lt "$before" ]]; then
    shrunk=$((shrunk + 1))
  else
    kept=$((kept + 1))
  fi
}

for target in "${TARGETS[@]}"; do
  if [[ -d "$target" ]]; then
    while IFS= read -r -d '' f; do
      process_file "$f"
    done < <(find "$target" -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -not -path '*/thumbs/*' -print0)
  elif [[ -f "$target" ]]; then
    process_file "$target"
  else
    echo "  ! skipped: $target (not a file or directory)" >&2
  fi
done

echo ""
echo "Summary: processed=$count shrunk=$shrunk kept=$kept"
