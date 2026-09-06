# ==============================================================================
# [COMMON]
# ==============================================================================

### oh my zsh

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
# ZSH_THEME="agnoster"
# ZSH_THEME="fino"
# ZSH_THEME="bira"
# ZSH_THEME="ys"
# ZSH_THEME="bureau"

# Tab-complete: - and _ are interchangeable
HYPHEN_INSENSITIVE="true"
# Faster git prompt in large repos (ignore untracked files)
DISABLE_UNTRACKED_FILES_DIRTY="true"
# Dates in history: 2026-09-02
HIST_STAMPS="yyyy-mm-dd"

plugins=(
  aliases
  # brew
  # bundler
  # docker
  # eza
  # fzf
  gh
  # git
  # kamal
  # macos
  # postgres
  # rails
  rbenv
  # ruby
  # rvm
  # themes
  tmux
  # vi-mode
  # vscode
  # z
  # zoxide

  # git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  zsh-autosuggestions

  # git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
  fast-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh


### history (oh-my-zsh defaults, made explicit)

# HIST_STAMPS above is read when oh-my-zsh.sh is sourced.
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=50000
SAVEHIST=10000

setopt EXTENDED_HISTORY        # write timestamps to HISTFILE
setopt HIST_EXPIRE_DUPS_FIRST  # drop dups first when trimming
setopt HIST_IGNORE_DUPS        # skip consecutive duplicates
setopt HIST_IGNORE_SPACE       # skip commands that start with a space
setopt HIST_VERIFY             # expand history before running
setopt SHARE_HISTORY           # share history across sessions
setopt NUMERIC_GLOB_SORT       # file10 after file9, not after file1


### path

# Prepend ~/.local/bin to PATH only if it is not already there (avoid duplicates).
# PATH is the list of folders the shell searches for commands, so you can
# run scripts in ~/.local/bin (e.g. install-all-packages.sh) from anywhere.
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"


### rbenv

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"


### zoxide

eval "$(zoxide init zsh)"


### fzf

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
  [[ -f "${ZDOTDIR:-$HOME/.config/zsh}/fzf.zsh" ]] && source "${ZDOTDIR:-$HOME/.config/zsh}/fzf.zsh"
fi


### aliases

source "${ZDOTDIR:-$HOME/.config/zsh}/aliases.zsh"


### extras

# Set the default editor to nano
export EDITOR="nano"

# Disable mail checking (to avoid delays when checking email)
unset MAILCHECK
