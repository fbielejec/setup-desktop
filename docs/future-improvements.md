# Future Improvements

Several items below were delivered on the macOS side during the port and are
now candidates for back-porting to Linux, where they do not yet exist.

## Back-port from macOS to Linux

These exist in `macos/` and would be worth having on the Linux side too.

### Dry run mode — done on macOS
`macos/run.sh --dry-run` prints the plan without changing anything. The Linux
`run.sh` has no equivalent.

### Install helpers — done on macOS
`brew_install` / `brew_install_cask` collapsed the repeated
"check then install" block. The Linux scripts still open-code
`is_apt_installed` guards, and an `apt_install` helper would remove the same
duplication.

### Step accounting — done on macOS
`macos/run.sh` reports steps run / gated off / not implemented. Linux `run.sh`
just counts to 22.

## Linux bugs found during the macOS port — all fixed

Recorded because each had been silently broken for a long time, and the failure
modes are worth recognising again.

1. **`claude-code/settings.json` was not valid JSON.** A `//` comment on line
   193. Claude Code tolerates it; `jq` does not — so the merge branch in
   `setup-claude-code.sh` failed on every run after the first, once
   `~/.claude/settings.json` existed. The `else` branch (fresh install) worked,
   which is why it went unnoticed. Comment removed; 153 deny rules intact.

2. **`bash/bashrc.d/java.sh` was broken on Java 15+.** It resolved `JAVA_HOME`
   via `jrunscript -e`, which needs Nashorn — removed from the JDK in 15, and
   `config.sh` pins 21. It printed an error on every shell start and left
   `JAVA_HOME` empty. Now resolved from the `java` binary on PATH via
   `readlink -f`. This also masked a stale `JAVA_HOME=/usr/lib/jvm/java-17-oracle`
   coming from **outside this repo** (`/etc/environment` or `~/.profile`) while
   `java` on PATH was 21. Since chased down: nothing in `/etc/environment`,
   `~/.profile`, `~/.bash_profile` or `~/.bashrc` sets it any more, and a fresh
   shell resolves `JAVA_HOME` to the pinned 21.

3. **`bash/alacritty.yml` was dead config.** Alacritty deprecated YAML in 0.13
   and removed it in 0.14. `setup-bash.sh` now deploys `alacritty.toml` and
   renames any leftover `.yml`. The old 854-line file is deleted.

4. **`rofi/setup-rofi.sh` copied from the wrong directory.** It used
   `cp -rf ./rofi/*`, a path relative to the *working* directory. `run.sh`
   invokes it from the repo root without cd-ing, so it produced
   `~/.config/rofi/rofi/config.rasi` plus a stray copy of the installer —
   where neither rofi nor i3's launcher (which hardcodes
   `~/.config/rofi/finder.sh`) would find anything. It only worked when run
   from inside `rofi/`, and the `[ ! -d ~/.config/rofi ]` guard meant it
   no-op'd forever afterwards. Now resolved from `$(dirname "$0")` and
   deploys unconditionally, matching the rest of the repo.

## Still open

### Local harness server install
Currently just the client can be enabled, create setup for the server leg 
(llama-server, model, chat-ui, rag-db).

### Full idempotency
Each script should check state thoroughly (version installed, config already
deployed), skip what is done, report did-vs-skipped, support `--force`, and
handle version upgrades gracefully (Java 17 installed but 21 desired).

**Partially addressed 2026-09-03**, scoped to what destroys data or misfires,
ahead of running this repo on a second machine assembled by hand over years:

1. **`i3/140` deleted the existing config.** `rm -rf ~/.config/i3/*` with no
   backup — the one command in the repo that destroyed user data outright. Now
   moves a differing config to `~/.config/i3.bak-<timestamp>`. The currency
   check compares entry by entry over the same glob the copy uses, because a
   whole-tree `diff -rq` never matches — see *GTK theme config is dead* below.
2. **`emacs/setup-emacs.sh` overwrote `~/.emacs.d`** with no backup, and its
   `git clone` hard-failed on every re-run because the directory already
   existed. Both fixed; the `mv …/*` also silently dropped dotfiles and is now
   `cp -a …/.`.
