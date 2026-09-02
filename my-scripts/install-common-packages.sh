#!/bin/bash

# ==============================================================================
# Check & Install: PACCHETTI CONDIVISI (COMMON)
# ==============================================================================

PKG_FILE="$HOME/Code/dotfiles/my-packages/packages.txt"

if [ ! -f "$PKG_FILE" ]; then
    echo "❌ File $PKG_FILE non trovato!"
    exit 1
fi

# Rileva il Sistema Operativo
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [ -f /etc/arch-release ]; then
    OS="arch"
fi

echo "🖥️  Sistema rilevato: $OS"
echo "🔍 Controllo pacchetti [COMMON]..."
echo "--------------------------------------------------"

# Estrai la sezione [COMMON]
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
            echo "  [✗] $ARCH_PKG (Mancante)"
            MISSING+=("$ARCH_PKG")
        fi
    elif [ "$OS" == "macos" ]; then
        if brew list "$BREW_PKG" &>/dev/null; then
            echo "  [✓] $BREW_PKG"
        else
            echo "  [✗] $BREW_PKG (Mancante)"
            MISSING+=("$BREW_PKG")
        fi
    fi
done <<< "$COMMON_LINES"

echo "--------------------------------------------------"

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "🎉 Tutti i pacchetti [COMMON] sono già installati!"
else
    echo "⚠️  Pacchetti mancanti: ${MISSING[*]}"
    read -p "Vuoi installarli/aggiornarli ora? (s/N): " choice
    if [[ "$choice" =~ ^[sS]$ ]]; then
        if [ "$OS" == "arch" ]; then
            sudo pacman -S --needed "${MISSING[@]}"
        elif [ "$OS" == "macos" ]; then
            brew install "${MISSING[@]}"
        fi
    fi
fi