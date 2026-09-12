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

VSCODE=cursor

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
  vscode
  # z
  # zoxide
  # zsh-interactive-cd

  # git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
  fzf-tab

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


### rbenv

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"


### zoxide

eval "$(zoxide init zsh)"


### fzf

# Cursor/VS Code shell integration sets ZDOTDIR to a temp dir, so don't use it for our files.
ZSH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
  [[ -f "$ZSH_CONFIG/fzf.zsh" ]] && source "$ZSH_CONFIG/fzf.zsh"
fi


### aliases

[[ -f "$ZSH_CONFIG/aliases.zsh" ]] && source "$ZSH_CONFIG/aliases.zsh"


### keybinds

[[ -f "$ZSH_CONFIG/keybinds.zsh" ]] && source "$ZSH_CONFIG/keybinds.zsh"


### extras

unset MAILCHECK


### zmv (batch rename/copy/link with patterns)

autoload -Uz zmv
alias zcp='zmv -C'
alias zln='zmv -L'
