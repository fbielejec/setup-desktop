# macOS setup

Reproduces the Linux i3 + Emacs environment on a work-issued MacBook.

## Order of operations

```sh
macos/00-probe.sh          # 1. what does this machine actually permit?
$EDITOR macos/config.sh    # 2. work email (required), modifier, feature flags
macos/run.sh --dry-run     # 3. review
macos/run.sh               # 4. go
```

**Run the probe first.** It uses only built-in commands, needs no admin and
changes nothing, so it works on day one before anything is approved or
installed. It writes `~/.setup-macos-probe`, and `run.sh` refuses to start
without it.

The probe ends with a verdict mapped onto the install tiers:

```
Toolchain half (brew, emacs, alacritty, tmux, dotfiles): proceed
Window manager half (aerospace, sketchybar, borders):    grant Accessibility, then re-run
Caps Lock as Hyper (karabiner):                          unproven — use the alt-cmd fallback
```

Gating is one-way: the probe can disable a tier, never enable one. Anything
requiring approval stays off until you turn it on by hand.

## Tiers

| Tier | Components                                                                                       | Requires                                  |
|------|--------------------------------------------------------------------------------------------------|-------------------------------------------|
| 1    | brew, bash, git, ssh, node, rust, python, java, colima, emacs, alacritty, fonts, gh, claude-code | nothing unusual                           |
| 2    | `defaults/` — key repeat, animations, Spaces, menu bar                                           | nothing                                   |
| 3    | aerospace, sketchybar, borders, alfred                                                           | **Accessibility permission**              |
| 4    | karabiner                                                                                        | system extension — *not the default path* |

Off by default and independent of the probe:

- `ssh/setup-sshd.sh` — opens an **inbound** SSH server. Read the header before
  enabling; this is a policy question on a managed laptop, not a technical one.
- `qmk/setup-qmk.sh` — the firmware toolchain. The keymap change itself can be
  flashed from the Linux desktop.

Both also guard internally, so they stay off however the script is reached.
Every other component is gated in `run.sh` alone and still runs standalone —
`bash macos/emacs/setup-emacs.sh`.

## Choosing components

`config.sh` carries one `SETUP_ENABLE_<COMPONENT>` flag per step, the same set
the Linux tree uses. Edit it, or set the variable for one run:

```sh
SETUP_ENABLE_EMACS=false macos/run.sh
```

Tier 3 is one flag, `SETUP_ENABLE_WM`. Homebrew is not switchable — every other
step stands on it.

The flags do not outrank the probe. A skipped step names whichever vetoed it:

```
[SKIP] [19] Setting up AeroSpace... — probe: AX_GRANTED=false
[SKIP] [12] Setting up Emacs... — disabled in config.sh
```

The first means grant the permission and re-run `00-probe.sh`; the second means
edit `config.sh`. `--dry-run` shows the whole plan without touching anything.

## Keyboard

The window-manager modifier is `⌥⌘` on **both** keyboards:

- QMK external board — `LAG_T(KC_ESC)` on Caps Lock: hold for ⌥⌘, tap for Escape
- Built-in keyboard — the Option+Command thumb chord

One gesture, one binding set. `macos/qmk/keymap-notes.md` covers the firmware
change, the PC-vs-Mac bottom-row modifier order, and how to switch to a Hyper
chord if you ever want one.

Karabiner-Elements is **not** required. It installs a DriverKit system
extension, which is the thing MDM is most likely to block; the QMK board does
the same job in firmware, where MDM has no say. `karabiner/` is kept for a
machine with no QMK board.

## Conventions

- **bash 3.2.** macOS ships it and these scripts run before `brew install bash`.
  No associative arrays, `${var,,}`, `mapfile`, `local -n`.
- **`require_brew` in any script that uses brew.** Each step is a fresh `bash`
  and `/opt/homebrew/bin` is not on the default PATH.
- **Shared assets are read, not copied.** `$REPO_DIR/bash/bashrc.d/`,
  `$REPO_DIR/fonts/` — an edit for Linux reaches the Mac on the next run.
- **Config identity guard.** `SETUP_USER_EMAIL` starts empty and `run.sh`
  refuses to run without it, so this machine cannot commit under the personal
  address.
- **Templates are rendered, not edited in place.** Change
  `aerospace.*.toml.template`, not `~/.aerospace.toml`.

### Two template traps

Both have already caused bugs here:

1. The bindings fragment is rendered **once per modifier**. Any binding whose
   chord contains no `@MOD@` placeholder must live in the tail, or it becomes a
   duplicate TOML key.
2. In the head template, every bare top-level key must appear **before** the
   first `[table]` header. TOML nests anything after a header into that table,
   silently.

## Wallpaper

```sh
macos/wallpaper/generate-wallpaper.sh [WIDTHxHEIGHT ...]
```

Renders a shortcut cheat-sheet to `macos/wallpaper/out/` (gitignored). Content
is `shortcuts.tsv`, cross-checked against the rendered AeroSpace keymap in both
directions — an undocumented binding or a documented non-binding fails the
build, so the wallpaper cannot drift out of date.

## Not ported

- **conky** — desktop widgets with no macOS equivalent. The readouts that
  mattered (battery, volume, clock) are in SketchyBar.
- **rofi** — X11 only. Alfred covers launching and clipboard history.
- **i3 `for_window` floating rules** — all name Linux-only applications.
- **`$mode_system`** — the lock/logout/suspend mode. Only lock survives, as
  `ctrl-alt-l`.
- **dunstctl bindings** — Notification Center has no scriptable equivalent.
