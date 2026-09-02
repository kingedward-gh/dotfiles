#!/bin/bash

# ==============================================================================
# Check & Install: SHARED PACKAGES (COMMON)
# ==============================================================================

PKG_FILE="$HOME/Code/dotfiles/my-packages/packages.txt"

if [ ! -f "$PKG_FILE" ]; then
    echo "❌ File $PKG_FILE not found!"
    exit 1
fi

# Detect operating system
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [ -f /etc/arch-release ]; then
    OS="arch"
fi

echo "🖥️  Detected OS: $OS"
echo "🔍 Checking [COMMON] packages..."
echo "--------------------------------------------------"

# Extract the [COMMON] section
COMMON_LINES=$(sed -n '/^\[COMMON\]/,/^\[/p' "$PKG_FILE" | grep -v '^\[' | grep -v '^\s*#' | grep -v '^\s*$')

MISSING=()

while IFS= read -r line; do
    BREW_PKG=$(echo "$line" | cut -d'|' -f1 | xargs)
    ARCH_PKG=$(echo "$line" | cut -d'|' -f2 | xargs)

    if [ "$OS" == "arch" ]; then
        if pacman -Qi "$ARCH_PKG" &>/dev/null || paru -Qi "$ARCH_PKG" &>/dev/null; then
            VER=$(pacman -Q "$ARCH_PKG" 2>/dev/null | awk '{print $2}')
            echo "  [✓] $ARCH_PKG ($VER)"
        else
            echo "  [✗] $ARCH_PKG (missing)"
            MISSING+=("$ARCH_PKG")
        fi
    elif [ "$OS" == "macos" ]; then
        if brew list "$BREW_PKG" &>/dev/null; then
            echo "  [✓] $BREW_PKG"
        else
            echo "  [✗] $BREW_PKG (missing)"
            MISSING+=("$BREW_PKG")
        fi
    fi
done <<< "$COMMON_LINES"

echo "--------------------------------------------------"

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "🎉 All [COMMON] packages are already installed!"
else
    echo "⚠️  Missing packages: ${MISSING[*]}"
    read -p "Install/update them now? (y/N): " choice
    if [[ "$choice" =~ ^[yY]$ ]]; then
        if [ "$OS" == "arch" ]; then
            paru -S --needed "${MISSING[@]}"
        elif [ "$OS" == "macos" ]; then
            brew install "${MISSING[@]}"
        fi
    fi
fi
