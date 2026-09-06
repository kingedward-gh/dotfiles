# ==============================================================================
# [COMMON]
# ==============================================================================

# zsh
alias ref='source ~/.zshrc'
alias zshrc='nano ~/.zshrc'

# ls / ll (legacy)
# macOS (BSD: -G = color): alias ll='ls -lahFG'
# Arch  (GNU: --color):    alias ll='ls -lahF --color=auto'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --color=auto'
  alias ll='eza -la --group-directories-first --color=auto --icons=auto'
  alias la='eza -lah --group-directories-first --color=auto --icons=auto --git'
  alias tree='eza --tree --icons -a --ignore-glob=".git"'
fi

if command -v bat >/dev/null 2>&1; then
  alias b='bat'
fi

# cd
alias -- -='cd -'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ioartista='cd ~/Code/ioartista_it'
alias dotfiles='cd ~/Code/dotfiles'

# git
alias g='git'
alias gad='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gba='git branch --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcam='git commit --all --message'
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
    echo "Errore: inserisci un messaggio per il commit."
    echo "Uso: lazypush \"messaggio del commit\""
    return 1
  fi

  git add --all && \
  git commit --all --message "$1" && \
  git push origin $(git branch --show-current)
}
alias gg="lazypush"

# rails local
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

# rails production
alias k='kamal'
alias kd='kamal deploy'
alias kl='kamal logs -f'
alias kc='kamal app exec --interactive "bin/rails console"'
alias kdbc='kamal app exec --interactive "bin/rails dbconsole"'

# vps: main commands
alias vps-connect='ssh vps'
alias vps-status="ssh -t vps '
echo -e \"\033[1;36m===================================================\033[0m\"
echo -e \"\033[1;33m 🚀 VPS DASHBOARD - \$(hostname) \033[0m\"
echo -e \"\033[1;36m===================================================\033[0m\"
echo -e \"\033[1;32m💻 CPU & LOAD:\033[0m\"
echo -e \"   Model: \$(lscpu | grep \"Model name\" | cut -d\":\" -f2 | xargs)\"
echo -e \"   Cores: \$(nproc) | Load Avg: \$(uptime | awk -F\"load average:\" \"{print \\\$2}\")\"
echo \"\"
echo -e \"\033[1;35m🧠 RAM:\033[0m\"
free -h | awk \"NR==1{printf \\\"   %-10s %-10s %-10s %-10s\n\\\", \\\$2, \\\$3, \\\$4, \\\$7} NR==2{printf \\\"   %-10s %-10s %-10s %-10s\n\\\", \\\$2, \\\$3, \\\$4, \\\$7}\"
echo \"\"
echo -e \"\033[1;33m💾 DISK (/):\033[0m\"
df -h / | awk \"NR==2{print \\\"   Used: \\\" \\\$3 \\\" / \\\" \\\$2 \\\" (\\\" \\\$5 \\\") - Free: \\\" \\\$4}\"
echo \"\"
echo -e \"\033[1;34m🐳 ACTIVE DOCKER CONTAINERS:\033[0m\"
docker stats --no-stream --format \"table   \033[1m{{.Name}}\033[0m\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\"
echo -e \"\033[1;36m===================================================\033[0m\"
fastfetch
'"
alias vps-ping="gping vps 1.1.1.1"
alias vps-btop="ssh -t vps btop"
alias vps-logs="cd ~/Code/ioartista_it && kamal app logs -f | $(command -v gstdbuf || command -v stdbuf) -oL tspin"
alias vps-docker="ssh -t vps lazydocker"

# vps: additional commands
alias vps-bandwhich="ssh -t vps sudo bandwhich"
# alias vps-postgres="cd ~/Code/ioartista_it && kamal accessory exec db -i -- psql -h localhost -U postgres -c \"
# SELECT 
#   pid, 
#   client_addr, 
#   now() - query_start AS duration, 
#   state, 
#   left(query, 60) AS query 
# FROM pg_stat_activity 
# WHERE state != 'idle' 
# ORDER BY duration DESC;
# \""
# vps-postgres() {
#   ssh -t vps '
#     CONTAINER=$(docker ps -q -f name=db)
#     if [ -z "$CONTAINER" ]; then
#       CONTAINER=$(docker ps -q -f name=postgres)
#     fi
#     docker exec -it $CONTAINER psql -U postgres -c "
#       SELECT 
#         pid, 
#         client_addr, 
#         now() - query_start AS duration, 
#         state, 
#         left(query, 60) AS query 
#       FROM pg_stat_activity 
#       WHERE state != '\''idle'\'' 
#       ORDER BY duration DESC;
#     "
#   '
# }


# ==============================================================================
# [MACOS]
# ==============================================================================

if [[ "$OSTYPE" == "darwin"* ]]; then
  # Flush the Mac DNS cache (useful when a site fails to load after DNS changes)
  alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

  # List listening TCP ports (if Rails or Postgres will not start because the port is taken, this shows who is using it)
  alias portslis='sudo lsof -iTCP -sTCP:LISTEN -P'

  # Copy your public SSH key to the clipboard to paste on GitHub/Bitbucket
  alias pubkey="([ -f ~/.ssh/id_ed25519.pub ] && pbcopy < ~/.ssh/id_ed25519.pub) || pbcopy < ~/.ssh/id_rsa.pub"

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

  # foot + tmux VPS dashboard (5 panes; foot has no splits):
  #
  #   ┌──────────────┬──────────────┐
  #   │   vps-ping   │   vps-btop   │
  #   ├──────────┬───┴────┬─────────┤
  #   │  status  │  logs  │ docker  │
  #   └──────────┴────────┴─────────┘
  vps-dash() {
    command -v foot >/dev/null 2>&1 || { echo "vps-dash: foot not found" >&2; return 1; }
    command -v tmux >/dev/null 2>&1 || { echo "vps-dash: tmux not found" >&2; return 1; }

    tmux has-session -t vps-dash 2>/dev/null && tmux kill-session -t vps-dash

    foot --maximized --app-id=vps-dash -T "VPS Dashboard" tmux \
      new-session -s vps-dash -n dashboard \; \
      set-option status off \; \
      set-option mouse on \; \
      set-option pane-border-status top \; \
      set-option pane-border-format ' #{pane_title} ' \; \
      split-window -v -l 50% \; \
      select-pane -t 0 \; \
      split-window -h -l 50% \; \
      select-pane -t 1 \; \
      split-window -h -l 66% \; \
      split-window -h -l 50% \; \
      select-pane -t 0 -T ping \; \
      select-pane -t 2 -T btop \; \
      select-pane -t 1 -T status \; \
      select-pane -t 3 -T logs \; \
      select-pane -t 4 -T docker \; \
      send-keys -t 0 'vps-ping' C-m \; \
      send-keys -t 2 'vps-btop' C-m \; \
      send-keys -t 1 'vps-status' C-m \; \
      send-keys -t 3 'vps-logs' C-m \; \
      send-keys -t 4 'vps-docker' C-m \
      >/dev/null 2>&1 &
    disown
  }
  alias vps-dashboard="vps-dash"
fi