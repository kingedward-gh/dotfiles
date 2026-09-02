#!/bin/bash

# ==============================================================================
# Check & Install: TUTTI I PACCHETTI (COMMON + OS-SPECIFIC)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    OS_SCRIPT="$SCRIPT_DIR/install-macos-packages.sh"
elif [ -f /etc/arch-release ]; then
    OS="arch"
    OS_SCRIPT="$SCRIPT_DIR/install-arch-packages.sh"
else
    echo "❌ Sistema operativo non supportato."
    exit 1
fi

echo "🖥️  Sistema rilevato: $OS"
echo ""

"$SCRIPT_DIR/install-common-packages.sh" || exit $?

echo ""
"$OS_SCRIPT" || exit $?
