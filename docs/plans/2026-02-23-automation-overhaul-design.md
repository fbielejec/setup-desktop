# Setup-Desktop Automation Overhaul

## Goal

Make setup scripts reliably provision a fresh Linux Mint machine to a fully configured development workstation, matching the current machine as reference.

## Target

- Linux Mint only
- No interactivity (linear run)
- Single `config.sh` for all personalizable values

---

## Project Structure

```
run.sh                          # Orchestrator: sources config, runs steps with progress + logging
config.sh                       # Personal info, pinned versions, optional component flags
lib/common.sh                   # Shared helpers (log_info, log_error, is_installed, is_apt_installed)
docs/plans/                     # Design documents
docs/future-improvements.md     # Backlog of future enhancements
```

## config.sh

```bash
# Personal
USER_NAME="Filip"
USER_EMAIL="your@email.com"
GIT_USER="your-github-username"

# Pinned versions (empty = use latest)
JAVA_VERSION="21"
NODE_VERSION="stable"

# Optional components (true/false)
INSTALL_GO=false
INSTALL_QMK=false
INSTALL_FOUNDRY=false

# Claude
ANTHROPIC_MODEL="claude-opus-4-6"
```

## lib/common.sh

Sourced by every component script. Provides:

- `log_info "message"` — `[INFO] message` to console + log file
- `log_error "message"` — `[ERROR] message` to console + log file
- `is_installed "command"` — returns 0 if command exists on PATH
- `is_apt_installed "pkg"` — returns 0 if apt package is installed

## run.sh Pattern

```bash
#!/bin/bash
source config.sh
source lib/common.sh
LOGFILE="$HOME/.setup-desktop-$(date +%Y%m%d-%H%M%S).log"
TOTAL=19
N=0

run_step() {
    N=$((N + 1))
    echo "[$N/$TOTAL] $1"
    bash "$2" 2>&1 | tee -a "$LOGFILE"
}

run_step "Installing base applications..." applications/install-applications.sh
run_step "Installing fonts..."            fonts/install-fonts.sh
# ... etc
```

## Standard Script Pattern

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Installing <component>..."

if is_installed <command>; then
    log_info "<component> already installed, skipping"
    exit 0
fi

# Install logic here...

