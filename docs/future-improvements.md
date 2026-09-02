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

### Interactive component selection
Add a first phase where the user selects which components to install via a TUI
or simple menu. Could also ask questions that drive the setup (preferred
editor, optional languages).

### Full idempotency
Each script should check state thoroughly (version installed, config already
deployed), skip what is done, report did-vs-skipped, support `--force`, and
handle version upgrades gracefully (Java 17 installed but 21 desired).

### Broader Linux support
Currently targets Linux Mint. Generalising to Ubuntu is near-free; other
Debian-based distros (Pop!_OS) need conditional package names and repos.
Note the macOS port deliberately did **not** take the OS-detection route — a
separate tree was preferred over a dispatch layer — so this stays a
Linux-family concern.

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
