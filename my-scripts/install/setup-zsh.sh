#!/bin/bash

# Install missing shell dependencies without changing .zshrc or the login shell.
set -euo pipefail

ZSH_ROOT="${ZSH:-$HOME/.oh-my-zsh}"
CUSTOM_ROOT="${ZSH_CUSTOM:-$ZSH_ROOT/custom}"
CLONE_TMP=""

cleanup() {
    if [ -n "$CLONE_TMP" ]; then
        rm -rf -- "$CLONE_TMP"
    fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

install_missing() {
    local name="$1" url="$2" destination="$3" entry="$4"
    if [ -f "$destination/$entry" ]; then
        echo "  [✓] $name already present (left unchanged)"
        return 0
    fi
    if [ -e "$destination" ] || [ -L "$destination" ]; then
        echo "  [✗] $destination exists but is missing $entry; inspect it before retrying." >&2
        return 1
    fi
    if ! command -v git >/dev/null 2>&1; then
        echo "  [✗] Install git before running setup-zsh.sh." >&2
        return 1
    fi
    mkdir -p -- "$(dirname "$destination")"
    CLONE_TMP=$(mktemp -d "${destination}.setup.XXXXXX")
    if ! git clone --depth=1 "$url" "$CLONE_TMP/repo"; then
        echo "  [✗] Download of $name failed; rerun setup-zsh.sh to retry." >&2
        return 1
    fi
    if [ ! -f "$CLONE_TMP/repo/$entry" ]; then
        echo "  [✗] Download of $name is missing $entry." >&2
        return 1
    fi
    # Refuse a destination created while the download was running.
    if [ -e "$destination" ] || [ -L "$destination" ]; then
        echo "  [✗] $destination appeared during setup; left unchanged." >&2
        return 1
    fi
    mv -- "$CLONE_TMP/repo" "$destination"
    rmdir -- "$CLONE_TMP"
    CLONE_TMP=""
    echo "  [✓] Installed $name"
}

install_missing 'Oh My Zsh' https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_ROOT" oh-my-zsh.sh
install_missing fzf-tab https://github.com/Aloxaf/fzf-tab.git "$CUSTOM_ROOT/plugins/fzf-tab" fzf-tab.plugin.zsh
install_missing zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git "$CUSTOM_ROOT/plugins/zsh-autosuggestions" zsh-autosuggestions.plugin.zsh
install_missing fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$CUSTOM_ROOT/plugins/fast-syntax-highlighting" fast-syntax-highlighting.plugin.zsh
