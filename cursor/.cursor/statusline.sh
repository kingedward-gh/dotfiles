#!/usr/bin/env bash
# Cursor CLI status line — reads StatusLinePayload JSON from stdin.
# Order: execution status, full directory, model + reasoning, context bar.
# cursor-agent does not currently send execution status; the slot is filled
# when a status field is present.

input=$(cat)

# Unit separator keeps empty fields (a leading tab would be skipped as whitespace).
parsed=$(printf '%s' "$input" | jq -r '[
  (.status // .execution_status // .agent_status // .activity // ""),
  (.model.display_name // "—"),
  (.model.param_summary // ""),
  (.workspace.current_dir // .cwd // ""),
  ((.context_window.used_percentage // 0) | floor | tostring)
] | join("\u001f")') || exit 1

IFS=$'\x1f' read -r STATUS_RAW MODEL PARAM DIR PCT <<<"$parsed"
case "$PCT" in
  ''|*[!0-9]*) PCT=0 ;;
esac

case "$STATUS_RAW" in
  idle|ready|Ready) STATUS="Ready" ;;
  generating|working|Working) STATUS="Working" ;;
  thinking|Thinking) STATUS="Thinking" ;;
  summarizing|Summarizing|summary) STATUS="Summarizing" ;;
  planning|Planning) STATUS="Planning" ;;
  transfer) STATUS="Moving to cloud" ;;
  loading) STATUS="Loading" ;;
  reconnecting) STATUS="Reconnecting" ;;
  shell-running) STATUS="Running shell" ;;
  queued) STATUS="Queued" ;;
  waiting-for-user) STATUS="Waiting for you" ;;
  waiting-for-confirmation) STATUS="Waiting for confirmation" ;;
  reviewing) STATUS="Reviewing" ;;
  "") STATUS="" ;;
  *) STATUS="$STATUS_RAW" ;;
esac

# ~/Code/dotfiles rather than the repo basename
DIR_LABEL="$DIR"
if [ -n "$HOME" ] && [ -n "$DIR" ]; then
  case "$DIR" in
    "$HOME") DIR_LABEL="~" ;;
    "$HOME"/*) DIR_LABEL="~${DIR#"$HOME"}" ;;
  esac
fi

# param_summary is the reasoning label ("high", "High", "(Thinking)", …)
PARAM="${PARAM#\(}"
PARAM="${PARAM%\)}"
MODEL_LABEL="$MODEL"
if [ -n "$PARAM" ]; then
  case "$MODEL" in
    *"$PARAM"*) ;;
    *) MODEL_LABEL="$MODEL $PARAM" ;;
  esac
fi

# Context bar
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /▓}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

if [ "$PCT" -ge 80 ]; then
  CTX_COLOR=$'\033[31m' # red
elif [ "$PCT" -ge 50 ]; then
  CTX_COLOR=$'\033[33m' # yellow
else
  CTX_COLOR=$'\033[32m' # green
fi

case "$STATUS" in
  Ready) STATUS_COLOR=$'\033[32m' ;;
  Working|Thinking|Summarizing|Planning|Running\ shell|Queued|Reviewing) STATUS_COLOR=$'\033[33m' ;;
  Reconnecting|Waiting*) STATUS_COLOR=$'\033[35m' ;;
  *) STATUS_COLOR=$'\033[36m' ;;
esac

CYAN=$'\033[36m'
DIM=$'\033[90m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

line=""
if [ -n "$STATUS" ]; then
  line="${STATUS_COLOR}${BOLD}${STATUS}${RESET}  "
fi
if [ -n "$DIR_LABEL" ]; then
  line="${line}${DIM}${DIR_LABEL}${RESET}  "
fi
line="${line}${CYAN}${MODEL_LABEL}${RESET}  ${CTX_COLOR}${BAR} ${PCT}%${RESET}"

printf '%s\n' "$line"
