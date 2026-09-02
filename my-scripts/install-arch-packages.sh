#!/bin/bash

# ==============================================================================
# Check & Install: ARCH-ONLY PACKAGES
# ==============================================================================

PKG_FILE="$HOME/Code/dotfiles/my-packages/packages.txt"

if [ ! -f /etc/arch-release ]; then
    echo "⚠️  This script is for Arch Linux only."
    exit 0
fi

if [ ! -f "$PKG_FILE" ]; then
    echo "❌ File $PKG_FILE not found!"
    exit 1
fi

echo "🔍 Checking [ARCH] packages..."
echo "--------------------------------------------------"

ARCH_LINES=$(sed -n '/^\[ARCH\]/,/^\[/p' "$PKG_FILE" | grep -v '^\[' | grep -v '^\s*#' | grep -v '^\s*$')

MISSING=()

while IFS= read -r pkg; do
    pkg=$(echo "$pkg" | xargs)
    if pacman -Qi "$pkg" &>/dev/null || paru -Qi "$pkg" &>/dev/null; then
        VER=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}')
        echo "  [✓] $pkg ($VER)"
    else
        echo "  [✗] $pkg (missing)"
        MISSING+=("$pkg")
    fi
done <<< "$ARCH_LINES"

echo "--------------------------------------------------"

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "🎉 All [ARCH] packages are installed!"
else
    echo "⚠️  Missing packages: ${MISSING[*]}"
    read -p "Install/update them with paru/pacman? (y/N): " choice
    if [[ "$choice" =~ ^[yY]$ ]]; then
        paru -S --needed "${MISSING[@]}"
    fi
fi
