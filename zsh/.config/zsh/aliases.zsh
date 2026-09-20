# ==============================================================================
# [COMMON]
# ==============================================================================

# zsh
alias ref='source ~/.zshrc'
alias zshrc='nano ~/.zshrc'
alias zshrc-aliases='nano ~/Code/dotfiles/zsh/.config/zsh/aliases.zsh'
alias x='exit'

# zmv (loaded in .zshrc extras)
# alias zmv='zmv'
alias zcp='zmv -C'
alias zln='zmv -L'

# cd
alias home='cd ~'
# alias -- -='cd -' # already in omz
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias dotfiles='cd ~/Code/dotfiles'
alias grillone='cd ~/Code/grillone_it'
alias ioartista='cd ~/Code/ioartista_it'

# ls
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lh --group-directories-first --color=auto --icons=auto'
  alias la='eza -lah --group-directories-first --color=auto --icons=auto --git'
  alias ll='ls'
  alias tree='eza --level 2 --tree --group-directories-first --color=auto --icons=auto --ignore-glob=".git"'
  alias treea='eza -a --level 2 --tree --group-directories-first --color=auto --icons=auto --ignore-glob=".git"'
fi

# mvm: create the destination directory (if needed), then move
mvm() {
  mkdir -p "${@:-1}" && mv "$@"
}

# ex: extract archives like 'ex archive.tar.gz'
ex() {
  if [[ ! -f $1 ]]; then
    echo "'$1' is not a valid file" >&2
    return 1
  fi
  case $1 in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz)         tar xf "$1"  ;;
    *.tar.zst)        tar --zstd -xf "$1" ;;
    *.tar)            tar xf "$1"  ;;
    *.bz2)            bunzip2 "$1" ;;
    *.gz)             gunzip "$1"  ;;
    *.zip)            unzip "$1"   ;;
    *.rar)            unrar x "$1" ;;
    *.7z)             7z x "$1"    ;;
    *.Z)              uncompress "$1" ;;
    *) echo "'$1' cannot be extracted via ex()" >&2; return 1 ;;
  esac
}

# bat
if command -v bat >/dev/null 2>&1; then
  alias b='bat'
fi

# fman: man page via fzf (`compgen` is bash-only; ${(k)commands} is the zsh equivalent)
if command -v fzf >/dev/null 2>&1; then
  fman() {
    local cmd
    cmd=$(print -rl -- ${(k)commands} | fzf) || return
    man "$cmd"
  }
fi

# git
alias g='git'
alias gad='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gba='git branch --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcam='git commit --message'
alias gcf='git config --list'
alias gd='git diff'
alias glgg='git log --graph'
alias glog='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'
alias gm='git merge'
alias gl='git pull'
alias ggl='git pull origin $(git branch --show-current)'
alias gp='git push'
alias ggp='git push origin $(git branch --show-current)'
alias gst='git status'
lazypush() {
  if [ -z "$1" ]; then
    echo "Error: provide a commit message."
    echo "Usage: lazypush \"commit message\""
    return 1
  fi
  git add --all && \
  git commit --all --message "$1" && \
  git push origin $(git branch --show-current)
}
alias gg="lazypush"
alias lg='lazygit'

# rails
alias bd='bin/dev'
alias bi='bundle install'
alias bl='bundle list'
alias rs='bin/rails server'
alias rc='bin/rails console'
alias rdbc='bin/rails dbconsole'
alias rdbm='bin/rails db:migrate'
alias rdbs='bin/rails db:seed'
alias rr='bin/rails routes'
alias rrc='bin/rails routes --controller'
alias rrg='bin/rails routes --grep'
alias rru='bin/rails routes --unused'
alias rsts='bin/rails stats'
alias devlog='tail -f log/development.log'

# kamal
alias k='kamal'
alias kd='kamal deploy'
alias kl='kamal logs -f'
alias kc='kamal app exec --interactive "bin/rails console"'
alias kdbc='kamal app exec --interactive "bin/rails dbconsole"'

