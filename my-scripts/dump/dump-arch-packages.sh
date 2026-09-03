#!/bin/bash

# ==============================================================================
# Snapshot: explicitly installed pacman/paru packages (not dependencies)
# Output: my-packages/installed-arch-packages.txt
# ==============================================================================

OUT="$HOME/Code/dotfiles/my-packages/installed-arch-packages.txt"

if [ ! -f /etc/arch-release ]; then
    echo "⚠️  This script is for Arch Linux only."
    exit 0
fi

if ! command -v pacman &>/dev/null; then
    echo "❌ pacman is not installed."
    exit 1
fi

mkdir -p "$(dirname "$OUT")"

{
    echo "# Snapshot $(date +%Y-%m-%d) — inventory, NOT the install list (that is my-setup/packages.txt)"
    echo "# Command: pacman -Qeq  (explicit, repos + AUR)"
    echo ""
    pacman -Qeq
} > "$OUT"

echo "✅ Wrote $OUT"
echo "   explicit: $(pacman -Qeq | wc -l | tr -d ' ')"
