# ==============================================================================
# [COMMON]
# ==============================================================================

### ZLE widgets (functions registered with zle -N) & keybinds.

# Ctrl+X L: clear screen but keep the current command buffer
function clear-screen-and-scrollback() {
  echoti civis >"$TTY"
  printf '%b' '\e[H\e[2J\e[3J' >"$TTY"
  echoti cnorm >"$TTY"
  zle redisplay
}
zle -N clear-screen-and-scrollback
bindkey '^Xl' clear-screen-and-scrollback

# Ctrl+X C: copy current command buffer to clipboard
function copy-buffer-to-clipboard() {
  if command -v pbcopy >/dev/null 2>&1; then
    echo -n "$BUFFER" | pbcopy
  elif command -v wl-copy >/dev/null 2>&1; then
    echo -n "$BUFFER" | wl-copy
  elif command -v xclip >/dev/null 2>&1; then
    echo -n "$BUFFER" | xclip -selection clipboard
  else
    zle -M "No clipboard command found"
    return
  fi
  zle -M "Copied to clipboard"
}
zle -N copy-buffer-to-clipboard
bindkey '^Xc' copy-buffer-to-clipboard


### extra keybinds

# Option+Left / Option+Right: move by word (macOS text-field convention).
# Ctrl+arrows switch Spaces; Alt+B/F need Option-as-Meta and steal ~ [ {.
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
