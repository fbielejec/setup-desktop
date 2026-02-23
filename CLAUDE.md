# Project: setup-desktop

Modular Linux desktop environment setup system. Automates installation and configuration of a complete dev/desktop environment on Debian/Ubuntu-based systems.

## Architecture

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
├── i3/150-copy-feh-background-folder.sh
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
| Path | Purpose |
|------|---------|
| `config.sh` | User-editable settings: name, email, git user, pinned versions, optional flags |
| `lib/common.sh` | Shared helpers: `log_info`, `log_error`, `is_installed`, `is_apt_installed` |
| `docs/` | Architecture documentation |

### Desktop Environment
| Dir | Purpose | Configs |
|-----|---------|---------|
| `i3/` | i3 window manager | `config/config`, `config/i3status.conf`, `config/dunstrc`, `config/compton.conf`, `config/scripts/` |
| `rofi/` | App launcher | `rofi/config.rasi`, `rofi/zenburn.rasi`, `rofi/finder.sh`, `rofi/files.sh` |
| `conky/` | System monitor | 4 themes: `meerkat`, `meerkat2`, `blacky`, `weebeastie` |
| `bash/` | Shell config | `bashrc`, `bashrc.d/` (modular snippets), `alacritty.yml` |
| `fonts/` | Font files | `.ttf` files copied to `~/.fonts` |

### Development Languages & Tools
| Dir | Purpose | Method |
|-----|---------|--------|
| `python/` | Python 3 + pip + venv | apt |
| `node/` | Node.js + npm | nvm (curl) |
| `java/` | JDK + Maven | apt PPA |
| `rust/` | Rust toolchain + wasm32 | rustup (curl) |
| `emacs/` | Emacs editor | Compiled from git source with native-comp |
| `gh/` | GitHub CLI | apt (official repo) |
| `claude-code/` | Claude Code CLI | npm global install |
| `sage/` | SageMath (optional) | Compiled from source |

### System Tools
| Dir | Purpose | Method |
|-----|---------|--------|
| `applications/` | ~60 apt packages | apt bulk install |
| `docker/` | Docker + compose v2 | apt (official repo) |
| `git/` | Git global config | git config commands |
| `ssh/` | RSA 4096 keypair + keychain | ssh-keygen + apt |

### Applications
| Dir | Purpose | Method |
|-----|---------|--------|
| `chrome/` | Google Chrome | wget .deb |
| `slack/` | Slack | snap |
| `vpn/` | NordVPN | wget .deb |
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