3. **The nvm guard could never be true.** `is_installed nvm` tested for a binary,
   but nvm is a shell function — so the installer re-ran on every pass.
4. **Docker group membership was skipped on machines that already had Docker,**
   because `usermod -aG` sat inside the not-installed branch.

Still open: `--force`; version-upgrade handling (the `is_installed emacs →
exit 0` guard still couples "binary present" to "config deployed", and the
pinned Synology release will not upgrade an older install); and an `apt_install`
helper. Step accounting is done — both orchestrators now report ran vs skipped.

### Broader Linux support
Currently targets Linux Mint. Generalising to Ubuntu is near-free; other
Debian-based distros (Pop!_OS) need conditional package names and repos.
Note the macOS port deliberately did **not** take the OS-detection route — a
separate tree was preferred over a dispatch layer — so this stays a
Linux-family concern.

### GTK theme config is dead — never deployed, and names missing themes
`i3/config/.config/gtk-3.0/settings.ini` has been tracked since `80f6211`, the
first commit, and has **never been deployed on any machine**. Two independent
faults, and fixing only the first produces a broken result:

1. **The copy never reaches it.** `i3/140` deploys with
   `cp -rf "$SCRIPT_DIR"/config/* …`, and that glob does not match dotfiles.
   Verified 2026-09-03: `~/.config/gtk-3.0/settings.ini` is absent on both the
   laptop and the second machine, and so is `~/.config/i3/.config` — so it has
   not landed in the right place *or* the wrong one. This is the only dotfile
   under any deployed config directory, and `i3/140` holds the only such glob
   in the repo, so the blast radius is exactly this one file.
2. **The path implies a destination the script cannot honour.** The layout
   `config/.config/gtk-3.0/settings.ini` is written relative to `$HOME` — the
   same payload-shaped convention as `rofi/rofi/` — which means it wants to land
   at `~/.config/gtk-3.0/settings.ini`. But `i3/140` copies into
   `~/.config/i3/`, so deploying it unchanged would produce the nonsense path
   `~/.config/i3/.config/gtk-3.0/settings.ini`, which GTK never reads.
3. **Its contents are stale anyway.** It names `gtk-theme-name=Arc-Red-Dark` and
   `gtk-icon-theme-name=Sardi Mono Arc`; **neither is installed** on either
   machine, and `applications/install-applications.sh` installs no theme
   packages at all. Only the cursor it names (`Breeze_Snow`) exists. Deploying
   it as-is would silently fall back to GTK defaults.

So this is not a one-line fix. Deciding it means answering: is a GTK theme still
wanted? If yes, the file needs a home of its own (a `gtk/` component, or a
`$HOME`-rooted payload dir), the theme packages need adding to
`applications/`, and the values need updating to something that exists. If no,
delete the file. Either way the current state — tracked, dead, and quietly
breaking a directory comparison — should not persist.

### Backup filenames collide with hand-made ones
`deploy_config` writes `<file>.bak-YYYYmmdd-HHMMSS`, and there are pre-existing
hand-made backups in the same namespace with a different shape — e.g.
`~/.qwen/settings.json.bak-20260708` (date only) and `.bak-mcp-20260712` (an
infix). A glob like `*.bak-*` conflates the two, which is misleading when
checking whether a run created a backup. Nothing is broken; the fix is either a
more distinctive suffix or a documented convention.

### Teardown
Scripts to remove certain components

### Emacs
Review and improve `emacs.d`. Two macOS-specific gaps to close there: the
config has no `system-type` branches for fonts or modifiers (currently handled
out-of-band by `macos/emacs/early-init.el`), and folding those in would let the
early-init file shrink or disappear.

### Test suite
Automated testing in Docker containers against a fresh Mint install, in CI on
each commit. Nothing equivalent is possible for the macOS side without a Mac
runner.

### AGENTS.md / CLAUDE.md
Maintain a repository with the current personal/global CLAUDE.md / AGENTS.md.
