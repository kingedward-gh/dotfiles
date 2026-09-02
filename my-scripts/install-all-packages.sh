#!/bin/bash

# ==============================================================================
# Check & Install: ALL PACKAGES (COMMON + OS-SPECIFIC)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    OS_SCRIPT="$SCRIPT_DIR/install-macos-packages.sh"
elif [ -f /etc/arch-release ]; then
    OS="arch"
    OS_SCRIPT="$SCRIPT_DIR/install-arch-packages.sh"
else
    echo "❌ Unsupported operating system."
    exit 1
fi

echo "🖥️  Detected OS: $OS"
echo ""

"$SCRIPT_DIR/install-common-packages.sh" || exit $?

echo ""
"$OS_SCRIPT" || exit $?
