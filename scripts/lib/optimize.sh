#!/usr/bin/env bash
# Shared image optimization helpers. Source this file to use them.
#
# Functions:
#   optimize_image_in_place <path>    Resize to max 1200px width and re-encode
#                                     JPEG at Q=80. Keeps the result only if
#                                     it is smaller than the original.
#   make_thumb <src> <dest>           Generate a 600px-wide JPEG at Q=70.

set -euo pipefail

IMG_MAX_WIDTH="${IMG_MAX_WIDTH:-1200}"
IMG_QUALITY="${IMG_QUALITY:-80}"
THUMB_WIDTH="${THUMB_WIDTH:-600}"
THUMB_QUALITY="${THUMB_QUALITY:-70}"

if ! command -v sips >/dev/null 2>&1; then
  echo "Error: sips not found (macOS required)" >&2
  exit 1
fi

# Optimize <src> into <dest>: JPEG, max IMG_MAX_WIDTH, Q=IMG_QUALITY. Always writes.
optimize_image() {
  local src="$1" dest="$2"
  local w
  w=$(sips -g pixelWidth "$src" 2>/dev/null | awk '/pixelWidth/{print $2}')
  if [[ -z "$w" ]]; then
    echo "  ! not an image: $src" >&2
    return 1
  fi
  mkdir -p "$(dirname "$dest")"
  if [[ "$w" -gt "$IMG_MAX_WIDTH" ]]; then
    sips -s format jpeg -s formatOptions "$IMG_QUALITY" --resampleWidth "$IMG_MAX_WIDTH" \
      "$src" --out "$dest" >/dev/null
  else
    sips -s format jpeg -s formatOptions "$IMG_QUALITY" \
      "$src" --out "$dest" >/dev/null
  fi
}

# Optimize a JPEG in place. Never inflates: keeps the result only if smaller
# than the original. Emits a warning when an oversized image (wider than
# IMG_MAX_WIDTH) cannot be shrunk below its current byte size.
optimize_image_in_place() {
  local f="$1"
  local w tmp orig_size new_size
  if [[ ! -f "$f" ]]; then
    echo "  ! missing: $f" >&2
    return 1
  fi
  w=$(sips -g pixelWidth "$f" 2>/dev/null | awk '/pixelWidth/{print $2}')
  if [[ -z "$w" ]]; then
    echo "  ! not an image: $f" >&2
    return 1
  fi
  tmp="$(mktemp -t optimg.XXXXXX)"
  if ! optimize_image "$f" "$tmp"; then
    rm -f "$tmp"
    return 1
  fi
  orig_size=$(stat -f%z "$f")
  new_size=$(stat -f%z "$tmp")
  if [[ "$new_size" -lt "$orig_size" ]]; then
    mv "$tmp" "$f"
    local note=""
    [[ "$w" -gt "$IMG_MAX_WIDTH" ]] && note=" (resized ${w}px → ${IMG_MAX_WIDTH}px)"
    printf '  ✓ %s%s (%d → %d bytes, -%d%%)\n' \
      "$f" "$note" "$orig_size" "$new_size" "$(( (orig_size - new_size) * 100 / orig_size ))"
  else
    rm -f "$tmp"
    if [[ "$w" -gt "$IMG_MAX_WIDTH" ]]; then
      printf '  ⚠ %s (%dpx wide, %d bytes — re-encode would inflate; inspect manually)\n' \
        "$f" "$w" "$orig_size"
    else
      printf '  = %s (already optimal, %d bytes)\n' "$f" "$orig_size"
    fi
  fi
}

# Generate a thumbnail from <src> to <dest>. Always writes (overwrite).
make_thumb() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  sips -s format jpeg -s formatOptions "$THUMB_QUALITY" --resampleWidth "$THUMB_WIDTH" \
    "$src" --out "$dest" >/dev/null
}
