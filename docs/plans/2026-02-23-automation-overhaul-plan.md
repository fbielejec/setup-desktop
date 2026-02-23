# Setup-Desktop Automation Overhaul — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make setup scripts reliably provision a fresh Linux Mint machine to a fully configured dev workstation.

**Architecture:** Central `config.sh` for personalization, shared `lib/common.sh` for helpers, modular `~/.bashrc.d/` snippets per component. Each script follows a standard pattern with guards and logging.

**Tech Stack:** Bash, apt, curl, git

---

## Task 1: Clean up stale directories

Remove directories for components no longer needed.

**Files:**
- Delete: `android/` (entire directory)
- Delete: `solc/` (entire directory)
- Delete: `caja/` (entire directory)
- Delete: `virtualbox/` (entire directory)
- Delete: `deborhpan/` (entire directory)
- Delete: `clojure/` (entire directory)

**Step 1: Remove directories**

```bash
cd /home/filip/CloudStation/DevOps/setup-desktop
rm -rf android solc caja virtualbox deborhpan clojure
```

**Step 2: Commit**

```bash
git add -A
git commit -m "remove stale components: android, solc, caja, virtualbox, deborphan, clojure"
```

---

## Task 2: Create config.sh

**Files:**
- Create: `config.sh`

**Step 1: Write config.sh**

```bash
#!/bin/bash
# setup-desktop configuration
# Edit these values before running on a new machine.

# Personal
SETUP_USER_NAME="Filip"
SETUP_USER_EMAIL="fbielejec@gmail.com"
SETUP_GIT_USER="fbielejec"

# Pinned versions (empty = use latest/default)
SETUP_JAVA_VERSION="21"
SETUP_NODE_VERSION="stable"

# Optional components (true/false)
SETUP_INSTALL_GO=false
SETUP_INSTALL_QMK=false
SETUP_INSTALL_FOUNDRY=false

# Claude Code
SETUP_ANTHROPIC_MODEL="claude-opus-4-6"
```

**Step 2: Commit**

```bash
git add config.sh
git commit -m "add config.sh for personalizable values"
```

---

## Task 3: Create lib/common.sh

**Files:**
- Create: `lib/common.sh`

**Step 1: Write lib/common.sh**

```bash
#!/bin/bash
# Shared helpers for setup scripts
# Source this at the top of every component script.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Log file path — set by run.sh, fallback for standalone runs
SETUP_LOGFILE="${SETUP_LOGFILE:-$HOME/.setup-desktop-$(date +%Y%m%d-%H%M%S).log}"

log_info() {
    local msg="[INFO] $1"
    echo "$msg"
    echo "$msg" >> "$SETUP_LOGFILE"
}

log_error() {
    local msg="[ERROR] $1"
    echo "$msg" >&2
    echo "$msg" >> "$SETUP_LOGFILE"
}

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

is_apt_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}
```

**Step 2: Commit**

```bash
git add lib/common.sh
git commit -m "add lib/common.sh with shared helper functions"
```

---

## Task 4: Create bashrc.d snippets

**Files:**
- Create: `bash/bashrc.d/rust.sh`
- Create: `bash/bashrc.d/node.sh`
- Create: `bash/bashrc.d/python.sh`
- Create: `bash/bashrc.d/java.sh`
- Create: `bash/bashrc.d/docker.sh`
- Create: `bash/bashrc.d/claude.sh`
- Create: `bash/bashrc.d/gpg.sh`
- Create: `bash/bashrc.d/secrets.sh`
- Create: `bash/bashrc.d/alacritty.sh`
- Create: `bash/bashrc.d/go.sh`
- Create: `bash/bashrc.d/qmk.sh`
- Create: `bash/bashrc.d/foundry.sh`

**Step 1: Write each snippet**

`bash/bashrc.d/rust.sh`:
```bash
# Rust toolchain
if [ -d "$HOME/.cargo" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
    export CARGO_HOME="$HOME/.cargo"
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    if command -v rustc >/dev/null 2>&1; then
        export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
    fi
fi
```

`bash/bashrc.d/node.sh`:
```bash
# Node.js via nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
```

`bash/bashrc.d/python.sh`:
```bash
# Python: pyenv + default venv
export PATH="$HOME/.local/bin:$PATH"
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    [ -d "$PYENV_ROOT/bin" ] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - bash)"
fi
[ -f "$HOME/.venv/default/bin/activate" ] && source "$HOME/.venv/default/bin/activate"
```

