# ==============================================================================
# [COMMON]
# ==============================================================================

# Cursor/VS Code shell integration sets ZDOTDIR to a temp dir, so don't use it for our files.
ZSH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"


### oh my zsh

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_THEME="robbyrussell" # chosen options: robbyrussell, agnoster, fino, bira, ys, bureau

# VSCode to cursor
VSCODE=cursor

# Move the completion dump file to the .cache folder
export ZSH_COMPDUMP="$HOME/.cache/.zcompdump-$HOST-$ZSH_VERSION"

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
  # rbenv
  # ruby
  # rvm
  thefuck
  # themes
  tmux
  # vi-mode
  vscode
  # z
  # zoxide
  # zsh-interactive-cd

)

# External plugins are installed by my-scripts/install/setup-zsh.sh.
for _dotfiles_plugin in fzf-tab zsh-autosuggestions fast-syntax-highlighting; do
  if [[ -f "${ZSH_CUSTOM:-$ZSH/custom}/plugins/$_dotfiles_plugin/$_dotfiles_plugin.plugin.zsh" ]]; then
    plugins+=("$_dotfiles_plugin")
  fi
done
unset _dotfiles_plugin

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  mkdir -p -- "${ZSH_COMPDUMP:h}"
  source "$ZSH/oh-my-zsh.sh"
elif [[ -o interactive ]]; then
  print -u2 'Oh My Zsh missing. From the dotfiles repo, run: bash my-scripts/install/setup-zsh.sh'
fi


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


### glob

setopt NUMERIC_GLOB_SORT       # file10 after file9, not after file1


### rbenv

export PATH="$HOME/.rbenv/bin:$PATH"
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi


### zoxide

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi


### fzf

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
  [[ -f "$ZSH_CONFIG/fzf.zsh" ]] && source "$ZSH_CONFIG/fzf.zsh"
fi


### aliases

[[ -f "$ZSH_CONFIG/aliases.zsh" ]] && source "$ZSH_CONFIG/aliases.zsh"


### keybinds

[[ -f "$ZSH_CONFIG/keybinds.zsh" ]] && source "$ZSH_CONFIG/keybinds.zsh"


### extras

# disable mailcheck
unset MAILCHECK

# zmv (batch rename/copy/link with patterns)
autoload -Uz zmv
