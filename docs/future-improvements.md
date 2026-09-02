# Future Improvements

Several items below were delivered on the macOS side during the port and are
now candidates for back-porting to Linux, where they do not yet exist.

## Back-port from macOS to Linux

These exist in `macos/` and would be worth having on the Linux side too.

### Dry run mode — done on macOS
`macos/run.sh --dry-run` prints the plan without changing anything. The Linux
`run.sh` has no equivalent.

### Backup before overwrite — done on macOS
`macos/lib/common.sh`'s `deploy_config` backs up an existing file to a
timestamped copy, but only when the content actually differs. The Linux
`bash/setup-bash.sh` still overwrites `~/.bashrc` unconditionally.

### Install helpers — done on macOS
`brew_install` / `brew_install_cask` collapsed the repeated
"check then install" block. The Linux scripts still open-code
`is_apt_installed` guards, and an `apt_install` helper would remove the same
duplication.

### Step accounting — done on macOS
`macos/run.sh` reports steps run / gated off / not implemented. Linux `run.sh`
just counts to 22.

## Linux bugs found during the macOS port

Three real defects on the Linux side, all currently unfixed:

1. **`claude-code/settings.json` is not valid JSON.** Line 193 has a `//`
   comment. Claude Code tolerates it; `jq` does not. So the merge branch in
   `claude-code/setup-claude-code.sh` fails on every run after the first, when
   `~/.claude/settings.json` already exists. Fix: strip comment-only lines
   before piping to `jq`, as `macos/claude-code/setup-claude-code.sh` does.

2. **`bash/bashrc.d/java.sh` is broken on Java 15+.** It resolves `JAVA_HOME`
   via `jrunscript -e`, which needs Nashorn — removed from the JDK in 15.
   `config.sh` pins Java 21, so this prints an error on every shell startup and
   sets `JAVA_HOME` to an empty string. The macOS branch added to that file uses
   `/usr/libexec/java_home` and is unaffected; Linux needs its own fix.

3. **`bash/alacritty.yml` is dead.** Alacritty removed YAML support in 0.14.
   `bash/alacritty.toml` now exists as the shared base, but
   `bash/setup-bash.sh` still deploys the `.yml`. The 29 KB of commented-out
   template in the old file can go with it.

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
