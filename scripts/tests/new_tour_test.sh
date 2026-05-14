#!/usr/bin/env bash

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$TEST_DIR/../new-tour.sh"

function set_up() {
  temp_file=$(mktemp)
  cat > "$temp_file" <<'EOF'
# header

EOF
  export FUEHRUNGEN_DATA="$temp_file"
}

function tear_down() {
  rm -f "$temp_file"
  unset FUEHRUNGEN_DATA
}

function test_appends_public_slot_with_defaults() {
  "$SCRIPT" --date 2026-08-09 --time 15:00 --kind public --guide Dirk >/dev/null

  assert_contains 'date = "2026-08-09"' "$(cat "$temp_file")"
  assert_contains 'time = "15:00"' "$(cat "$temp_file")"
  assert_contains 'kind = "public"' "$(cat "$temp_file")"
  assert_contains 'status = "free"' "$(cat "$temp_file")"
  assert_contains 'guide = "Dirk"' "$(cat "$temp_file")"
}

function test_private_defaults_status_to_booked() {
  "$SCRIPT" --date 2026-08-09 --time 15:00 --kind private >/dev/null

  assert_contains 'kind = "private"' "$(cat "$temp_file")"
  assert_contains 'status = "booked"' "$(cat "$temp_file")"
}

function test_omits_duration_when_default() {
  "$SCRIPT" --date 2026-08-09 --time 15:00 --kind public >/dev/null

  assert_not_contains "duration_min" "$(cat "$temp_file")"
}

function test_writes_duration_when_overridden() {
  "$SCRIPT" --date 2026-08-09 --time 15:00 --kind public --duration 90 >/dev/null

  assert_contains "duration_min = 90" "$(cat "$temp_file")"
}

function test_omits_guide_when_not_provided() {
  "$SCRIPT" --date 2026-08-09 --time 15:00 --kind public >/dev/null

  assert_not_contains "guide" "$(cat "$temp_file")"
}

function test_rejects_invalid_date() {
  output=$("$SCRIPT" --date "not-a-date" --time 15:00 --kind public 2>&1) && status=$? || status=$?

  assert_equals "1" "$status"
  assert_contains "Invalid date" "$output"
}

function test_rejects_invalid_time() {
  output=$("$SCRIPT" --date 2026-08-09 --time "noon" --kind public 2>&1) && status=$? || status=$?

  assert_equals "1" "$status"
  assert_contains "Invalid time" "$output"
}

function test_rejects_private_with_free_status() {
  output=$("$SCRIPT" --date 2026-08-09 --time 15:00 --kind private --status free 2>&1) && status=$? || status=$?

  assert_equals "1" "$status"
  assert_contains "Private slot cannot have status 'free'" "$output"
}

function test_rejects_unknown_kind() {
  output=$("$SCRIPT" --date 2026-08-09 --time 15:00 --kind weird 2>&1) && status=$? || status=$?

  assert_equals "1" "$status"
  assert_contains "Invalid kind" "$output"
}

function test_rejects_missing_required_args() {
  output=$("$SCRIPT" --time 15:00 --kind public 2>&1) && status=$? || status=$?

  assert_equals "1" "$status"
  assert_contains "--date required" "$output"
}

function test_escapes_quotes_in_guide() {
  "$SCRIPT" --date 2026-08-09 --time 15:00 --kind public --guide 'Dirk "Captain"' >/dev/null

  assert_contains 'guide = "Dirk \"Captain\""' "$(cat "$temp_file")"
}
