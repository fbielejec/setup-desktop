# setup-desktop

Scripted setup of a working development environment, for two machines:

- **Linux** — the primary desktop. i3, Debian/Ubuntu-based (originally Linux Mint 19).
- **macOS** — a work-issued MacBook, set up to feel like the Linux machine.

Both live in this repo. Shell snippets, fonts and the Emacs config are shared;
everything platform-specific is separate.

---

## Linux

```sh
$EDITOR config.sh      # name, email, git user, pinned versions
./run.sh               # 24 steps, logs to ~/.setup-desktop-<timestamp>.log
```

|           |                                                                                 |
|-----------|---------------------------------------------------------------------------------|
| Desktop   | i3, rofi, conky, dunst, compton, feh                                            |
| Shell     | bash + `~/.bashrc.d/` snippets, Alacritty                                       |
| Languages | Python, Node (nvm), Java + Maven, Rust (rustup)                                 |
| Tools     | git, ssh, Docker, GitHub CLI, Claude Code, Qwen-Code, Emacs (built from source) |
| Apps      | Chrome, Slack, NordVPN, Synology Drive                                          |

Not in `run.sh`, run manually: `sage/`, `ledger_live/`.

### A second Linux machine

The scripts are run **on** the target, not pushed to it:

```sh
ssh -t <host>
git clone git@github.com:fbielejec/setup-desktop.git ~/setup-desktop
cd ~/setup-desktop && $EDITOR config.sh && ./run.sh
```

`-t` matters. `run.sh` needs sudo throughout, and without a TTY the run stalls on a
password prompt you cannot see. Run it under `tmux`: Emacs compiles from source, and a
dropped connection otherwise kills the run.

Clone to `~/setup-desktop`, **not** into a Synology-synced directory — two writers on one
`.git` produces sync conflicts inside the index.

On a machine assembled by hand, expect the first run to surface problems. Components
that replace a config back the old one up first (`~/.config/i3.bak-*`,
`~/.emacs.d.bak-*`, `*.bak-<timestamp>`), so a bad outcome is recoverable, but the run
is not yet fully idempotent — see `docs/future-improvements.md`.

---

## macOS

```sh
macos/00-probe.sh                        # FIRST — reports what the machine allows
$EDITOR macos/config.sh                  # work email is required; run.sh refuses without it
macos/run.sh --dry-run                   # review the plan
macos/run.sh                             # 24 steps
```

The probe exists because the target is a managed work laptop. It reports local
admin, MDM enrollment, system-extension policy and whether the Accessibility
permission is grantable, then `run.sh` skips whatever the machine will not
permit rather than failing halfway. On a locked-down machine you still get a
working toolchain — only the window-manager tier drops out.

|                | Linux               | macOS                       |
|----------------|---------------------|-----------------------------|
| Packages       | apt                 | Homebrew (`macos/Brewfile`) |
| Window manager | i3                  | AeroSpace                   |
| Status bar     | i3status            | SketchyBar                  |
| Window borders | i3 `client.focused` | JankyBorders                |
| Launcher       | rofi                | Alfred                      |
| Clipboard      | parcellite          | Alfred                      |
| Wallpaper      | feh                 | desktoppr                   |
| Notifications  | dunst               | terminal-notifier           |
| Containers     | Docker              | colima                      |
| Emacs          | built from git      | `emacs-plus`                |
| System monitor | conky               | *not ported*                |

The window-manager modifier is **⌥⌘** on both keyboards: the QMK external
board produces it from one key (`LAG_T(KC_ESC)` on Caps Lock), the built-in
keyboard from a thumb chord. Same gesture either way — see
`macos/qmk/keymap-notes.md`.

`macos/wallpaper/generate-wallpaper.sh` renders a shortcut cheat-sheet
wallpaper, cross-checked against the live keymap so it cannot drift.

---

## Layout

```
config.sh  lib/  run.sh              # Linux entry point
bash/ fonts/ emacs/ …                # components — shared assets live here
macos/                               # macOS tree, own run.sh + config.sh + lib/
CLAUDE.md                            # architecture reference for agents
macos/README.md                      # macOS specifics
```

Each directory is one component: its `setup-*.sh` script plus its config files.
The macOS scripts read shared assets from their Linux siblings by relative path
rather than copying them, so an edit for one machine reaches the other.
