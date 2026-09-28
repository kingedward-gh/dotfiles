# dotfiles

Cross-platform sync of configs and scripts between **macOS**, **Arch Linux (omarchy)**, and an **Ubuntu VPS**.

Top-level folders are [GNU Stow](https://www.gnu.org/software/stow/) packages: each mirrors the `$HOME` layout and gets symlinked there by `stow-all.sh`.

---

## Structure

```
dotfiles/
├── zsh/              # zsh config —> Common
├── git/              # gitconfig —> Common
├── gh/               # gh config.yml —> Common (hosts.yml stays local)
├── lazygit/          # lazygit config —> Common
├── lazydocker/       # lazydocker config —> Common
├── nano/             # nanorc —> Common
├── cliamp/           # cliamp config —> Common (folded)
├── yazi/             # yazi config —> Common
├── bat/              # bat config —> Common
├── btop/             # btop config —> Common
├── fastfetch/        # fastfetch config —> Common
├── cursor/           # Cursor CLI config, personal agents and skills —> Common
├── cursor-arch/      # Shared editor settings at Arch paths
├── cursor-macos/     # Cursor config —> macOS (symlink wrapper, do not edit)
├── iterm2-macos/           # iTerm2 config —> macOS
├── mactop-macos/           # mactop config —> macOS
├── alfred/           # Alfred prefs (not stowed — set folder in the app)
├── rectangle/        # Rectangle config —> macOS
├── foot-arch/             # Foot terminal config —> Arch
├── starlink-tracker/ # starlink script —> Common (stow wrapper, do not edit)
├── my-setup/         # setup manifests
├── my-dump/          # package inventory dump/snapshot
└── my-scripts/       # install / dump / stow
    ├── install/
    ├── dump/
    ├── stow/
    └── starlink-tracker/
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



### Ubuntu — apt

apt is already on Ubuntu. No extra helper is required.

---



## Install scripts

Install packages listed in `my-setup/packages.txt`.

```bash
# Install everything (COMMON + OS-specific) — auto-detects OS
bash my-scripts/install/install-all.sh

# Or run individually:
bash my-scripts/install/install-common.sh   # shared packages (macOS + Arch)
bash my-scripts/install/install-macos.sh    # macOS only (Homebrew)
bash my-scripts/install/install-arch.sh     # Arch only (pacman/paru)
bash my-scripts/install/install-ubuntu.sh   # Ubuntu only (apt)
```

`packages.txt` uses `brew_name | arch_name` for `[COMMON]` (macOS + Arch). `[MACOS]`, `[ARCH]`, and `[UBUNTU]` hold OS-specific packages. Ubuntu (VPS) installs **only** `[UBUNTU]`, not `[COMMON]`.

---



## Dump scripts

Save a snapshot of **currently installed** packages (useful to compare against `packages.txt`).

```bash
bash my-scripts/dump/dump-macos.sh    # → my-dump/macos-dump.txt
bash my-scripts/dump/dump-arch.sh     # → my-dump/arch-dump.txt
bash my-scripts/dump/dump-ubuntu.sh   # → my-dump/ubuntu-dump.txt
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

The `cursor` package stores the shared CLI configuration (`.cursor/cli-config.json`), personal agents (`.cursor/agents/`) and skills (`.cursor/skills/`). Setup links them into `~/.cursor/` on macOS and Arch, keeping `~/.cursor` itself local. Agents and skills are directory symlinks; the CLI configuration is a file symlink. Empty target directories are removed before Stow runs; if either directory already contains files, move them into the matching package directory first. The `.gitkeep` files preserve empty directories in Git.

The `cursor-arch` package holds the canonical editor `settings.json` and `keybindings.json` under `.config/Cursor/User/`. On Arch, Stow links these individual files. On macOS, `cursor-macos` links the same originals into `~/Library/Application Support/Cursor/User/`. Both platforms use the `cursor` common package plus their platform-specific package. Cache files, Cursor-managed `skills-cursor`, plans and transcripts stay outside these packages.

---



## Git ignore

The `git` package stows `~/.gitconfig` and Git hooks. Ignore rules are managed in each repository's `.gitignore`; there is no shared global ignore file or `core.excludesFile` setting.

Each repository's `.gitignore` starts with OS, editor, backup, personal scratch (`_ignore/`, `_global`), and environment-file rules. Repository-specific rules follow, so their exceptions and overrides take precedence.

When creating a new repository, copy the shared rules into its `.gitignore`. Changes to those rules must be applied separately to each repository.


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
