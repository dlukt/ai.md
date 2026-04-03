#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
MAX_LINES="${MAX_LINES:-80}"
INCLUDE_GENERATED="${INCLUDE_GENERATED:-0}"
if [[ ! -d "$ROOT" ]]; then
  echo "error: project root not found: $ROOT" >&2
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "error: ripgrep (rg) is required for this script" >&2
  exit 1
fi

cd "$ROOT"

IS_GRAPHICS_GD_REPO=0
if [[ -f go.mod ]] && rg -q '^module\s+graphics\.gd$' go.mod; then
  IS_GRAPHICS_GD_REPO=1
fi

RG_GLOBS=(-g '*.go')
if [[ "$INCLUDE_GENERATED" != "1" && "$IS_GRAPHICS_GD_REPO" == "1" ]]; then
  RG_GLOBS+=(
    -g '!classdb/**'
    -g '!variant/**'
    -g '!internal/**'
    -g '!startup/**'
    -g '!shaders/**'
    -g '!cmd/**'
  )
fi

show_matches() {
  local title="$1"
  local pattern="$2"
  local tmp
  tmp="$(mktemp)"

  rg -n "$pattern" "${RG_GLOBS[@]}" >"$tmp" || true
  local count
  count="$(wc -l < "$tmp" | tr -d ' ')"

  echo "-- $title --"
  echo "matches: $count"
  if [[ "$count" -gt 0 ]]; then
    sed -n "1,${MAX_LINES}p" "$tmp"
    if [[ "$count" -gt "$MAX_LINES" ]]; then
      echo "... truncated to first $MAX_LINES lines (set MAX_LINES to change)"
    fi
  fi
  echo

  rm -f "$tmp"
}

echo "== graphics.gd project scan =="
echo "root: $(pwd)"
echo "max_lines_per_section: $MAX_LINES"
echo "include_generated: $INCLUDE_GENERATED"
echo "is_graphics_gd_repo: $IS_GRAPHICS_GD_REPO"
echo

GO_FILE_COUNT_TOTAL="$(rg --files -g '*.go' | wc -l | tr -d ' ')"
GO_FILE_COUNT_SCANNED="$(rg --files "${RG_GLOBS[@]}" | wc -l | tr -d ' ')"
echo "go_files_total: $GO_FILE_COUNT_TOTAL"
echo "go_files_scanned: $GO_FILE_COUNT_SCANNED"
if [[ "$GO_FILE_COUNT_SCANNED" -le 5 && "$INCLUDE_GENERATED" != "1" && "$IS_GRAPHICS_GD_REPO" == "1" ]]; then
  echo "tip: very few files scanned; rerun with INCLUDE_GENERATED=1 for framework-repo deep scans."
fi
echo

show_matches "imports containing graphics.gd" '"graphics\.gd/'
show_matches "startup calls" 'startup\.(LoadingScene|Rendering|MainLoop|Scene|AsExtension|OnSuspend|OnRestore)\('
show_matches "class registration" 'classdb\.Register\['
show_matches "extension/singleton embeddings" '\.(Extension|Singleton)\[[^]]+\]'
show_matches "lifecycle/draw callbacks" 'func \([^)]*\)\s*(Ready|Process|PhysicsProcess|Draw|Initialize|Finalize)\('

echo "-- inferred primary integration mode --"
if rg -q 'startup\.AsExtension\(' "${RG_GLOBS[@]}"; then
  echo "mode: extension-library (startup.AsExtension)"
elif rg -q 'startup\.MainLoop\(' "${RG_GLOBS[@]}"; then
  echo "mode: custom-mainloop (startup.MainLoop)"
elif rg -q 'startup\.Rendering\(' "${RG_GLOBS[@]}"; then
  echo "mode: rendering-loop (startup.Rendering)"
elif rg -q 'startup\.(LoadingScene|Scene)\(' "${RG_GLOBS[@]}"; then
  echo "mode: scene-tree (startup.LoadingScene/startup.Scene)"
else
  echo "mode: unknown (no standard startup pattern found)"
fi