log_info "<component> installed successfully"
```

---

## Component Execution Order

| #  | Component   | Script                                      | Action                                         |
|----|-------------|---------------------------------------------|-------------------------------------------------|
| 1  | applications| applications/install-applications.sh        | Audit & update ~60 apt packages                 |
| 2  | fonts       | fonts/install-fonts.sh                      | As-is, add guards                               |
| 3  | python      | python/setup-python.sh                      | NEW: pip, venv, pyenv, create ~/.venv/default   |
| 4  | node        | node/setup-node.sh                          | Fix nvm URL (nvm-sh/nvm), install nvm + node    |
| 5  | java        | java/setup-java.sh                          | Switch to openjdk-21-jdk via apt                |
| 6  | rust        | rust/setup-rust.sh                          | As-is, add guards                               |
| 7  | git         | git/setup-git.sh                            | Use config.sh for name/email                    |
| 8  | ssh         | ssh/setup-ssh.sh                            | Use config.sh for email, add guards             |
| 9  | docker      | docker/setup-docker.sh                      | As-is, add guards                               |
| 10 | i3          | i3/120-install-i3.sh                        | As-is, add guards                               |
| 11 | i3          | i3/130-install-extra-software-needed-on-i3.sh| As-is                                          |
| 12 | i3          | i3/140-copy-i3-files-to-config-i3-folder.sh | As-is                                           |
| 13 | i3          | i3/150-copy-feh-background-folder.sh        | As-is                                           |
| 14 | rofi        | rofi/setup-rofi.sh                          | As-is                                           |
| 15 | conky       | conky/setup-conky.sh                        | As-is                                           |
| 16 | bash        | bash/setup-bash.sh                          | Deploy bashrc + ~/.bashrc.d/ snippets + alacritty|
| 17 | emacs       | emacs/setup-emacs.sh                        | Update gcc deps, fix --no-check-certificate     |
| 18 | chrome      | chrome/install-google-chrome.sh             | As-is                                           |
| 19 | gh          | gh/setup-gh.sh                              | NEW: GitHub apt repo + install                  |
| 20 | claude-code | claude-code/setup-claude-code.sh            | NEW: npm install -g @anthropic-ai/claude-code   |
| 21 | slack       | slack/setup-slack.sh                        | Switch from snap to apt .deb                    |
| 22 | nordvpn     | vpn/setup-vpn.sh                            | Update to apt repo method                       |

**Optional (run manually, not in run.sh):**
- `sage/setup-sage.sh` — compile SageMath from source

**Removed from repo:**
- android, solc, caja, virtualbox, deborhpan (typo dir), clojure

---

## Bashrc Architecture

The main `bash/bashrc` contains standard bash config (history, prompt, colors, aliases, ssh-agent, bash completion) and sources modular snippets:

```bash
for f in ~/.bashrc.d/*.sh; do
    [ -r "$f" ] && source "$f"
done
```

Each component's setup script copies its snippet to `~/.bashrc.d/`. Snippets are stored in the repo under `bash/bashrc.d/`:

| Snippet          | Contents                                          | Installed by |
|------------------|---------------------------------------------------|--------------|
| rust.sh          | cargo PATH, RUST_SRC_PATH, cargo env              | rust         |
| node.sh          | NVM_DIR, nvm source (guarded), nvm use default    | node         |
| python.sh        | pyenv init, default venv activate (guarded)        | python       |
| java.sh          | JAVA_HOME                                          | java         |
| docker.sh        | UID/GID exports                                    | docker       |
| claude.sh        | ANTHROPIC_MODEL, CLAUDE_CUSTOM_INSTRUCTIONS        | claude-code  |
| gpg.sh           | GPG_TTY                                            | git          |
| secrets.sh       | source ~/.secrets (guarded)                        | bash         |
| alacritty.sh     | alacritty completions (guarded)                    | bash         |
| go.sh            | GOPATH, GOROOT, PATH (guarded, optional)           | —            |
| qmk.sh          | QMK_HOME (guarded, optional)                       | —            |
| foundry.sh       | foundry PATH (guarded, optional)                   | —            |

All snippets use guards (`command -v`, `[ -f ... ]`, or `[ -d ... ]`) so they don't error if the tool isn't installed yet.

---

## Bashrc Cleanup Summary

**Removed entirely:**
- Arduino paths
- Android block (was commented out)
- OpenCV block
- Gradle block (was commented out)
- aws-glue (was commented out)
- Hardcoded zero_knowledge virtualenv
- rd (rr replacement) — user uses vanilla rr
- flyctl / fly.io

**Fixed:**
- `nvm use 23.9.0` -> `nvm use default`
- Hardcoded `/home/filip/` -> `$HOME` everywhere
- `source $NVM_DIR/nvm.sh` -> guarded version
- `source $HOME/.secrets` -> guarded
- Alacritty completions -> guarded with robust path
- CARGO_HOME -> `$HOME/.cargo`
- Default python venv: `~/.venv/default` (created by python setup script)

---

## Component Update Details

### java (STALE -> UPDATE)
- From: Java 16 via oracle PPA
- To: `apt install openjdk-21-jdk`

### node (FIX URL)
- From: `creationix/nvm/master` curl URL
- To: `nvm-sh/nvm` official URL

### emacs (UPDATE)
- Update gcc/g++ version requirement to match Mint 21 repos
- Remove `--no-check-certificate` from wget (security fix)

### slack (CHANGE METHOD)
- From: snap install
- To: apt .deb install (no snap on target system)

### nordvpn (UPDATE)
- From: hardcoded version 3.16.2 wget
- To: official NordVPN apt repository method

### applications (AUDIT)
- Review ~60 packages against what's actually installed on reference machine
- Remove obsolete packages, add missing ones

### New: python/setup-python.sh
- Install python3-pip, python3-venv via apt
- Install pyenv via git clone
- Create `~/.venv/default`
- Copy python.sh snippet to ~/.bashrc.d/

### New: gh/setup-gh.sh
- Add GitHub CLI apt repository
- `apt install gh`

### New: claude-code/setup-claude-code.sh
- Requires node (dependency order handles this)
- `npm install -g @anthropic-ai/claude-code`
- Copy claude.sh snippet to ~/.bashrc.d/

### New: bash/setup-bash.sh
- Replaces direct `cp bashrc ~/.bashrc`
- Copies bashrc to ~/.bashrc
- Creates ~/.bashrc.d/ directory
- Copies common snippets (secrets.sh, alacritty.sh, gpg.sh)
- Copies optional guarded snippets (go.sh, qmk.sh, foundry.sh) based on config.sh flags
