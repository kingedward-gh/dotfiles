#!/bin/bash

# ==============================================================================
# Check & Install: ALL PACKAGES (COMMON + OS-SPECIFIC)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    OS_SCRIPT="$SCRIPT_DIR/install-macos-packages.sh"
    RUN_COMMON=true
elif [ -f /etc/arch-release ]; then
    OS="arch"
    OS_SCRIPT="$SCRIPT_DIR/install-arch-packages.sh"
    RUN_COMMON=true
elif [ -f /etc/os-release ] && grep -qi '^ID=ubuntu' /etc/os-release; then
    OS="ubuntu"
    OS_SCRIPT="$SCRIPT_DIR/install-ubuntu-packages.sh"
    RUN_COMMON=false
else
    echo "❌ Unsupported operating system."
    exit 1
fi

echo "🖥️  Detected OS: $OS"
echo ""

if [ "$RUN_COMMON" = true ]; then
    "$SCRIPT_DIR/install-common-packages.sh" || exit $?
    echo ""
fi

"$OS_SCRIPT" || exit $?
