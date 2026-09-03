# dotfiles

Cross-platform sync of configs and scripts between **macOS** and **Arch Linux (omarchy)**.

Top-level folders are [GNU Stow](https://www.gnu.org/software/stow/) packages: each mirrors the `$HOME` layout and gets symlinked there by `stow-all.sh`.

---

## Structure

```
dotfiles/
├── zsh/              # zsh config —> Common
├── cursor/           # Cursor config —> Arch
├── cursor-macos/     # Cursor config —> macOS (symlink wrapper, do not edit)
├── iterm2/           # iTerm2 config —> macOS
├── foot/             # Foot terminal config —> Arch
├── starlink-tracker/ # starlink script —> Common (stow wrapper, do not edit)
├── my-setup/         # setup manifests 
├── my-packages/      # package inventory dump/snapshot
└── my-scripts/       # install / dump / stow
    ├── install/
    ├── dump/
    └── stow/
```

---



## Requirements

Install these before running the install scripts.

### macOS — [Homebrew](https://brew.sh)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Arch — [paru](https://github.com/Morganamilo/paru)

```bash
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

---



## Install scripts

Install packages listed in `my-setup/packages.txt`.

```bash
# Install everything (COMMON + OS-specific) — auto-detects OS
bash my-scripts/install/install-all-packages.sh

# Or run individually:
bash my-scripts/install/install-common-packages.sh   # shared packages
bash my-scripts/install/install-macos-packages.sh    # macOS only (Homebrew)
bash my-scripts/install/install-arch-packages.sh     # Arch only (pacman/paru)
```

`packages.txt` uses `brew_name | arch_name` for shared packages; `[MACOS]` and `[ARCH]` sections hold OS-specific ones.

---



## Dump scripts

Save a snapshot of **currently installed** packages (useful to compare against `packages.txt`).

```bash
bash my-scripts/dump/dump-macos-packages.sh   # → my-packages/installed-macos-packages.txt
bash my-scripts/dump/dump-arch-packages.sh    # → my-packages/installed-arch-packages.txt
```

> Output files are inventory snapshots only — **not** the install list.

---



## Stow scripts

Read `my-setup/stow.txt` and symlink package folders into `$HOME`.

```bash
bash my-scripts/stow/stow-all.sh
```

Packages are stowed in order:

1. `[COMMON]` section (e.g. `zsh`, `starlink-tracker`)
2. OS-specific sections (`[MACOS]` or `[ARCH]`)

To add a new config folder, create it in the repo and add its name to `stow.txt` in the right section.

---



## Standalone scripts

Scripts that are not part of the stow/install workflow.

### `starlink-tracker`

Logs changes to public IP, geolocation, and ISP — useful for monitoring Starlink connectivity.

After stow, the binary is available at `~/.local/bin/starlink-tracker`.

**Interactive use:**

```bash
starlink-tracker
```

Prints current status and offers to open/view the log.

**Automated use (cron every 5 minutes):**

```cron
*/5 * * * * "$HOME/.local/bin/starlink-tracker"
```

In non-TTY mode (cron) it stays silent except on hard errors.

Log file: `~/.starlink_tracker.log`.