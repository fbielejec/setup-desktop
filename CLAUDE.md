# Project: setup-desktop

Modular desktop environment setup system. Automates installation and configuration of a complete dev/desktop environment.

**Two platforms, two trees, one repo:**

| | Linux (primary) | macOS (work laptop) |
|---|---|---|
| Entry point | `run.sh` | `macos/run.sh` |
| Package manager | apt | Homebrew (`macos/Brewfile`) |
| Window manager | i3 | AeroSpace |
| Root of tree | repo root | `macos/` |

There is **no OS-dispatch abstraction** — this is deliberate. `macos/` is a
separate tree with its own `run.sh`, `config.sh` and `lib/common.sh`. What it
does *not* do is copy portable assets: its scripts read siblings by relative
path (`$REPO_DIR/bash/bashrc.d/`, `$REPO_DIR/fonts/`), so a shell snippet
edited for Linux reaches the Mac on the next run. Sharing is for config assets,
never for control flow.

See `macos/README.md` for the macOS tree.

## Architecture (Linux)

```
config.sh                       # Personalizable settings (name, email, versions)
lib/common.sh                   # Shared helpers sourced by every setup script
run.sh                          # Master orchestrator - 22 steps sequentially
├── applications/install-applications.sh
├── fonts/install-fonts.sh
├── python/setup-python.sh
├── node/setup-node.sh
├── java/setup-java.sh
├── rust/setup_rust.sh
├── git/setup-git.sh
├── ssh/setup-ssh.sh
├── docker/setup-docker.sh
├── i3/120-install-i3.sh
├── i3/130-install-extra-software-needed-on-i3.sh
├── i3/140-copy-i3-files-to-config-i3-folder.sh
├── i3/150-copy-feh-background.sh
├── rofi/setup-rofi.sh
├── conky/setup-conky.sh
├── bash/setup-bash.sh          # Deploys bashrc + ~/.bashrc.d/ snippets
├── emacs/setup-emacs.sh
├── chrome/install-google-chrome.sh
├── gh/setup-gh.sh
├── claude-code/setup-claude-code.sh
├── slack/setup-slack.sh
└── vpn/setup_vpn.sh
```

Optional (not in run.sh, run manually): `sage/`, `ledger_live/`.

## Directory Layout

Each directory = one component with its own `setup-*.sh` or `install-*.sh` script plus config files.

### Infrastructure
| Path            | Purpose                                                                        |
|-----------------|--------------------------------------------------------------------------------|
| `config.sh`     | User-editable settings: name, email, git user, pinned versions, optional flags |
| `lib/common.sh` | Shared helpers: `log_info`, `log_error`, `is_installed`, `is_apt_installed`    |
| `docs/`         | Architecture documentation                                                     |

### Desktop Environment
| Dir      | Purpose           | Configs                                                                                             |
|----------|-------------------|-----------------------------------------------------------------------------------------------------|
| `i3/`    | i3 window manager | `config/config`, `config/i3status.conf`, `config/dunstrc`, `config/compton.conf`, `config/scripts/` |
| `rofi/`  | App launcher      | `rofi/config.rasi`, `rofi/zenburn.rasi`, `rofi/finder.sh`, `rofi/files.sh`                          |
| `conky/` | System monitor    | 4 themes: `meerkat`, `meerkat2`, `blacky`, `weebeastie`                                             |
| `bash/`  | Shell config      | `bashrc`, `bashrc.d/` (modular snippets), `alacritty.toml`                                          |
| `fonts/` | Font files        | `.ttf` files copied to `~/.fonts`                                                                   |

**The `rofi/rofi/` nesting is intentional.** `setup-rofi.sh` copies the inner
`rofi/` wholesale into `~/.config/rofi/`, so that directory is the payload, laid
out exactly as it must appear under `~/.config/`. The Configs column above is
written relative to it. Do not flatten it.

### Development Languages & Tools
| Dir            | Purpose                 | Method                                    |
|----------------|-------------------------|-------------------------------------------|
| `python/`      | Python 3 + pip + venv   | apt                                       |
| `node/`        | Node.js + npm           | nvm (curl)                                |
| `java/`        | JDK + Maven             | apt PPA                                   |
| `rust/`        | Rust toolchain + wasm32 | rustup (curl)                             |
| `emacs/`       | Emacs editor            | Compiled from git source with native-comp |
| `gh/`          | GitHub CLI              | apt (official repo)                       |
| `claude-code/` | Claude Code CLI         | npm global install                        |
| `sage/`        | SageMath (optional)     | Compiled from source                      |

### System Tools
| Dir             | Purpose                     | Method              |
|-----------------|-----------------------------|---------------------|
| `applications/` | ~60 apt packages            | apt bulk install    |
| `docker/`       | Docker + compose v2         | apt (official repo) |
| `git/`          | Git global config           | git config commands |
| `ssh/`          | RSA 4096 keypair + keychain | ssh-keygen + apt    |

