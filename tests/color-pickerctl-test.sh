#!/usr/bin/env bash

# SPDX-License-Identifier: GPL-3.0-only

set -euo pipefail

readonly ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly CONTROL="$ROOT_DIR/scripts/color-pickerctl"
readonly FIXTURES="$ROOT_DIR/tests/fixtures"
readonly TEST_DIR="$(mktemp -d)"
readonly ARGS_FILE="$TEST_DIR/args"
readonly CLIPBOARD_FILE="$TEST_DIR/clipboard"

trap 'rm -rf -- "$TEST_DIR"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_equal() {
  local expected="$1"
  local actual="$2"
  local label="$3"
  [[ $actual == "$expected" ]] || fail "$label: expected '$expected', got '$actual'"
}

run_pick() {
  local format="$1"
  local raw="$2"
  MOCK_COLOR="$raw" \
  MOCK_ARGS_FILE="$ARGS_FILE" \
  MOCK_CLIPBOARD_FILE="$CLIPBOARD_FILE" \
  OMARCHY_COLOR_PICKER_HYPRPICKER="$FIXTURES/hyprpicker" \
  OMARCHY_COLOR_PICKER_WL_COPY="$FIXTURES/wl-copy" \
    "$CONTROL" pick "$format"
}

assert_pick() {
  local format="$1"
  local raw="$2"
  local expected="$3"
  local actual args clipboard

  actual="$(run_pick "$format" "$raw")"
  clipboard="$(<"$CLIPBOARD_FILE")"
  args="$(<"$ARGS_FILE")"

  assert_equal "$expected" "$actual" "$format stdout"
  assert_equal "$expected" "$clipboard" "$format clipboard"
  [[ $args == *"--format=$format"* ]] || fail "$format was not passed to hyprpicker"
  [[ $args == *"--scale=8"* ]] || fail "zoom scale was not passed to hyprpicker"
  [[ $args == *"--radius=64"* ]] || fail "lens radius was not passed to hyprpicker"
  [[ $args == *"--no-fancy"* ]] || fail "plain output was not requested"
  [[ $args != *"--quiet"* ]] || fail "quiet mode suppresses hyprpicker's color output"
  if [[ $format == hsl ]]; then
    [[ $args == *"--output-format={} {}%% {}%%"* ]] \
      || fail "HSL percent signs were not escaped for hyprpicker"
  fi
}

assert_pick hex '#a1B2c3' '#A1B2C3'
assert_pick rgb '30 144 255' 'rgb(30, 144, 255)'
assert_pick hsl '210 100% 56%' 'hsl(210, 100%, 56%)'

printf 'unchanged' > "$CLIPBOARD_FILE"
if MOCK_EXIT_CODE=1 \
  MOCK_COLOR='#000000' \
  MOCK_ARGS_FILE="$ARGS_FILE" \
  MOCK_CLIPBOARD_FILE="$CLIPBOARD_FILE" \
  OMARCHY_COLOR_PICKER_HYPRPICKER="$FIXTURES/hyprpicker" \
  OMARCHY_COLOR_PICKER_WL_COPY="$FIXTURES/wl-copy" \
    "$CONTROL" pick hex; then
  fail "cancelled picker unexpectedly succeeded"
fi
assert_equal 'unchanged' "$(<"$CLIPBOARD_FILE")" "cancelled clipboard"

printf 'unchanged' > "$CLIPBOARD_FILE"
if run_pick hex ''; then
  fail "empty picker output unexpectedly succeeded"
fi
assert_equal 'unchanged' "$(<"$CLIPBOARD_FILE")" "empty-output clipboard"

printf 'unchanged' > "$CLIPBOARD_FILE"
if run_pick hex 'not-a-color'; then
  fail "invalid picker output unexpectedly succeeded"
fi
assert_equal 'unchanged' "$(<"$CLIPBOARD_FILE")" "invalid-output clipboard"

if "$CONTROL" pick invalid >/dev/null 2>&1; then
  fail "invalid format unexpectedly succeeded"
fi

assert_equal $'hex\nrgb\nhsl' "$($CONTROL formats)" "format list"

printf 'All color-pickerctl tests passed.\n'