`bash/bashrc.d/java.sh`:
```bash
# Java
if command -v jrunscript >/dev/null 2>&1; then
    export JAVA_HOME="$(jrunscript -e 'java.lang.System.out.println(java.lang.System.getProperty("java.home"));')"
fi
```

`bash/bashrc.d/docker.sh`:
```bash
# Docker compose UID/GID
export UID=$(id -u)
export GID=$(id -g)
```

`bash/bashrc.d/claude.sh`:
```bash
# Claude Code
export ANTHROPIC_MODEL="${ANTHROPIC_MODEL:-claude-opus-4-6}"
export CLAUDE_CUSTOM_INSTRUCTIONS="$HOME/.config/CLAUDE.md"
```

`bash/bashrc.d/gpg.sh`:
```bash
# GPG
export GPG_TTY=$(tty)
```

`bash/bashrc.d/secrets.sh`:
```bash
# User secrets
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"
```

`bash/bashrc.d/alacritty.sh`:
```bash
# Alacritty completions
if command -v alacritty >/dev/null 2>&1; then
    for f in "$HOME/Programs/alacritty/extra/completions/alacritty.bash" \
             "/usr/share/bash-completion/completions/alacritty"; do
        if [ -f "$f" ]; then
            source "$f"
            break
        fi
    done
fi
```

`bash/bashrc.d/go.sh`:
```bash
# Go (optional)
if [ -d "/usr/local/go" ]; then
    export GOPATH="$HOME/go"
    export GOROOT="/usr/local/go"
    export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"
fi
```

`bash/bashrc.d/qmk.sh`:
```bash
# QMK keyboard firmware (optional)
[ -d "$HOME/qmk_firmware" ] && export QMK_HOME="$HOME/qmk_firmware"
```

`bash/bashrc.d/foundry.sh`:
```bash
# Foundry / Ethereum (optional)
[ -d "$HOME/.foundry/bin" ] && export PATH="$PATH:$HOME/.foundry/bin"
```

**Step 2: Commit**

```bash
git add bash/bashrc.d/
git commit -m "add modular bashrc.d snippets for all components"
```

---

## Task 5: Rewrite bash/bashrc and bash/setup-bash.sh

**Files:**
- Modify: `bash/bashrc` — strip out all tool-specific blocks, add bashrc.d sourcing loop
- Modify: `bash/setup-bash.sh` — full setup script that deploys bashrc, bashrc.d, and alacritty config

**Step 1: Rewrite bash/bashrc**

Keep: interactive check, history, checkwinsize, lesspipe, debian_chroot, prompt, colors, ls/grep aliases, ll/la/l aliases, alert alias, bash_aliases sourcing, bash completion, ssh-agent block.

Remove: everything after the ssh-agent block (all tool-specific exports/sources).

Add at the end (before any removed content):
```bash
# Source modular config snippets
for f in ~/.bashrc.d/*.sh; do
    [ -r "$f" ] && source "$f"
done
```

**Step 2: Rewrite bash/setup-bash.sh**

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up bash configuration..."

# Deploy bashrc
cp "$(dirname "$0")/bashrc" "$HOME/.bashrc"
log_info "Copied bashrc to ~/.bashrc"

# Create bashrc.d directory
mkdir -p "$HOME/.bashrc.d"

