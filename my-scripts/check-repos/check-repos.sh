#!/bin/bash

# Check every repo in the Code directory (parent of this dotfiles repo).
# Folders whose names start with _ are skipped.
# For each repo: git pull --no-rebase --ff-only, then git status.
# --no-rebase overrides pull.rebase so a dirty tree that is not behind
# still counts as synced. --ff-only refuses a merge or rebase.
# Prints one status line per repo:
#   repo-name: OK
#   repo-name: uncommitted changes

CODE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

join_by() {
  local sep="$1"
  shift
  local out="" item first=1
  for item in "$@"; do
    if [[ "$first" -eq 1 ]]; then
      out="$item"
      first=0
    else
      out="${out}${sep}${item}"
    fi
  done
  printf '%s' "$out"
}

note_for_codes() {
  local parts=() code
  for code in "$@"; do
    case "$code" in
      push) parts+=("waiting for commits to be pushed") ;;
      dirty) parts+=("uncommitted changes") ;;
      diverged) parts+=("diverged from remote") ;;
      behind) parts+=("behind remote") ;;
      noupstream) parts+=("no upstream branch") ;;
      detached) parts+=("detached HEAD") ;;
      notgit) parts+=("not a git repository") ;;
      pullfail)
        parts+=("pull failed")
        ;;
      pullfail:*)
        parts+=("pull failed (${code#pullfail:})")
        ;;
      *)
        parts+=("$code")
        ;;
    esac
  done
  join_by ", " "${parts[@]}"
}

check_repo() {
  local dir="$1"
  local codes=() pull_failed=0 pull_err="" counts left right explained c

  if ! git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf '%s' "notgit"
    return
  fi

  if ! git -C "$dir" symbolic-ref -q HEAD >/dev/null 2>&1; then
    codes+=("detached")
  elif ! git -C "$dir" rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
    codes+=("noupstream")
  else
    pull_err="$(git -C "$dir" -c color.ui=false pull --no-rebase --ff-only 2>&1)" || pull_failed=1
    counts="$(git -C "$dir" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null || true)"
    left="${counts%%$'\t'*}"
    right="${counts#*$'\t'}"
    [[ "$left" =~ ^[0-9]+$ ]] || left=0
    [[ "$right" =~ ^[0-9]+$ ]] || right=0
    if [[ "$left" -gt 0 && "$right" -gt 0 ]]; then
      codes+=("diverged")
    elif [[ "$right" -gt 0 ]]; then
      codes+=("push")
    elif [[ "$left" -gt 0 ]]; then
      codes+=("behind")
    fi
  fi

  if [[ -n "$(git -C "$dir" status --porcelain 2>/dev/null || true)" ]]; then
    codes+=("dirty")
  fi

  if [[ "$pull_failed" -eq 1 ]]; then
    explained=0
    for c in "${codes[@]}"; do
      [[ "$c" == "diverged" ]] && explained=1
    done
    if [[ "$explained" -eq 0 ]]; then
      pull_err="$(printf '%s\n' "$pull_err" | head -n 1 | sed -E 's/^(fatal|error): //')"
      if [[ -n "$pull_err" ]]; then
        codes+=("pullfail:${pull_err}")
      else
        codes+=("pullfail")
      fi
    fi
  fi

  join_by "|" "${codes[@]}"
}

main() {
  if [[ ! -d "$CODE_DIR" ]]; then
    echo "check-repos: directory not found: $CODE_DIR" >&2
    exit 1
  fi

  export GIT_TERMINAL_PROMPT=0

  local repos=() path name
  shopt -s nullglob
  for path in "$CODE_DIR"/*/; do
    name="$(basename "$path")"
    [[ "$name" == _* ]] && continue
    repos+=("$name")
  done

  if [[ ${#repos[@]} -eq 0 ]]; then
    echo "no repos found in $CODE_DIR"
    exit 1
  fi

  local dir raw failed=0 codes_arr=()
  for name in "${repos[@]}"; do
    dir="$CODE_DIR/$name"
    raw="$(check_repo "$dir")"
    if [[ -z "$raw" ]]; then
      printf '%s: OK\n' "$name"
    else
      IFS='|' read -r -a codes_arr <<< "$raw"
      printf '%s: %s\n' "$name" "$(note_for_codes "${codes_arr[@]}")"
      failed=1
    fi
  done

  return "$failed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
