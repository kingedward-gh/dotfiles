#!/bin/bash

# ==============================================================================
# Snapshot: requested Homebrew packages (not dependencies)
# Output: my-packages/installed-macos-packages.txt
# ==============================================================================

OUT="$HOME/Code/dotfiles/my-packages/installed-macos-packages.txt"

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  This script is for macOS only."
    exit 0
fi

if ! command -v brew &>/dev/null; then
    echo "❌ brew is not installed."
    exit 1
fi

mkdir -p "$(dirname "$OUT")"

{
    echo "# Snapshot $(date +%Y-%m-%d) — inventory, NOT the install list (that is packages.txt)"
    echo "# Command: brew leaves + brew list --cask"
    echo ""
    echo "[FORMULAE]"
    brew leaves
    echo ""
    echo "[CASKS]"
    brew list --cask
} > "$OUT"

echo "✅ Wrote $OUT"
echo "   formulae: $(brew leaves | wc -l | tr -d ' ')  casks: $(brew list --cask | wc -l | tr -d ' ')"
