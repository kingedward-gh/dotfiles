#!/bin/bash

# ==============================================================================
# Stow: COMMON + OS-SPECIFIC packages from my-packages/stow.txt
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../.." && pwd)"
STOW_FILE="$REPO/my-packages/stow.txt"

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

        if stow --no-folding -R -t "$HOME" -d "$REPO" "$pkg"; then
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
