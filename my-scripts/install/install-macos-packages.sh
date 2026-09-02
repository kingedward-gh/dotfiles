#!/bin/bash

# ==============================================================================
# Check & Install: MACOS-ONLY PACKAGES
# ==============================================================================

PKG_FILE="$HOME/Code/dotfiles/my-packages/packages.txt"

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  This script is for macOS only."
    exit 0
fi

if [ ! -f "$PKG_FILE" ]; then
    echo "❌ File $PKG_FILE not found!"
    exit 1
fi

echo "🔍 Checking [MACOS] packages..."
echo "--------------------------------------------------"

MACOS_LINES=$(sed -n '/^\[MACOS\]/,/^\[/p' "$PKG_FILE" | grep -v '^\[' | grep -v '^\s*#' | grep -v '^\s*$')

MISSING=()

while IFS= read -r pkg; do
    pkg=$(echo "$pkg" | xargs)
    if brew list "$pkg" &>/dev/null; then
        echo "  [✓] $pkg"
    else
        echo "  [✗] $pkg (missing)"
        MISSING+=("$pkg")
    fi
done <<< "$MACOS_LINES"

echo "--------------------------------------------------"

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "🎉 All [MACOS] packages are installed!"
else
    echo "⚠️  Missing packages: ${MISSING[*]}"
    read -p "Install them now via Homebrew? (y/N): " choice
    if [[ "$choice" =~ ^[yY]$ ]]; then
        brew install "${MISSING[@]}"
    fi
fi
