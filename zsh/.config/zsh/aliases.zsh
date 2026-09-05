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
fi

# cd
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ioartista='cd ~/Code/ioartista_it'
alias dotfiles='cd ~/Code/dotfiles'

# rails local
alias bd='bin/dev'
alias rs='bin/rails server'
alias rc='bin/rails console'
alias rdbc='bin/rails dbconsole'
alias rdbm='bin/rails db:migrate'

# rails production
alias k='kamal'
alias kd='kamal deploy'
alias kl='kamal logs -f'
alias kc='kamal app exec --interactive "bin/rails console"'
alias kdb='kamal app exec --interactive "bin/rails dbconsole"'

# git
#alias gst='git status'
#alias gad='git add .'
#alias gcm='git commit -m'
#alias gco='git checkout'
#alias gcb='git checkout -b' # Create and switch to a new branch
#alias gpl='git pull'
#alias gps='git push'
#alias ggl="git log --graph --oneline --decorate"
#alias gdi='git diff'

# vps
alias vps-connect='ssh ubuntu@145.239.72.166'
alias vps-status="ssh -t ubuntu@145.239.72.166 '
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


# ==============================================================================
# [MACOS]
# ==============================================================================

if [[ "$OSTYPE" == "darwin"* ]]; then
  # Flush the Mac DNS cache (useful when a site fails to load after DNS changes)
  alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

  # List listening TCP ports (if Rails or Postgres will not start because the port is taken, this shows who is using it)
  alias portslis='sudo lsof -iTCP -sTCP:LISTEN -P'

  # Copy your public SSH key to the clipboard to paste on GitHub/Bitbucket
  alias pubkey="pbcopy < ~/.ssh/id_rsa.pub"
fi