### Applications
| Dir            | Purpose                         | Method                   |
|----------------|---------------------------------|--------------------------|
| `chrome/`      | Google Chrome                   | wget .deb                |
| `slack/`       | Slack                           | wget .deb                |
| `vpn/`         | NordVPN                         | wget .deb                |
| `ledger_live/` | Ledger crypto wallet (optional) | wget binary + udev rules |

## Key Patterns

- **`config.sh`** at project root holds all personalizable values (name, email, versions, optional flags)
- **`lib/common.sh`** sourced by every setup script for logging and guard helpers
- **Standard script pattern**: `set -e`, source `common.sh`, idempotent guards (`is_installed`/`is_apt_installed`), structured logging
- **`~/.bashrc.d/`** modular shell snippets: one `.sh` file per tool (node, java, rust, python, etc.), sourced by `~/.bashrc` via a loop
- **One dir per component**: installer script + config files co-located
- **i3 scripts**: numeric prefix (`120-`, `130-`, etc.) = execution order
- **Config deployment**: scripts copy from repo to `~/.config/` or `~/`
- **Optional components**: `sage/` and `ledger_live/` are not in `run.sh`; run their scripts manually

## Component Dependencies

- **Claude Code requires Node.js** (Node should be installed first)
- **i3 ecosystem**: rofi (launcher), conky (monitor), fonts (for conky glyphs), feh (wallpaper), dunst (notifications) - all interdependent
- **Emacs compilation** needs build-essential, gcc (from applications)

## Architecture (macOS)

Targets a work-issued, MDM-managed MacBook running alongside the Linux desktop.

```
macos/
├── 00-probe.sh             # ALWAYS RUN FIRST — reports what the machine permits
├── run.sh                  # orchestrator, 23 steps, gated on the probe
├── config.sh               # $MOD, work git identity, feature flags
├── lib/common.sh           # brew_install, deploy_config, probe_value, load_brew_env
├── Brewfile                # ordered by approval risk, truncated when gated
├── brew/ bash/ git/ ssh/ node/ rust/ python/ java/ docker/ emacs/
├── alacritty/ fonts/ gh/ claude-code/ defaults/          # toolchain + dotfiles
├── aerospace/ sketchybar/ borders/ alfred/               # window manager tier
├── karabiner/ qmk/                                       # keyboard
└── wallpaper/              # shortcut cheat-sheet generator
```

### macOS-specific patterns

- **Probe-gated execution.** `00-probe.sh` records machine capabilities to
  `~/.setup-macos-probe`. `run.sh` reads it and skips tiers the machine will not
  permit rather than failing halfway. The probe can only *disable* a tier, never
  auto-enable one. It is standalone — no sourcing, no repo needed, bash 3.2 —
  so it can be pasted into a fresh terminal on day one.
- **bash 3.2 compatibility is mandatory.** macOS ships 3.2 and these scripts run
  before `brew install bash`. No associative arrays, `${var,,}`, `mapfile`, or
  `local -n`.
- **`require_brew` in every script that needs brew.** Each step is a fresh
  `bash`, and `/opt/homebrew/bin` is not on the default PATH, so `brew shellenv`
  must be re-evaluated per script via `load_brew_env`.
- **Templates, not static configs.** `aerospace.{head,bindings,tail}.toml.template`
  and `alacritty.toml.template` are rendered with values from `config.sh`. The
  bindings fragment is rendered once *per modifier*, so any binding with a
  literal (non-`@MOD@`) chord must live in the tail or it becomes a duplicate
  TOML key.
- **TOML ordering.** In the AeroSpace head template every bare top-level key
  must precede the first `[table]` header, or TOML silently nests it.
- **Config identity guard.** `SETUP_USER_EMAIL` is empty by default and `run.sh`
  refuses to start without it, so a work machine cannot inherit the personal
  git address.

### macOS component dependencies

- **Everything needs Homebrew** except `00-probe.sh`
- **AeroSpace, SketchyBar, JankyBorders, Alfred** all need the Accessibility
  permission — gated on `AX_GRANTED` from the probe
- **SketchyBar reads AeroSpace** (`aerospace list-workspaces`) and is driven by
  its `exec-on-workspace-change` event; AeroSpace launches both it and `borders`
  via `after-startup-command`
- **JankyBorders** is configured by `~/.config/borders/bordersrc` only —
  AeroSpace must invoke `borders` with no arguments or the file is ignored
- **Karabiner is NOT on the default path.** The QMK keyboard emits the modifier
  chord in firmware, which removes the system-extension dependency entirely
- **`macos/wallpaper/`** cross-checks itself against the rendered AeroSpace
  keymap in both directions and fails the build on any mismatch
