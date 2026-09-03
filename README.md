# setup-desktop

Scripted setup of a working development environment, for two machines:

- **Linux** — the primary desktop. i3, Debian/Ubuntu-based (originally Linux Mint 19).
- **macOS** — a work-issued MacBook, set up to feel like the Linux machine.

Both live in this repo. Shell snippets, fonts and the Emacs config are shared;
everything platform-specific is separate.

---

## Linux

```sh
$EDITOR config.sh      # name, email, git user, pinned versions, components
./run.sh               # 26 steps, 24 on by default; logs to ~/.setup-desktop-<timestamp>.log
```

|           |                                                                                 |
|-----------|---------------------------------------------------------------------------------|
| Desktop   | i3, rofi, conky, dunst, compton, feh                                            |
| Shell     | bash + `~/.bashrc.d/` snippets, Alacritty                                       |
| Languages | Python, Node (nvm), Java + Maven, Rust (rustup)                                 |
| Tools     | git, ssh, Docker, GitHub CLI, Claude Code, Qwen-Code, Emacs (built from source) |
| Apps      | Chrome, Slack, NordVPN, Synology Drive                                          |

Off by default: `sage/` (a multi-hour source build) and `ledger_live/`.

### Choosing components

`config.sh` carries one `SETUP_ENABLE_<COMPONENT>` flag per step. Edit it to
change a machine for good, or set the variable for a single run:

```sh
SETUP_ENABLE_EMACS=false ./run.sh       # skip the source build this time
SETUP_ENABLE_SAGE=true ./run.sh         # opt into an off-by-default component
```

`run.sh` prints what is off before it does any work, so a mistyped variable is
visible immediately — `SETUP_ENABLE_EMASC=false` lists `emasc`, which is not a
component, and emacs runs anyway.

The i3 desktop is one flag (`SETUP_ENABLE_WM`) covering i3, its config, the
wallpaper and rofi. Gating happens in `run.sh` only, so every component script
still runs on its own — `bash emacs/setup-emacs.sh` — which is how you retry
one failed step without re-running the other 25.

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

`macos/config.sh` carries the same `SETUP_ENABLE_<COMPONENT>` flags as the Linux
side. The difference is that the probe outranks them: it can only ever *disable*,
so a flag set to true is a request, not a guarantee. Skipped steps say which of
the two vetoed them — `disabled in config.sh` or `probe: AX_GRANTED=false`.

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
