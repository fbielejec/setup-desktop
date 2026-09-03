#!/bin/bash
# macos/run.sh — orchestrator for the macOS setup.
#
# Mirrors the shape of the root run.sh, with one difference: steps are gated on
# what 00-probe.sh found the machine will permit. A locked-down machine gets a
# working toolchain and skips the window-manager tier rather than failing.
#
# Usage:
#   macos/00-probe.sh          # first, always
#   macos/run.sh               # everything the machine permits
#   macos/run.sh --dry-run     # print the plan, change nothing

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/lib/common.sh"

export SETUP_LOGFILE="$HOME/.setup-macos-$(date +%Y%m%d-%H%M%S).log"

DRY_RUN=false
[ "${1:-}" = "--dry-run" ] && DRY_RUN=true

N=0
RAN=0
SKIPPED=0
MISSING=0

# run_step LABEL SCRIPT [GATE]
# GATE: "true"/"false" — false skips the step with a logged reason.
run_step() {
    local label="$1"
    local script="$2"
    local gate="${3:-true}"
    N=$((N + 1))

    if [ "$gate" != "true" ]; then
        log_skip "[$N] $label — gated off"
        SKIPPED=$((SKIPPED + 1))
        return 0
    fi

    if [ ! -f "$SCRIPT_DIR/$script" ]; then
        log_skip "[$N] $label — $script not written yet"
        MISSING=$((MISSING + 1))
        return 0
    fi

    RAN=$((RAN + 1))

    echo ""
    echo "[$N] $label"
    echo "[$N] $label" >> "$SETUP_LOGFILE"

    if [ "$DRY_RUN" = true ]; then
        echo "     (dry run — would execute $script)"
        return 0
    fi

    bash "$SCRIPT_DIR/$script" 2>&1 | tee -a "$SETUP_LOGFILE"
}

echo "=========================================="
echo " setup-desktop — macOS"
echo " Log: $SETUP_LOGFILE"
[ "$DRY_RUN" = true ] && echo " DRY RUN — nothing will be changed"
echo "=========================================="

# --------------------------------------------------------------- preflight --

require_probe

AX="$(probe_value AX_GRANTED unknown)"
SYSEXT="$(probe_value SYSEXT_ALLOWED unknown)"
HOMEBREW="$(probe_value HOMEBREW unknown)"

# The probe overrides config.sh rather than the other way round: the machine
# gets the final say on what is possible.
if [ "$AX" != "true" ]; then
    SETUP_ENABLE_WM=false
fi
if [ "$SYSEXT" != "likely" ]; then
    SETUP_ENABLE_KARABINER=false
fi
# ctrl-alt-cmd has two possible sources: the QMK keyboard's firmware, or
# Karabiner. Only fall back when neither is available — the QMK route is
# independent of anything MDM controls, so a blocked system extension no
# longer forces the fallback.
if [ "$SETUP_MOD" = "ctrl-alt-cmd" ] \
   && [ "$SETUP_QMK_HYPER" != "true" ] \
   && [ "$SETUP_ENABLE_KARABINER" != "true" ]; then
    log_error "SETUP_MOD is ctrl-alt-cmd but nothing can produce it:"
    log_error "  SETUP_QMK_HYPER=false and SETUP_ENABLE_KARABINER=false."
    log_error "Falling back to alt-cmd for this run. Update macos/config.sh to make it stick."
    SETUP_MOD="alt-cmd"
    SETUP_MOD_FALLBACK=""
fi

# All three must be exported: each component script re-sources config.sh, which
# now defers to these (see the :- assignments there). Without the export the
# probe's verdict never reaches the scripts it is supposed to gate.
export SETUP_MOD SETUP_MOD_FALLBACK SETUP_QMK_HYPER
export SETUP_ENABLE_WM SETUP_ENABLE_KARABINER SETUP_ENABLE_SSHD SETUP_INSTALL_QMK

if [ -z "$SETUP_USER_EMAIL" ]; then
    log_error "SETUP_USER_EMAIL is empty in macos/config.sh."
    log_error "Set your work email before running — this guard exists so a work"
    log_error "machine cannot end up committing under the personal address."
    exit 1
fi

echo ""
echo "  Modifier:        $SETUP_MOD${SETUP_MOD_FALLBACK:+ (+ $SETUP_MOD_FALLBACK on the built-in keyboard)}"
echo "  QMK Hyper:       $SETUP_QMK_HYPER"
echo "  Window manager:  $SETUP_ENABLE_WM   (probe: AX_GRANTED=$AX)"
echo "  Karabiner:       $SETUP_ENABLE_KARABINER   (probe: SYSEXT_ALLOWED=$SYSEXT)"
echo "  Homebrew:        $HOMEBREW"

# ------------------------------------------------------- tier 1: toolchain --

run_step "Installing Homebrew..."              brew/setup-brew.sh
run_step "Installing packages (Brewfile)..."   brew/install-packages.sh
run_step "Setting up bash..."                  bash/setup-bash.sh
run_step "Setting up Git..."                   git/setup-git.sh
run_step "Setting up SSH (client)..."          ssh/setup-ssh.sh
run_step "Enabling SSH server..."              ssh/setup-sshd.sh "$SETUP_ENABLE_SSHD"
run_step "Setting up Node.js..."               node/setup-node.sh
run_step "Setting up Rust..."                  rust/setup-rust.sh
run_step "Setting up Python..."                python/setup-python.sh
run_step "Setting up Java..."                  java/setup-java.sh
run_step "Setting up containers (colima)..."   docker/setup-colima.sh
run_step "Setting up Emacs..."                 emacs/setup-emacs.sh
run_step "Setting up Alacritty..."             alacritty/setup-alacritty.sh
run_step "Installing fonts..."                 fonts/install-fonts.sh
run_step "Installing GitHub CLI..."            gh/setup-gh.sh
run_step "Installing Claude Code..."           claude-code/setup-claude-code.sh
run_step "Setting up local coding harness..."  local-harness/setup-local-harness.sh

# --------------------------------------------------- tier 2: macOS defaults --

run_step "Applying macOS defaults..."          defaults/setup-defaults.sh

# ----------------------------------------------- tier 3: window manager -----

run_step "Setting up AeroSpace..."             aerospace/setup-aerospace.sh  "$SETUP_ENABLE_WM"
run_step "Setting up SketchyBar..."            sketchybar/setup-sketchybar.sh "$SETUP_ENABLE_WM"
run_step "Setting up JankyBorders..."          borders/setup-borders.sh       "$SETUP_ENABLE_WM"
run_step "Setting up Alfred..."                alfred/setup-alfred.sh         "$SETUP_ENABLE_WM"

# ---------------------------------------------------- tier 4: karabiner -----

run_step "Setting up QMK toolchain..."         qmk/setup-qmk.sh               "$SETUP_INSTALL_QMK"

# Only needed if the QMK keyboard is NOT the source of the Hyper chord.
run_step "Setting up Karabiner..."             karabiner/setup-karabiner.sh   "$SETUP_ENABLE_KARABINER"

# ------------------------------------------------------------------ done ----

echo ""
echo "=========================================="
echo " Done. $RAN of $N steps ran, $SKIPPED gated off, $MISSING not yet written."
echo " Log: $SETUP_LOGFILE"
if [ "$SETUP_ENABLE_WM" != "true" ]; then
    echo ""
    echo " Window manager tier was skipped. To enable it:"
    echo "   1. System Settings → Privacy & Security → Accessibility"
    echo "   2. Grant the permission to your terminal"
    echo "   3. Re-run macos/00-probe.sh, then this script"
fi
echo "=========================================="
