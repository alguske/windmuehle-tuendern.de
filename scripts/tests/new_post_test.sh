#!/usr/bin/env bash

# Absolute paths resolved at load time — tests cd into temp dirs.
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/new-post.sh"
SEED_IMG="$REPO_ROOT/static/imgs/logo.jpg"

function set_up() {
  temp_dir=$(mktemp -d)
  original_dir=$(pwd)
  mkdir -p "$temp_dir/content/aktuelles" \
           "$temp_dir/static/imgs/thumbs" \
           "$temp_dir/local/imgs"
  cp "$SEED_IMG" "$temp_dir/local/imgs/photo-a.jpg"
  cp "$SEED_IMG" "$temp_dir/local/imgs/photo-b.jpg"
  cp "$SEED_IMG" "$temp_dir/local/imgs/photo-c.jpg"
  cd "$temp_dir"
}

function tear_down() {
  cd "$original_dir"
  rm -rf "$temp_dir"
}

function test_creates_post_file_with_date_prefix() {
  "$SCRIPT" my-slug -D 2026-05-10 >/dev/null

  assert_file_exists "content/aktuelles/2026-05-my-slug.md"
}

function test_post_frontmatter_contains_title_date_description() {
  "$SCRIPT" baustelle -t "Baustelle" -s "Infos zur Baustelle" -D 2026-05-10 >/dev/null

  content=$(cat "content/aktuelles/2026-05-baustelle.md")

  assert_contains 'title = "Baustelle"' "$content"
  assert_contains 'date = 2026-05-10' "$content"
  assert_contains 'description = "Infos zur Baustelle"' "$content"
  assert_contains 'template = "blog-post.html"' "$content"
}

function test_humanizes_slug_to_title_when_title_omitted() {
  "$SCRIPT" neue-fluegel -D 2026-05-10 >/dev/null

  content=$(cat "content/aktuelles/2026-05-neue-fluegel.md")

  assert_contains 'title = "Neue Fluegel"' "$content"
}

function test_optimizes_images_to_static_dir() {
  "$SCRIPT" my-slug -D 2026-05-10 >/dev/null

  assert_file_exists "static/imgs/my-slug/my-slug-01.jpg"
  assert_file_exists "static/imgs/my-slug/my-slug-02.jpg"
  assert_file_exists "static/imgs/my-slug/my-slug-03.jpg"
}

function test_resizes_post_images_to_1200px_width() {
  "$SCRIPT" my-slug -D 2026-05-10 >/dev/null

  width=$(sips -g pixelWidth "static/imgs/my-slug/my-slug-01.jpg" | awk '/pixelWidth/ {print $2}')

  assert_same "1200" "$width"
}

function test_generates_thumbnail() {
  "$SCRIPT" my-slug -D 2026-05-10 >/dev/null

  assert_file_exists "static/imgs/thumbs/my-slug.jpg"

  width=$(sips -g pixelWidth "static/imgs/thumbs/my-slug.jpg" | awk '/pixelWidth/ {print $2}')
  assert_same "600" "$width"
}

function test_gallery_references_optimized_image_paths() {
  "$SCRIPT" my-slug -D 2026-05-10 >/dev/null

  content=$(cat "content/aktuelles/2026-05-my-slug.md")

  assert_contains '/imgs/my-slug/my-slug-01.jpg' "$content"
  assert_contains '/imgs/my-slug/my-slug-02.jpg' "$content"
  assert_contains '<div class="post-images">' "$content"
}

function test_frontmatter_extra_image_uses_first_optimized() {
  "$SCRIPT" my-slug -D 2026-05-10 >/dev/null

  content=$(cat "content/aktuelles/2026-05-my-slug.md")

  assert_contains 'image = "/imgs/my-slug/my-slug-01.jpg"' "$content"
}

function test_custom_source_dir_option() {
  mkdir -p custom-dir
  cp "$SEED_IMG" custom-dir/x.jpg

  "$SCRIPT" my-slug -d custom-dir -D 2026-05-10 >/dev/null

  assert_file_exists "static/imgs/my-slug/my-slug-01.jpg"
}

function test_fails_when_slug_missing() {
  output=$("$SCRIPT" 2>&1) && status=0 || status=$?

  assert_not_equals "0" "$status"
  assert_contains "slug" "$output"
}

function test_fails_when_slug_invalid_format() {
  output=$("$SCRIPT" "Bad Slug" -D 2026-05-10 2>&1) && status=0 || status=$?

  assert_not_equals "0" "$status"
  assert_contains "kebab-case" "$output"
}

function test_fails_when_date_invalid_format() {
  output=$("$SCRIPT" my-slug -D "10-05-2026" 2>&1) && status=0 || status=$?

  assert_not_equals "0" "$status"
  assert_contains "YYYY-MM-DD" "$output"
}

function test_fails_when_source_dir_missing() {
  output=$("$SCRIPT" my-slug -d does-not-exist -D 2026-05-10 2>&1) && status=0 || status=$?

  assert_not_equals "0" "$status"
  assert_contains "does not exist" "$output"
}

function test_fails_when_source_dir_has_no_images() {
  mkdir -p empty-dir

  output=$("$SCRIPT" my-slug -d empty-dir -D 2026-05-10 2>&1) && status=0 || status=$?

  assert_not_equals "0" "$status"
  assert_contains "no images" "$output"
}

function test_fails_when_post_already_exists() {
  "$SCRIPT" my-slug -D 2026-05-10 >/dev/null

  output=$("$SCRIPT" my-slug -D 2026-05-10 2>&1) && status=0 || status=$?

  assert_not_equals "0" "$status"
  assert_contains "already exists" "$output"
}
