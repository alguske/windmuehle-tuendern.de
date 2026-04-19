#!/usr/bin/env bash

# Regenerate the homepage thumbnail for a post and point its extra.image
# at the given image. Identifies the post by the slug embedded in the
# image path (e.g. /imgs/<slug>/<file>.jpg) and updates the DE, EN, and
# ES versions if present. Removes the previous thumbnail.
#
# Usage:
#   ./scripts/make-thumb.sh <image-path>
#
# Accepted path forms (all resolve to the same image on disk):
#   /imgs/einweihung-der-windmuehle/einweihung-der-windmuehle-06.jpg
#   static/imgs/einweihung-der-windmuehle/einweihung-der-windmuehle-06.jpg
#   imgs/einweihung-der-windmuehle/einweihung-der-windmuehle-06.jpg

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <image-path>" >&2
  exit 1
fi

if ! command -v sips >/dev/null 2>&1; then
  echo "Error: sips not found (macOS required)" >&2
  exit 1
fi

INPUT="$1"

# Normalize input to the web path form used inside extra.image.
case "$INPUT" in
  /imgs/*)       WEB_PATH="$INPUT" ;;
  static/imgs/*) WEB_PATH="/${INPUT#static/}" ;;
  imgs/*)        WEB_PATH="/$INPUT" ;;
  *)
    echo "Error: path must start with /imgs/, static/imgs/, or imgs/" >&2
    exit 1
    ;;
esac

FS_PATH="static${WEB_PATH}"

if [[ ! -f "$FS_PATH" ]]; then
  echo "Error: '$FS_PATH' is not a file" >&2
  exit 1
fi

# Slug = first path segment after /imgs/
SLUG="${WEB_PATH#/imgs/}"
SLUG="${SLUG%%/*}"

if [[ -z "$SLUG" || "$SLUG" == "$WEB_PATH" ]]; then
  echo "Error: could not extract post slug from '$WEB_PATH'" >&2
  exit 1
fi

# Find matching posts across all three language trees.
shopt -s nullglob
POSTS=(
  content/aktuelles/*-"${SLUG}".md
  content/en/aktuelles/*-"${SLUG}".md
  content/es/aktuelles/*-"${SLUG}".md
)
shopt -u nullglob

if [[ ${#POSTS[@]} -eq 0 ]]; then
  echo "Error: no post found for slug '$SLUG' in content/**/aktuelles/" >&2
  exit 1
fi

# Read current extra.image from the first matched post (all languages
# reference the same image path, so any one suffices).
OLD_IMAGE=$(awk -F'"' '/^image = /{print $2; exit}' "${POSTS[0]}")
if [[ -z "$OLD_IMAGE" ]]; then
  echo "Error: post missing extra.image: ${POSTS[0]}" >&2
  exit 1
fi

THUMB_DIR="static/imgs/thumbs"
mkdir -p "$THUMB_DIR"

old_stem=$(basename "$OLD_IMAGE"); old_stem="${old_stem%.*}"
new_stem=$(basename "$FS_PATH");   new_stem="${new_stem%.*}"
OLD_THUMB="${THUMB_DIR}/${old_stem}.jpg"
NEW_THUMB="${THUMB_DIR}/${new_stem}.jpg"

if [[ "$OLD_IMAGE" != "$WEB_PATH" && -f "$OLD_THUMB" ]]; then
  echo "→ Removing old thumb: $OLD_THUMB"
  rm -f "$OLD_THUMB"
fi

echo "→ Generating thumb: $NEW_THUMB"
sips -s format jpeg -s formatOptions 70 --resampleWidth 600 \
  "$FS_PATH" --out "$NEW_THUMB" >/dev/null

if [[ "$OLD_IMAGE" != "$WEB_PATH" ]]; then
  for post in "${POSTS[@]}"; do
    echo "→ Updating extra.image: $post"
    # macOS BSD sed: -i '' requires explicit empty backup suffix.
    sed -i '' -E "s|^image = .*|image = \"${WEB_PATH}\"|" "$post"
  done
fi

echo "✓ Done"
