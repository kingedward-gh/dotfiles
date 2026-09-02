#!/bin/bash

# ==============================================================================
# Check & Install: PACCHETTI MACOS ONLY
# ==============================================================================

PKG_FILE="$HOME/Code/dotfiles/my-packages/packages.txt"

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  Questo script è inteso solo per macOS."
    exit 0
fi

if [ ! -f "$PKG_FILE" ]; then
    echo "❌ File $PKG_FILE non trovato!"
    exit 1
fi

echo "🔍 Controllo pacchetti [MACOS]..."
echo "--------------------------------------------------"

MACOS_LINES=$(sed -n '/^\[MACOS\]/,/^\[/p' "$PKG_FILE" | grep -v '^\[' | grep -v '^\s*#' | grep -v '^\s*$')

MISSING=()

while IFS= read -r pkg; do
    pkg=$(echo "$pkg" | xargs)
    if brew list "$pkg" &>/dev/null; then
        echo "  [✓] $pkg"
    else
        echo "  [✗] $pkg (Mancante)"
        MISSING+=("$pkg")
    fi
done <<< "$MACOS_LINES"

echo "--------------------------------------------------"

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "🎉 Tutti i pacchetti [MACOS] sono installati!"
else
    echo "⚠️  Pacchetti mancanti: ${MISSING[*]}"
    read -p "Vuoi installarli ora via Homebrew? (s/N): " choice
    if [[ "$choice" =~ ^[sS]$ ]]; then
        brew install "${MISSING[@]}"
    fi
fi