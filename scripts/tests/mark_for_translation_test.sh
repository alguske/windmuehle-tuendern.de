#!/usr/bin/env bash

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$TEST_DIR/../mark-for-translation.sh"

function set_up() {
  temp_dir=$(mktemp -d)
  echo "Original content" > "$temp_dir/sample.md"
}

function tear_down() {
  rm -rf "$temp_dir"
}

function test_mark_for_translation_creates_marker_file() {
  "$SCRIPT" "$temp_dir"

  content=$(cat "$temp_dir/sample.md")

  assert_same "to be translated" "$content"
}
