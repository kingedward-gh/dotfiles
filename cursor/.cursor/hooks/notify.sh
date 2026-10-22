#!/usr/bin/env bash

# Cross-platform notification sound for Codex and Cursor Agent.
# macOS: Glass.aiff
# Linux: freedesktop sound theme

case "$(uname -s)" in
  Darwin)
    sound="/System/Library/Sounds/Glass.aiff"
    if [[ -f "$sound" ]]; then
      /usr/bin/afplay "$sound" >/dev/null 2>&1
    fi
    ;;

  Linux)
    sound=""

    for candidate in \
      /usr/share/sounds/freedesktop/stereo/complete.oga \
      /usr/share/sounds/freedesktop/stereo/message.oga \
      /usr/share/sounds/freedesktop/stereo/bell.oga
    do
      if [[ -f "$candidate" ]]; then
        sound="$candidate"
        break
      fi
    done

    if [[ -n "$sound" ]]; then
      if command -v paplay >/dev/null 2>&1; then
        paplay "$sound" >/dev/null 2>&1
      elif command -v pw-play >/dev/null 2>&1; then
        pw-play "$sound" >/dev/null 2>&1
      fi
    fi
    ;;
esac

exit 0