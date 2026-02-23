# Project: setup-desktop

Modular Linux desktop environment setup system. Automates installation and configuration of a complete dev/desktop environment on Debian/Ubuntu-based systems (originally Linux Mint 19).

## Architecture

```
run.sh                          # Master orchestrator - calls all setup scripts sequentially
├── deborphan/setup-deborphan.sh
├── applications/install-applications.sh
├── i3/120-install-i3.sh        # i3 window manager (numbered = execution order)
├── i3/130-install-extra-software-needed-on-i3.sh
├── i3/140-copy-i3-files-to-config-i3-folder.sh
├── i3/150-copy-feh-background-folder.sh
├── rofi/setup-rofi.sh
├── conky/setup-conky.sh
├── chrome/install-google-chrome.sh
├── java/setup-java.sh
├── node/setup-node.sh
├── bash/bashrc                 # Direct cp to ~/.bashrc (no script)
├── git/setup-git.sh
├── fonts/install-fonts.sh
├── emacs/setup-emacs.sh
├── rust/setup-rust.sh
├── clojure/setup-clojure.sh
├── ssh/setup-ssh.sh
├── docker/setup-docker.sh
├── slack/setup-slack.sh
├── ledger_live/setup-ledger-live.sh
└── vpn/setup_vpn.sh
```

Commented out (disabled): android, solc, virtualbox, caja. Arduino is TODO.

## Directory Layout

Each directory = one component with its own `setup-*.sh` or `install-*.sh` script plus any config files.

### Desktop Environment
| Dir | Purpose | Configs |
|-----|---------|---------|
| `i3/` | i3 window manager | `config/config` (keybindings, 700 lines), `config/i3status.conf`, `config/dunstrc`, `config/compton.conf`, `config/scripts/` |
| `rofi/` | App launcher | `rofi/config.rasi`, `rofi/zenburn.rasi`, `rofi/finder.sh`, `rofi/files.sh` |
| `conky/` | System monitor | 4 themes: `meerkat`, `meerkat2`, `blacky`, `weebeastie` |
| `bash/` | Shell config | `bashrc`, `alacritty.yml` (terminal emulator) |
| `fonts/` | Font files | `.ttf` files copied to `~/.fonts` |

### Development Languages
| Dir | Purpose | Method |
|-----|---------|--------|
| `node/` | Node.js + yarn | nvm (curl) |
| `java/` | JDK 16 + Maven | apt PPA |
| `clojure/` | Clojure CLI + deps.edn | curl installer |
| `rust/` | Rust toolchain + wasm32 | rustup (curl) |
| `emacs/` | Emacs editor | Compiled from git source with native-comp |
| `solc/` | Solidity compiler (disabled) | wget binary |
| `sage/` | SageMath (not in run.sh) | Compiled from source |

### System Tools
| Dir | Purpose | Method |
|-----|---------|--------|
| `applications/` | ~60 apt packages | apt bulk install |
| `docker/` | Docker + compose v2 | apt |
| `git/` | Git global config | git config commands |
| `ssh/` | RSA 4096 keypair + keychain | ssh-keygen + apt |
| `deborphan/` | Orphaned package cleanup | apt |

### Applications
| Dir | Purpose | Method |
|-----|---------|--------|
| `chrome/` | Google Chrome | wget .deb |
| `slack/` | Slack | snap |
| `ledger_live/` | Ledger crypto wallet | wget binary + udev rules |
| `vpn/` | NordVPN | wget .deb |
| `android/` | Android Studio (disabled) | wget + extract |
| `virtualbox/` | VirtualBox (disabled) | wget .deb |

## Key Patterns

- **One dir per component**: installer script + config files co-located
- **Naming**: `setup-{name}.sh` or `install-{name}.sh`
- **i3 scripts**: numeric prefix (`120-`, `130-`, etc.) = execution order
- **Config deployment**: scripts copy from repo to `~/.config/` or `~/`
- **Install methods**: apt, curl/wget binaries, snap, compile from source

## Component Dependencies

- **Clojure requires Java** (Java should be installed first)
- **i3 ecosystem**: rofi (launcher), conky (monitor), fonts (for conky glyphs), feh (wallpaper), dunst (notifications) - all interdependent
- **Emacs compilation** needs build-essential, gcc-10 (from applications)
