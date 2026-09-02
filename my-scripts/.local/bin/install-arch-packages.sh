#!/bin/bash

# ==============================================================================
# Check & Install: PACCHETTI ARCH ONLY
# ==============================================================================

PKG_FILE="$HOME/Code/dotfiles/my-packages/packages.txt"

if [ ! -f /etc/arch-release ]; then
    echo "⚠️  Questo script è inteso solo per Arch Linux."
    exit 0
fi

if [ ! -f "$PKG_FILE" ]; then
    echo "❌ File $PKG_FILE non trovato!"
    exit 1
fi

echo "🔍 Controllo pacchetti [ARCH]..."
echo "--------------------------------------------------"

ARCH_LINES=$(sed -n '/^\[ARCH\]/,/^\[/p' "$PKG_FILE" | grep -v '^\[' | grep -v '^\s*#' | grep -v '^\s*$')

MISSING=()

while IFS= read -r pkg; do
    pkg=$(echo "$pkg" | xargs)
    if pacman -Qi "$pkg" &>/dev/null || paru -Qi "$pkg" &>/dev/null; then
        VER=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}')
        echo "  [✓] $pkg ($VER)"
    else
        echo "  [✗] $pkg (Mancante)"
        MISSING+=("$pkg")
    fi
done <<< "$ARCH_LINES"

echo "--------------------------------------------------"

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "🎉 Tutti i pacchetti [ARCH] sono installati!"
else
    echo "⚠️  Pacchetti mancanti: ${MISSING[*]}"
    read -p "Vuoi installarli/aggiornarli con paru/pacman? (s/N): " choice
    if [[ "$choice" =~ ^[sS]$ ]]; then
        paru -S --needed "${MISSING[@]}"
    fi
fi