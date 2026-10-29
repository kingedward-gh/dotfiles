# Minimal Robby Russell prompt with clock and Git branch

_prompt_git_info() {
  local branch
  branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
    branch=$(git rev-parse --short HEAD 2>/dev/null) ||
    return

  printf '%%F{blue}:%%B%%F{red}%s%%b' "$branch"

  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    printf ' %%F{red}✗'
  fi
}

PROMPT='%(?:%F{green}➜ :%F{red}➜ )'
PROMPT+='%F{cyan}%D{%H:%M} '
PROMPT+='%F{blue}%c'
PROMPT+='${_prompt_git_info}'
PROMPT+=' %f'
