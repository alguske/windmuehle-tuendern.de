#!/usr/bin/env bash

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/make-thumb.sh"
SEED_IMG="$REPO_ROOT/static/imgs/logo.jpg"

# Seed a temp repo with a post (de/en/es) whose extra.image points at
# image -01 of a slug, plus several optimized images in static/imgs/<slug>/.
function set_up() {
  temp_dir=$(mktemp -d)
  original_dir=$(pwd)
  slug="einweihung-der-windmuehle"

  mkdir -p "$temp_dir/content/aktuelles" \
           "$temp_dir/content/en/aktuelles" \
           "$temp_dir/content/es/aktuelles" \
           "$temp_dir/static/imgs/$slug" \
           "$temp_dir/static/imgs/thumbs"

  for i in 01 02 03 06; do
    cp "$SEED_IMG" "$temp_dir/static/imgs/$slug/$slug-$i.jpg"
  done

  # Initial thumb (for -01) as new-post.sh would have left it.
  cp "$SEED_IMG" "$temp_dir/static/imgs/thumbs/$slug-01.jpg"

  for tree in "aktuelles" "en/aktuelles" "es/aktuelles"; do
    cat > "$temp_dir/content/$tree/2026-04-$slug.md" <<EOF
+++
title = "Einweihung"
date = 2026-04-17
description = "desc"
template = "blog-post.html"

[extra]
image = "/imgs/$slug/$slug-01.jpg"
+++

body
EOF
  done

  cd "$temp_dir"
}

function tear_down() {
  cd "$original_dir"
  rm -rf "$temp_dir"
}

function test_creates_new_thumb_from_web_path() {
  "$SCRIPT" "/imgs/$slug/$slug-06.jpg" >/dev/null

  assert_file_exists "static/imgs/thumbs/$slug-06.jpg"

  width=$(sips -g pixelWidth "static/imgs/thumbs/$slug-06.jpg" | awk '/pixelWidth/ {print $2}')
  assert_same "600" "$width"
}

function test_removes_old_thumb_when_switching() {
  "$SCRIPT" "/imgs/$slug/$slug-06.jpg" >/dev/null

  assert_file_not_exists "static/imgs/thumbs/$slug-01.jpg"
}

function test_updates_extra_image_in_all_language_posts() {
  "$SCRIPT" "/imgs/$slug/$slug-06.jpg" >/dev/null

  for tree in "aktuelles" "en/aktuelles" "es/aktuelles"; do
    content=$(cat "content/$tree/2026-04-$slug.md")
    assert_contains "image = \"/imgs/$slug/$slug-06.jpg\"" "$content"
  done
}

function test_accepts_filesystem_path_form() {
  "$SCRIPT" "static/imgs/$slug/$slug-02.jpg" >/dev/null

  assert_file_exists "static/imgs/thumbs/$slug-02.jpg"
}

function test_accepts_relative_imgs_path_form() {
  "$SCRIPT" "imgs/$slug/$slug-03.jpg" >/dev/null

  assert_file_exists "static/imgs/thumbs/$slug-03.jpg"
}

function test_idempotent_when_target_matches_current_extra_image() {
  # Same image as current extra.image: regen thumb, leave post alone.
  "$SCRIPT" "/imgs/$slug/$slug-01.jpg" >/dev/null

  assert_file_exists "static/imgs/thumbs/$slug-01.jpg"

  content=$(cat "content/aktuelles/2026-04-$slug.md")
  assert_contains "image = \"/imgs/$slug/$slug-01.jpg\"" "$content"
}

function test_fails_when_image_not_found_on_disk() {
  output=$("$SCRIPT" "/imgs/$slug/$slug-99.jpg" 2>&1) && status=0 || status=$?

  assert_not_equals "0" "$status"
  assert_contains "not a file" "$output"
}

function test_fails_when_no_post_matches_slug() {
  mkdir -p "static/imgs/orphan-slug"
  cp "$SEED_IMG" "static/imgs/orphan-slug/orphan-slug-01.jpg"

  output=$("$SCRIPT" "/imgs/orphan-slug/orphan-slug-01.jpg" 2>&1) && status=0 || status=$?

  assert_not_equals "0" "$status"
  assert_contains "no post found" "$output"
}

function test_fails_when_path_format_invalid() {
  output=$("$SCRIPT" "foo/bar.jpg" 2>&1) && status=0 || status=$?

  assert_not_equals "0" "$status"
  assert_contains "path must start" "$output"
}

function test_fails_when_no_arguments() {
  output=$("$SCRIPT" 2>&1) && status=0 || status=$?

  assert_not_equals "0" "$status"
  assert_contains "Usage" "$output"
}
