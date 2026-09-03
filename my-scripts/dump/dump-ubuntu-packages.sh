#!/bin/bash

# ==============================================================================
# Snapshot: manually installed apt packages (not auto dependencies)
# Output: my-packages/installed-ubuntu-packages.txt
# ==============================================================================

OUT="$HOME/Code/dotfiles/my-packages/installed-ubuntu-packages.txt"

if [ ! -f /etc/os-release ] || ! grep -qi '^ID=ubuntu' /etc/os-release; then
    echo "⚠️  This script is for Ubuntu only."
    exit 0
fi

if ! command -v apt-mark &>/dev/null; then
    echo "❌ apt-mark is not installed."
    exit 1
fi

mkdir -p "$(dirname "$OUT")"

{
    echo "# Snapshot $(date +%Y-%m-%d) — inventory, NOT the install list (that is my-setup/packages.txt)"
    echo "# Command: apt-mark showmanual"
    echo ""
    apt-mark showmanual
} > "$OUT"

echo "✅ Wrote $OUT"
echo "   manual: $(apt-mark showmanual | wc -l | tr -d ' ')"
