#!/bin/bash

# ==============================================================================
# Check & Install: UBUNTU-ONLY PACKAGES
# ==============================================================================

PKG_FILE="$HOME/Code/dotfiles/my-setup/packages.txt"

if [ ! -f /etc/os-release ] || ! grep -qi '^ID=ubuntu' /etc/os-release; then
    echo "⚠️  This script is for Ubuntu only."
    exit 0
fi

if [ ! -f "$PKG_FILE" ]; then
    echo "❌ File $PKG_FILE not found!"
    exit 1
fi

echo "🔍 Checking [UBUNTU] packages..."
echo "--------------------------------------------------"

UBUNTU_LINES=$(sed -n '/^\[UBUNTU\]/,/^\[/p' "$PKG_FILE" | grep -v '^\[' | grep -v '^\s*#' | grep -v '^\s*$')

MISSING=()

while IFS= read -r pkg; do
    pkg=$(echo "$pkg" | xargs)
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "ok installed"; then
        VER=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null)
        echo "  [✓] $pkg ($VER)"
    else
        echo "  [✗] $pkg (missing)"
        MISSING+=("$pkg")
    fi
done <<< "$UBUNTU_LINES"

echo "--------------------------------------------------"

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "🎉 All [UBUNTU] packages are installed!"
else
    echo "⚠️  Missing packages: ${MISSING[*]}"
    read -p "Install them now via apt? (y/N): " choice
    if [[ "$choice" =~ ^[yY]$ ]]; then
        sudo apt update
        sudo apt install --yes "${MISSING[@]}"
    fi
fi