# Copy all snippets
for f in "$(dirname "$0")"/bashrc.d/*.sh; do
    cp "$f" "$HOME/.bashrc.d/"
done
log_info "Copied bashrc.d snippets to ~/.bashrc.d/"

# Deploy alacritty config
mkdir -p "$HOME/.config/alacritty"
cp "$(dirname "$0")/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"
log_info "Copied alacritty config"

log_info "Bash configuration complete"
```

**Step 3: Commit**

```bash
git add bash/
git commit -m "rewrite bashrc with modular bashrc.d architecture"
```

---

## Task 6: Update git/setup-git.sh

**Files:**
- Modify: `git/setup-git.sh`

**Step 1: Rewrite the script**

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Configuring git..."

if ! is_installed git; then
    log_info "Installing git..."
    sudo apt-get install -y git
fi

git config --global user.name "$SETUP_USER_NAME"
git config --global user.email "$SETUP_USER_EMAIL"
git config --global core.editor nano
git config --global credential.helper 'cache --timeout=18000'
git config --global push.default simple

log_info "Git configured for $SETUP_USER_NAME <$SETUP_USER_EMAIL>"
```

Note: removed `sudo git config --system` — use `--global` only (doesn't need root).

**Step 2: Commit**

```bash
git add git/setup-git.sh
git commit -m "update git setup to use config.sh for personal info"
```

---

## Task 7: Update ssh/setup-ssh.sh

**Files:**
- Modify: `ssh/setup-ssh.sh`

**Step 1: Rewrite the script**

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up SSH..."

if [ -f "$HOME/.ssh/id_rsa" ]; then
    log_info "SSH keypair already exists, skipping generation"
else
    log_info "Generating SSH keypair..."
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t rsa -b 4096 -C "$SETUP_USER_EMAIL"
fi

if ! is_apt_installed keychain; then
    log_info "Installing keychain..."
    sudo apt-get install -y keychain
fi

log_info "SSH setup complete"
```

**Step 2: Commit**

```bash
git add ssh/setup-ssh.sh
git commit -m "update ssh setup to use config.sh, add guards"
```

---

## Task 8: Update java/setup-java.sh

**Files:**
- Modify: `java/setup-java.sh`

**Step 1: Rewrite the script**

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up Java..."

JAVA_PKG="openjdk-${SETUP_JAVA_VERSION}-jdk"

if is_apt_installed "$JAVA_PKG"; then
    log_info "Java ($JAVA_PKG) already installed, skipping"
    exit 0
fi

log_info "Installing $JAVA_PKG and Maven..."
sudo apt-get install -y "$JAVA_PKG" maven

log_info "Java setup complete"
```

**Step 2: Commit**

```bash
git add java/setup-java.sh
git commit -m "update java setup: Java 16 -> 21 via apt, use config.sh"
```

---

## Task 9: Update node/setup-node.sh

**Files:**
- Modify: `node/setup-node.sh`

**Step 1: Rewrite the script**

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up Node.js..."

if is_installed nvm; then
    log_info "nvm already installed, skipping"
else
    log_info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
fi

# Source nvm for this session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

log_info "Installing Node.js (${SETUP_NODE_VERSION})..."
nvm install "$SETUP_NODE_VERSION"
nvm alias default "$SETUP_NODE_VERSION"

log_info "Installing yarn..."
npm install -g yarn

log_info "Node.js setup complete"
```

**Step 2: Commit**

```bash
git add node/setup-node.sh
git commit -m "fix node setup: update nvm URL, use config.sh for version"
```

---

## Task 10: Update rust/setup_rust.sh

**Files:**
- Modify: `rust/setup_rust.sh`

**Step 1: Rewrite the script**

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Rust..."

if is_installed rustup; then
    log_info "Rust already installed, updating..."
    rustup update
else
    log_info "Installing Rust via rustup..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"
fi

rustup default stable
rustup target add wasm32-unknown-unknown
rustup component add rustfmt

log_info "Rust setup complete"
```

**Step 2: Commit**

```bash
git add rust/setup_rust.sh
git commit -m "update rust setup with guards and common.sh"
```

---

## Task 11: Update docker/setup-docker.sh

**Files:**
- Modify: `docker/setup-docker.sh`

**Step 1: Rewrite the script**

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Docker..."

if is_installed docker; then
    log_info "Docker already installed, skipping"
else
    log_info "Installing Docker..."
    sudo apt-get install -y docker.io docker-compose-v2
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER"
fi

log_info "Docker setup complete"
```

**Step 2: Commit**

```bash
git add docker/setup-docker.sh
git commit -m "update docker setup with guards and common.sh"
```

---

## Task 12: Update i3 scripts

**Files:**
- Modify: `i3/120-install-i3.sh`
- Modify: `i3/130-install-extra-software-needed-on-i3.sh`
- Modify: `i3/140-copy-i3-files-to-config-i3-folder.sh`
- Modify: `i3/150-copy-feh-background-folder.sh`

**Step 1: Add common.sh sourcing and guards to each**

For each script, add at the top:
```bash
set -e
source "$(dirname "$0")/../lib/common.sh"
```

For `120-install-i3.sh`, add guard:
```bash
if is_installed i3; then
    log_info "i3 already installed, skipping"
    exit 0
fi
```

For `140` and `150` (copy scripts), just add logging — these should always run to update configs.

**Step 2: Commit**

```bash
git add i3/
git commit -m "update i3 scripts with common.sh and guards"
```

---

## Task 13: Update remaining existing scripts (rofi, conky, fonts, chrome)

**Files:**
- Modify: `rofi/setup-rofi.sh`
- Modify: `conky/setup-conky.sh`
- Modify: `fonts/install-fonts.sh`
- Modify: `chrome/install-google-chrome.sh`

**Step 1: Add common.sh sourcing and logging to each**

Same pattern: add `set -e`, source `common.sh`, add `log_info` calls, add guards where appropriate.

For `chrome/install-google-chrome.sh` add:
```bash
if is_installed google-chrome; then
    log_info "Google Chrome already installed, skipping"
    exit 0
fi
```

**Step 2: Commit**

```bash
git add rofi/ conky/ fonts/ chrome/
git commit -m "update rofi, conky, fonts, chrome with common.sh and guards"
```

---

## Task 14: Update emacs/setup-emacs.sh

**Files:**
- Modify: `emacs/setup-emacs.sh`

**Step 1: Update the script**

Changes needed:
- Add `set -e`, source `common.sh`
- Add guard: `if is_installed emacs; then ... skip`
- Replace `gcc-10 g++-10 libgccjit-10-dev` with `gcc g++ libgccjit0-dev libgccjit-12-dev` (Mint 21 default)
- Remove `--no-check-certificate` from any wget calls
- Add `log_info` calls

Read the current script carefully before modifying — only change what's needed, keep the compilation flags intact.

**Step 2: Commit**

```bash
git add emacs/setup-emacs.sh
git commit -m "update emacs setup: fix gcc deps for Mint 21, fix wget security"
```

---

## Task 15: Update slack/setup-slack.sh

**Files:**
- Modify: `slack/setup-slack.sh`

**Step 1: Rewrite to use apt .deb**

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Slack..."

if is_installed slack; then
    log_info "Slack already installed, skipping"
    exit 0
fi

log_info "Downloading Slack..."
wget -O /tmp/slack.deb "https://downloads.slack-edge.com/desktop-releases/linux/x64/4.41.105/slack-desktop-4.41.105-amd64.deb"
sudo dpkg -i /tmp/slack.deb || sudo apt-get install -f -y
rm -f /tmp/slack.deb

log_info "Slack setup complete"
```

Note: check latest Slack .deb URL at implementation time. The version number will need to be current.

**Step 2: Commit**

```bash
git add slack/setup-slack.sh
git commit -m "switch slack install from snap to apt .deb"
```

---

## Task 16: Update vpn/setup_vpn.sh

**Files:**
- Modify: `vpn/setup_vpn.sh`

**Step 1: Rewrite to use NordVPN apt repo**

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up NordVPN..."

if is_installed nordvpn; then
    log_info "NordVPN already installed, skipping"
    exit 0
fi

log_info "Installing NordVPN via official repo..."
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)

log_info "NordVPN setup complete"
```

**Step 2: Commit**

```bash
git add vpn/setup_vpn.sh
git commit -m "update nordvpn to use official installer instead of hardcoded version"
```

---

## Task 17: Create python/setup-python.sh (NEW)

**Files:**
- Create: `python/setup-python.sh`

**Step 1: Write the script**

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Python..."

log_info "Installing python3-pip and python3-venv..."
sudo apt-get install -y python3-pip python3-venv

# Install pyenv if not present
if is_installed pyenv; then
    log_info "pyenv already installed, skipping"
else
    log_info "Installing pyenv..."
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev curl \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    curl https://pyenv.run | bash
fi

# Create default venv
if [ -d "$HOME/.venv/default" ]; then
    log_info "Default venv already exists, skipping"
else
    log_info "Creating default venv at ~/.venv/default..."
    mkdir -p "$HOME/.venv"
    python3 -m venv "$HOME/.venv/default"
fi

log_info "Python setup complete"
```

**Step 2: Commit**

```bash
git add python/
git commit -m "add python setup: pip, venv, pyenv, default virtualenv"
```

---

## Task 18: Create gh/setup-gh.sh (NEW)

**Files:**
- Create: `gh/setup-gh.sh`

**Step 1: Write the script**

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up GitHub CLI..."

if is_installed gh; then
    log_info "GitHub CLI already installed, skipping"
    exit 0
fi

log_info "Adding GitHub CLI apt repository..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt-get update
sudo apt-get install -y gh

log_info "GitHub CLI setup complete"
```

**Step 2: Commit**

```bash
git add gh/
git commit -m "add GitHub CLI (gh) setup"
```

---

## Task 19: Create claude-code/setup-claude-code.sh (NEW)

**Files:**
- Modify: `claude-code/setup-claude-code.sh` (create new script, directory already exists)

**Step 1: Write the script**

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up Claude Code..."

if is_installed claude; then
    log_info "Claude Code already installed, skipping"
    exit 0
fi

# Requires node/npm
if ! is_installed npm; then
    log_error "npm is required but not installed. Run node setup first."
    exit 1
fi

log_info "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

log_info "Claude Code setup complete"
```

**Step 2: Commit**

```bash
git add claude-code/setup-claude-code.sh
git commit -m "add Claude Code setup script"
```

---

## Task 20: Rewrite run.sh

**Files:**
- Modify: `run.sh`

**Step 1: Rewrite run.sh with orchestration pattern**

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/lib/common.sh"

export SETUP_LOGFILE="$HOME/.setup-desktop-$(date +%Y%m%d-%H%M%S).log"

TOTAL=22
N=0

run_step() {
    N=$((N + 1))
    echo ""
    echo "[$N/$TOTAL] $1"
    echo "[$N/$TOTAL] $1" >> "$SETUP_LOGFILE"
    bash "$SCRIPT_DIR/$2" 2>&1 | tee -a "$SETUP_LOGFILE"
}

echo "=========================================="
echo " setup-desktop"
echo " Log: $SETUP_LOGFILE"
echo "=========================================="

sudo apt-get update

run_step "Installing base applications..."       applications/install-applications.sh
run_step "Installing fonts..."                    fonts/install-fonts.sh
run_step "Setting up Python..."                   python/setup-python.sh
run_step "Setting up Node.js..."                  node/setup-node.sh
run_step "Setting up Java..."                     java/setup-java.sh
run_step "Setting up Rust..."                     rust/setup_rust.sh
run_step "Configuring Git..."                     git/setup-git.sh
run_step "Setting up SSH..."                      ssh/setup-ssh.sh
run_step "Setting up Docker..."                   docker/setup-docker.sh
run_step "Installing i3..."                       i3/120-install-i3.sh
run_step "Installing i3 extras..."                i3/130-install-extra-software-needed-on-i3.sh
run_step "Copying i3 config..."                   i3/140-copy-i3-files-to-config-i3-folder.sh
run_step "Copying wallpaper..."                   i3/150-copy-feh-background-folder.sh
run_step "Setting up Rofi..."                     rofi/setup-rofi.sh
run_step "Setting up Conky..."                    conky/setup-conky.sh
run_step "Setting up Bash..."                     bash/setup-bash.sh
run_step "Setting up Emacs..."                    emacs/setup-emacs.sh
run_step "Installing Chrome..."                   chrome/install-google-chrome.sh
run_step "Installing GitHub CLI..."               gh/setup-gh.sh
run_step "Installing Claude Code..."              claude-code/setup-claude-code.sh
run_step "Installing Slack..."                    slack/setup-slack.sh
run_step "Installing NordVPN..."                  vpn/setup_vpn.sh

echo ""
echo "=========================================="
echo " Setup complete! Log saved to:"
echo " $SETUP_LOGFILE"
echo "=========================================="
```

**Step 2: Commit**

```bash
git add run.sh
git commit -m "rewrite run.sh with progress tracking, logging, and updated component order"
```

---

## Task 21: Update applications/install-applications.sh

**Files:**
- Modify: `applications/install-applications.sh`

**Step 1: Add common.sh, logging, review package list**

Add `set -e`, source `common.sh`, wrap with `log_info`. Review the package list against what's on the reference machine — keep useful packages, remove any that are clearly obsolete. Add `keepassxc` (replaces flatpak install).

**Step 2: Commit**

```bash
git add applications/install-applications.sh
git commit -m "update applications list with common.sh and reviewed packages"
```

---

## Task 22: Update ledger_live/setup-ledger-live.sh

**Files:**
- Modify: `ledger_live/setup-ledger-live.sh`

**Step 1: Add common.sh and guards**

Add `set -e`, source `common.sh`, add `log_info` calls, add guard checking if ledger-live binary already exists.

**Step 2: Commit**

```bash
git add ledger_live/
git commit -m "update ledger live setup with common.sh and guards"
```

---

## Task 23: Final review and cleanup

**Step 1: Verify all scripts source common.sh and config.sh correctly**

Run through each script and verify:
- `set -e` is present
- `source common.sh` path is correct
- `log_info` calls are present
- Guards work (check for already-installed)

**Step 2: Verify run.sh TOTAL count matches actual steps**

**Step 3: Update CLAUDE.md to reflect new architecture**

Update the project documentation to reflect:
- New `config.sh` and `lib/common.sh`
- `~/.bashrc.d/` architecture
- Removed components
- New components (python, gh, claude-code)

**Step 4: Commit**

```bash
git add -A
git commit -m "final cleanup: verify all scripts, update CLAUDE.md"
```
