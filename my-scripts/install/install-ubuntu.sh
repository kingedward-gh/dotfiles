#!/bin/bash

# ==============================================================================
# Check & Install: UBUNTU-ONLY PACKAGES
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_FILE="$REPO/my-setup/packages.txt"

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
        bandwhich) echo "bandwhich" ;;
        lazydocker) echo "lazydocker" ;;
        tailspin) echo "tspin" ;;
        *) echo "" ;;
    esac
}

# Run each binary install in a subshell so cleanup cannot hide its exit status.
install_binary() (
    local pkg="$1" cmd arch project release tag asset tmp
    cmd=$(standalone_cmd "$pkg")
    case "$(uname -m)" in
        x86_64) arch=x86_64 ;;
        aarch64|arm64) arch=aarch64 ;;
        *) echo "❌ $pkg: unsupported architecture: $(uname -m)" >&2; exit 1 ;;
    esac
    case "$pkg" in
        bandwhich) project=imsnif/bandwhich ;;
        lazydocker) project=jesseduffield/lazydocker ;;
        tailspin) project=bensadeh/tailspin ;;
        *) echo "❌ Unknown standalone package: $pkg" >&2; exit 1 ;;
    esac
    echo "📦 Installing $pkg..."
    tmp=$(mktemp -d) || { echo "❌ $pkg: cannot create temporary directory." >&2; exit 1; }
    trap 'rm -rf -- "$tmp"' EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM

    # Resolve once: versioned asset names must match the chosen release.
    release=$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/$project/releases/latest") || {
        echo "❌ $pkg: cannot resolve latest release." >&2; exit 1;
    }
    case "$release" in
        "https://github.com/$project/releases/tag/"*) tag=${release##*/} ;;
        *) echo "❌ $pkg: unexpected release URL: $release" >&2; exit 1 ;;
    esac
    if [[ ! "$tag" =~ ^[vV]?[0-9][a-zA-Z0-9._-]*$ ]]; then
        echo "❌ $pkg: invalid release tag: $tag" >&2; exit 1
    fi
    case "$pkg" in
        bandwhich) asset="bandwhich-${tag}-${arch}-unknown-linux-musl.tar.gz" ;;
        tailspin) asset="tailspin-${arch}-unknown-linux-musl.tar.gz" ;;
        lazydocker)
            [ "$arch" != aarch64 ] || arch=arm64
            asset="lazydocker_${tag#v}_Linux_${arch}.tar.gz"
            ;;
    esac
    curl -fsSL "https://github.com/$project/releases/download/$tag/$asset" -o "$tmp/archive.tar.gz" || {
        echo "❌ $pkg: download failed." >&2; exit 1;
    }
    tar -xzf "$tmp/archive.tar.gz" -C "$tmp" || {
        echo "❌ $pkg: extraction failed." >&2; exit 1;
    }
    if [ ! -f "$tmp/$cmd" ] || [ -L "$tmp/$cmd" ]; then
        echo "❌ $pkg: archive does not contain the expected binary $cmd." >&2; exit 1
    fi
    chmod +x "$tmp/$cmd" && "$tmp/$cmd" --version >/dev/null || {
        echo "❌ $pkg: downloaded binary cannot run." >&2; exit 1;
    }
    sudo install -m 0755 "$tmp/$cmd" "/usr/local/bin/$cmd" || {
        echo "❌ $pkg: installation in /usr/local/bin failed." >&2; exit 1;
    }
    "/usr/local/bin/$cmd" --version >/dev/null || {
        echo "❌ $pkg: installed binary failed verification." >&2; exit 1;
    }
    echo "  [✓] $pkg installed"
)

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
        if [ ${#MISSING_BIN[@]} -gt 0 ]; then
            for tool in curl tar chmod install; do
                command -v "$tool" >/dev/null 2>&1 || {
                    echo "❌ Required command missing: $tool" >&2; exit 1;
                }
            done
        fi
        if [ ${#MISSING_APT[@]} -gt 0 ]; then
            sudo apt -o APT::Update::Error-Mode=any update || {
                echo "❌ APT: package index update failed." >&2; exit 1;
            }
            sudo apt install --yes "${MISSING_APT[@]}" || {
                echo "❌ APT: package installation failed." >&2; exit 1;
            }
        fi
        for pkg in "${MISSING_BIN[@]}"; do
            install_binary "$pkg" || exit $?
        done
    fi
fi