# vps
alias vps-connect='ssh vps'
vps-status() {
  ssh -t vps "$(cat <<'REMOTE'
echo -e "\033[1;36m===================================================\033[0m"
echo -e "\033[1;33m 🚀 VPS DASHBOARD - $(hostname) \033[0m"
echo -e "\033[1;36m===================================================\033[0m"
echo -e "\033[1;32m💻 CPU & LOAD:\033[0m"
echo -e "   Model: $(lscpu | grep "Model name" | cut -d":" -f2 | xargs)"
echo -e "   Cores: $(nproc) | Load Avg: $(uptime | awk -F"load average:" '{print $2}')"
echo ""
echo -e "\033[1;35m🧠 RAM:\033[0m"
free -h | awk 'NR==1 || NR==2 {printf "   %-10s %-10s %-10s %-10s\n", $2, $3, $4, $7}'
echo ""
echo -e "\033[1;33m💾 DISK (/):\033[0m"
df -h / | awk 'NR==2 {print "   Used: " $3 " / " $2 " (" $5 ") - Free: " $4}'
echo ""
echo -e "\033[1;34m🐳 ACTIVE DOCKER CONTAINERS:\033[0m"
docker stats --no-stream --format "table   \033[1m{{.Name}}\033[0m\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
echo -e "\033[1;36m===================================================\033[0m"
fastfetch
REMOTE
)"
}
alias vps-ping="gping vps 1.1.1.1"
alias vps-btop="ssh -t vps btop"
alias vps-logs="cd ~/Code/ioartista_it && kamal app logs -f | $(command -v gstdbuf || command -v stdbuf) -oL tspin"
alias vps-docker="ssh -t vps lazydocker"
alias vps-bandwhich="ssh -t vps sudo bandwhich"
# alias vps-postgres ?


# ==============================================================================
# [MACOS]
# ==============================================================================

if [[ "$OSTYPE" == "darwin"* ]]; then
  # nano: use English locale to avoid encoding issues
  alias nano='LC_ALL=C nano'

  # Flush the Mac DNS cache (useful when a site fails to load after DNS changes)
  alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

  # List listening TCP ports (if Rails or Postgres will not start because the port is taken, this shows who is using it)
  alias portslis='sudo lsof -iTCP -sTCP:LISTEN -P'

  # Copy your public SSH key to the clipboard to paste on GitHub/Bitbucket
  alias pubkey="([ -f ~/.ssh/id_ed25519.pub ] && pbcopy < ~/.ssh/id_ed25519.pub) || pbcopy < ~/.ssh/id_rsa.pub"

  # cd this shell to the front Finder window (selected folder, else current folder)
  cdf() {
    local finder_path
    finder_path="$(finder-iterm --path)" || return
    cd -- "$finder_path"
  }

  # iTerm2 VPS dashboard (5 panes):
  #
  #   ┌──────────────┬──────────────┐
  #   │   vps-ping   │   vps-btop   │
  #   ├──────────┬───┴────┬─────────┤
  #   │  status  │  logs  │ docker  │
  #   └──────────┴────────┴─────────┘
  vps-dash() {
    osascript <<'EOF'
tell application "System Events"
    set itermWasRunning to (exists process "iTerm2")
end tell

tell application "iTerm"
    activate

    -- Cold start already opens a default window; reuse it. Otherwise open a new one.
    if itermWasRunning then
        set dashWindow to (create window with default profile)
    else
        set dashWindow to current window
    end if

    tell dashWindow
        set zoomed to true
    end tell
    try
        set name of current tab of dashWindow to "VPS Dashboard"
    end try

    delay 0.35

    -- Row split first, then each row independently
    set sessionPing to current session of dashWindow
    tell sessionPing
        set sessionStatus to (split horizontally with default profile)
        set sessionBtop to (split vertically with default profile)
    end tell

    tell sessionStatus
        set sessionLogs to (split vertically with default profile)
    end tell

    tell sessionLogs
        set sessionDocker to (split vertically with default profile)
    end tell

    -- Bottom row starts 50/25/25; even the three panes out
    try
        set totalCols to (columns of sessionStatus) + (columns of sessionLogs) + (columns of sessionDocker)
        set paneCols to totalCols div 3
        set columns of sessionStatus to paneCols
        set columns of sessionLogs to paneCols
    end try

    tell sessionPing
        set name to "ping"
        write text "vps-ping"
    end tell

    tell sessionBtop
        set name to "btop"
        write text "vps-btop"
    end tell

    tell sessionStatus
        set name to "status"
        write text "vps-status"
    end tell

    tell sessionLogs
        set name to "logs"
        write text "vps-logs"
    end tell

    tell sessionDocker
        set name to "docker"
        write text "vps-docker"
    end tell
end tell
EOF
  }
  alias vps-dashboard="vps-dash"
fi


# ==============================================================================
# [ARCH]
# ==============================================================================

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Flush the DNS cache (useful when a site fails to load after DNS changes)
  alias flushdns="sudo systemd-resolve --flush-caches"

  # Copy your public SSH key to the clipboard to paste on GitHub/Bitbucket
  alias pubkey="xclip -selection clipboard < ~/.ssh/id_ed25519.pub 2>/dev/null || wl-copy < ~/.ssh/id_ed25519.pub"
fi
