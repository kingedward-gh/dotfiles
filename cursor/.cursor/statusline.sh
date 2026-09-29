#!/usr/bin/env bash
# Cursor CLI status line — reads StatusLinePayload JSON from stdin
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "—"')
PARAM=$(echo "$input" | jq -r '.model.param_summary // empty')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
VIM=$(echo "$input" | jq -r '.vim.mode // empty')
WT=$(echo "$input" | jq -r '.worktree.name // empty')

# Context bar
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /▓}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

# Color by context pressure
if [ "$PCT" -ge 80 ]; then
  CTX_COLOR=$'\033[31m' # red
elif [ "$PCT" -ge 50 ]; then
  CTX_COLOR=$'\033[33m' # yellow
else
  CTX_COLOR=$'\033[32m' # green
fi

CYAN=$'\033[36m'
DIM=$'\033[90m'
MAGENTA=$'\033[35m'
RESET=$'\033[0m'

BRANCH=""
if git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
  [ -n "$BRANCH" ] && BRANCH=" ${MAGENTA} ${BRANCH}${RESET}"
fi

BASE="${DIR##*/}"
[ -n "$WT" ] && BASE="$WT"
MODEL_LABEL="$MODEL"
[ -n "$PARAM" ] && MODEL_LABEL="$MODEL $PARAM"

VIM_LABEL=""
[ -n "$VIM" ] && VIM_LABEL=" ${CYAN}${VIM}${RESET}"

printf "%s%s%s  %s%s%s%s%s  %s%s %s%%%s\n" \
  "$CYAN" "$MODEL_LABEL" "$RESET" \
  "$DIM" "$BASE" "$RESET" \
  "$BRANCH" "$VIM_LABEL" \
  "$CTX_COLOR" "$BAR" "$PCT" "$RESET"
