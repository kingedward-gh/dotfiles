#!/bin/bash

# ==============================================================================
# Stow: COMMON + OS-SPECIFIC packages from my-setup/stow.txt
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../.." && pwd)"
STOW_FILE="$REPO/my-setup/stow.txt"

if ! command -v stow &>/dev/null; then
    echo "❌ stow is not installed."
    exit 1
fi

if [ ! -f "$STOW_FILE" ]; then
    echo "❌ File $STOW_FILE not found!"
    exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    OS_SECTION="MACOS"
elif [ -f /etc/arch-release ]; then
    OS="arch"
    OS_SECTION="ARCH"
else
    echo "❌ Unsupported operating system."
    exit 1
fi

extract_section() {
    local section="$1"
    sed -n "/^\[${section}\]/,/^\[/p" "$STOW_FILE" | grep -v '^\[' | grep -v '^\s*#' | grep -v '^\s*$'
}

# Apps that rewrite config via temp+rename replace file-level stow symlinks.
# Fold the whole config dir so writes land in the repo.
fold_dir_for() {
    case "$1" in
        cliamp) printf '%s\n' ".config/cliamp" ;;
    esac
}

# If $HOME/<rel> is a real directory, adopt tracked files into the package
# and move the dir aside so stow can create a directory symlink.
prepare_fold_dir() {
    local pkg="$1"
    local rel="$2"
    local src="$REPO/$pkg/$rel"
    local dst="$HOME/$rel"
    FOLD_STASH=""

    if [ ! -d "$src" ]; then
        echo "  [✗] $pkg (missing $src)"
        return 1
    fi

    if [ -L "$dst" ]; then
        local actual expected
        actual=$(cd "$dst" 2>/dev/null && pwd -P) || actual=""
        expected=$(cd "$src" && pwd -P)
        if [ "$actual" = "$expected" ]; then
            return 0
        fi
        echo "  [✗] $dst is a symlink to a different path"
        return 1
    fi

    [ ! -e "$dst" ] && return 0

    if [ ! -d "$dst" ]; then
        echo "  [✗] $dst exists and is not a directory"
        return 1
    fi

    local f base
    for f in "$src"/*; do
        [ -f "$f" ] || continue
        base=$(basename "$f")
        if [ -f "$dst/$base" ] && [ ! -L "$dst/$base" ]; then
            cp "$dst/$base" "$f"
        fi
    done

    FOLD_STASH=$(mktemp -d "${TMPDIR:-/tmp}/stow-${pkg}.XXXXXX")
    mv "$dst" "$FOLD_STASH/old"
}

restore_fold_dir() {
    local pkg="$1"
    local rel="$2"
    local stash="$3"
    local stow_ok="$4"
    local src="$REPO/$pkg/$rel"
    local dst="$HOME/$rel"

    [ -n "$stash" ] || return 0
    [ -d "$stash/old" ] || { rm -rf "$stash"; return 0; }

    if [ "$stow_ok" != 1 ]; then
        if [ ! -e "$dst" ]; then
            mv "$stash/old" "$dst"
        fi
        rm -rf "$stash"
        return 0
    fi

    local f base
    for f in "$stash/old"/* "$stash/old"/.[!.]*; do
        [ -e "$f" ] || continue
        base=$(basename "$f")
        if [ ! -e "$src/$base" ]; then
            cp -a "$f" "$dst/"
        fi
    done
    rm -rf "$stash"
}

stow_packages() {
    local label="$1"
    local packages="$2"

    echo "🔗 Stow [$label]..."
    echo "--------------------------------------------------"

    if [ -z "$packages" ]; then
        echo "  (no packages)"
        echo "--------------------------------------------------"
        return 0
    fi

    while IFS= read -r pkg; do
        pkg=$(echo "$pkg" | xargs)
        [ -z "$pkg" ] && continue

        if [ ! -d "$REPO/$pkg" ]; then
            echo "  [✗] $pkg (folder not found in $REPO)"
            continue
        fi

        local fold_rel stow_ok=0
        fold_rel=$(fold_dir_for "$pkg")
        FOLD_STASH=""

        if [ -n "$fold_rel" ]; then
            prepare_fold_dir "$pkg" "$fold_rel" || return 1
            if stow -R -t "$HOME" -d "$REPO" "$pkg"; then
                stow_ok=1
            fi
            restore_fold_dir "$pkg" "$fold_rel" "$FOLD_STASH" "$stow_ok"
        else
            if stow --no-folding -R -t "$HOME" -d "$REPO" "$pkg"; then
                stow_ok=1
            fi
        fi

        if [ "$stow_ok" = 1 ]; then
            echo "  [✓] $pkg → \$HOME"
        else
            echo "  [✗] $pkg (stow error)"
            return 1
        fi
    done <<< "$packages"

    echo "--------------------------------------------------"
}

echo "🖥️  Detected OS: $OS"
echo ""

COMMON_PKGS=$(extract_section "COMMON")
stow_packages "COMMON" "$COMMON_PKGS" || exit $?

echo ""
OS_PKGS=$(extract_section "$OS_SECTION")
stow_packages "$OS_SECTION" "$OS_PKGS" || exit $?
