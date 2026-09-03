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

# Packages not in apt: check via command, install as standalone binaries.
# tailspin's binary is named tspin.
standalone_cmd() {
    case "$1" in
        lazydocker) echo "lazydocker" ;;
        tailspin) echo "tspin" ;;
        *) echo "" ;;
    esac
}

install_lazydocker() {
    echo "📦 Installing lazydocker..."
    curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    if [ -f "$HOME/.local/bin/lazydocker" ]; then
        sudo mv "$HOME/.local/bin/lazydocker" /usr/local/bin/lazydocker
    fi
}

install_tailspin() {
    local tmp arch
    echo "📦 Installing tspin..."
    case "$(uname -m)" in
        x86_64) arch="x86_64-unknown-linux-musl" ;;
        aarch64|arm64) arch="aarch64-unknown-linux-musl" ;;
        *)
            echo "❌ Unsupported architecture for tailspin: $(uname -m)"
            return 1
            ;;
    esac
    tmp=$(mktemp -d)
    if curl -fsSL "https://github.com/bensadeh/tailspin/releases/latest/download/tailspin-${arch}.tar.gz" | tar -xz -C "$tmp"; then
        sudo mv "$tmp/tspin" /usr/local/bin/tspin
        sudo chmod +x /usr/local/bin/tspin
    fi
    rm -rf "$tmp"
}

echo "🔍 Checking [UBUNTU] packages..."
echo "--------------------------------------------------"

UBUNTU_LINES=$(sed -n '/^\[UBUNTU\]/,/^\[/p' "$PKG_FILE" | grep -v '^\[' | grep -v '^\s*#' | grep -v '^\s*$')

MISSING_APT=()
MISSING_BIN=()

while IFS= read -r pkg; do
    pkg=$(echo "$pkg" | xargs)
    cmd=$(standalone_cmd "$pkg")

    if [ -n "$cmd" ]; then
        if command -v "$cmd" &>/dev/null; then
            echo "  [✓] $pkg"
        else
            echo "  [✗] $pkg (missing)"
            MISSING_BIN+=("$pkg")
        fi
    elif dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "ok installed"; then
        VER=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null)
        echo "  [✓] $pkg ($VER)"
    else
        echo "  [✗] $pkg (missing)"
        MISSING_APT+=("$pkg")
    fi
done <<< "$UBUNTU_LINES"

echo "--------------------------------------------------"

MISSING=("${MISSING_APT[@]}" "${MISSING_BIN[@]}")

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "🎉 All [UBUNTU] packages are installed!"
else
    echo "⚠️  Missing packages: ${MISSING[*]}"
    read -p "Install them now? (y/N): " choice
    if [[ "$choice" =~ ^[yY]$ ]]; then
        if [ ${#MISSING_APT[@]} -gt 0 ]; then
            sudo apt update
            sudo apt install --yes "${MISSING_APT[@]}"
        fi
        for pkg in "${MISSING_BIN[@]}"; do
            case "$pkg" in
                lazydocker) install_lazydocker ;;
                tailspin) install_tailspin ;;
            esac
        done
    fi
fi
