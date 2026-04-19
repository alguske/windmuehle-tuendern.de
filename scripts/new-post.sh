#!/usr/bin/env bash

# Emergency offline script to create a new DE aktuelles post.
# Optimizes images, generates thumbnail, scaffolds markdown with frontmatter.
#
# Usage:
#   ./scripts/new-post.sh <slug> [options]
#
# Options:
#   -d, --dir <path>          Source image directory (default: local/imgs/)
#   -t, --title <string>      Post title (default: slug humanized)
#   -s, --summary <string>    Description for frontmatter (default: title)
#   -D, --date <YYYY-MM-DD>   Post date (default: today)
#   -h, --help                Show this help
#
# Example:
#   ./scripts/new-post.sh fluegel-montage -t "Flügelmontage" -s "Die neuen Flügel wurden montiert."

# ./scripts/new-post.sh einweihung-der-windmuehle -s "Wir hatten am 17. April eine schöne Einweihung der Windmühle. Über die vielen Besucher haben wir uns sehr gefreut. Wir bedanken uns für die Glückwünsche und die großen und kleinen Spenden."

set -euo pipefail

SRC_DIR="local/imgs/"
SLUG=""
TITLE=""
SUMMARY=""
DATE="$(date +%Y-%m-%d)"

usage() {
  sed -n '3,17p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dir)     SRC_DIR="$2"; shift 2 ;;
    -t|--title)   TITLE="$2"; shift 2 ;;
    -s|--summary) SUMMARY="$2"; shift 2 ;;
    -D|--date)    DATE="$2"; shift 2 ;;
    -h|--help)    usage 0 ;;
    -*)           echo "Unknown option: $1" >&2; usage 1 ;;
    *)            if [[ -z "$SLUG" ]]; then SLUG="$1"; else echo "Too many args" >&2; usage 1; fi; shift ;;
  esac
done

if [[ -z "$SLUG" ]]; then
  echo "Error: <slug> required" >&2
  usage 1
fi

if ! [[ "$SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "Error: slug must be lowercase kebab-case (a-z, 0-9, -)" >&2
  exit 1
fi

if ! [[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Error: date must be YYYY-MM-DD" >&2
  exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Error: source dir '$SRC_DIR' does not exist" >&2
  exit 1
fi

if ! command -v sips >/dev/null 2>&1; then
  echo "Error: sips not found (macOS required)" >&2
  exit 1
fi

# Humanize slug for default title
humanize() {
  echo "$1" | tr '-' ' ' | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1'
}

[[ -z "$TITLE" ]]   && TITLE="$(humanize "$SLUG")"
[[ -z "$SUMMARY" ]] && SUMMARY="$TITLE"

YEAR_MONTH="${DATE:0:7}"
POST_FILE="content/aktuelles/${YEAR_MONTH}-${SLUG}.md"
IMG_DIR="static/imgs/${SLUG}"
THUMB_DIR="static/imgs/thumbs"

if [[ -e "$POST_FILE" ]]; then
  echo "Error: post already exists: $POST_FILE" >&2
  exit 1
fi

mkdir -p "$IMG_DIR" "$THUMB_DIR"

# Collect source images (jpg/jpeg/png/heic), case-insensitive, sorted
shopt -s nullglob nocaseglob
SRC_IMAGES=()
for f in "$SRC_DIR"/*.{jpg,jpeg,png,heic}; do
  [[ -f "$f" ]] && SRC_IMAGES+=("$f")
done
shopt -u nocaseglob
shopt -u nullglob

if [[ ${#SRC_IMAGES[@]} -eq 0 ]]; then
  echo "Error: no images found in '$SRC_DIR' (jpg/jpeg/png/heic)" >&2
  exit 1
fi

# Sort deterministically
IFS=$'\n' SRC_IMAGES=($(printf '%s\n' "${SRC_IMAGES[@]}" | sort))
unset IFS

echo "→ Found ${#SRC_IMAGES[@]} image(s) in $SRC_DIR"

OPTIMIZED_NAMES=()
i=1
for src in "${SRC_IMAGES[@]}"; do
  num="$(printf '%02d' "$i")"
  dest_name="${SLUG}-${num}.jpg"
  dest_path="${IMG_DIR}/${dest_name}"

  echo "  [${num}] $(basename "$src") → $dest_path"
  sips -s format jpeg -s formatOptions 80 --resampleWidth 1200 \
    "$src" --out "$dest_path" >/dev/null

  OPTIMIZED_NAMES+=("$dest_name")
  i=$((i+1))
done

# Generate thumbnail for the first optimized image (used as extra.image).
# If extra.image is later changed to a different image in the post folder,
# run scripts/make-thumb.sh on that image to swap the thumbnail.
FIRST_IMG="${OPTIMIZED_NAMES[0]}"
THUMB_FILE="${THUMB_DIR}/${FIRST_IMG}"
echo "→ Generating thumbnail: $THUMB_FILE"
sips -s format jpeg -s formatOptions 70 --resampleWidth 600 \
  "${SRC_IMAGES[0]}" --out "$THUMB_FILE" >/dev/null

# Build gallery markdown: single <div class="post-images">. The grid is
# 2-column; splitting into multiple divs produces orphan rows and oversized
# gaps. Split manually after editing if logical sections are needed.
build_gallery() {
  echo ""
  echo "<div class=\"post-images\">"
  for name in "${OPTIMIZED_NAMES[@]}"; do
    echo "  <img src=\"/imgs/${SLUG}/${name}\">"
  done
  echo "</div>"
}

GALLERY="$(build_gallery)"

# Write post
cat > "$POST_FILE" <<EOF
+++
title = "${TITLE}"
date = ${DATE}
description = "${SUMMARY}"
template = "blog-post.html"

[extra]
image = "/imgs/${SLUG}/${FIRST_IMG}"
+++

${SUMMARY}
${GALLERY}
EOF

echo ""
echo "✓ Post created:   $POST_FILE"
echo "✓ Images:         $IMG_DIR/ (${#OPTIMIZED_NAMES[@]} files)"
echo "✓ Thumbnail:      $THUMB_FILE"
echo ""
echo "Next steps:"
echo "  1. Edit $POST_FILE — replace TODOs, add alt texts"
echo "  2. Create EN + ES translations in content/en/aktuelles/ and content/es/aktuelles/"
echo "  3. Run: zola build"
