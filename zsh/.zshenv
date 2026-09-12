# ==============================================================================
# [COMMON]
# ==============================================================================

# Sourced for every zsh: interactive, scripts, Cursor. Keep this file fast.
# Do not set ZDOTDIR: Cursor/VS Code expect ~/.zshrc under $HOME.


### XDG

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"


### path

# typeset -U drops duplicates; user bins first so ~/.local/bin wins.
typeset -U path PATH
path=("$HOME/.local/bin" $path)


### editor

# Used by git, crontab, etc. even without an interactive prompt.
export EDITOR="${EDITOR:-nano}"
export VISUAL="${VISUAL:-$EDITOR}"


### gpg

# $TTY is set by zsh when stdin is a terminal; avoid $(tty) in scripts.
[[ -n "$TTY" ]] && export GPG_TTY="$TTY"


### pager

if (( $+commands[bat] )); then
  export MANPAGER="${MANPAGER:-bat -l man -p}"
elif (( $+commands[batcat] )); then
  export MANPAGER="${MANPAGER:-batcat -l man -p}"
fi
