#!/bin/bash
#
# 00-probe.sh — report what this Mac will actually permit, before installing anything.
#
# Run this FIRST, on day one, before requesting software or running any setup.
# It answers the questions that gate the rest of macos/: local admin, MDM
# enrollment, system-extension policy, and whether Accessibility is grantable.
#
# Deliberately standalone: no sourcing, no dependencies, no repo required.
# You can paste this whole file into a fresh terminal. Written for bash 3.2,
# which is what macOS ships — no associative arrays, no ${var,,}.
#
# Read-only. Installs nothing, changes nothing, needs no sudo.

set -u

# Not under $TMPDIR — macOS purges that after a few days, and run.sh refuses
# to start without this file.
RESULTS="${PROBE_RESULTS:-$HOME/.setup-macos-probe}"
: > "$RESULTS"

pass=0
warn=0
fail=0

section() {
    printf '\n\033[1m== %s\033[0m\n' "$1"
}

# record KEY VALUE — machine-readable, for run.sh to consume
record() {
    printf '%s=%s\n' "$1" "$2" >> "$RESULTS"
}

# report STATUS LABEL DETAIL
report() {
    _status="$1"; _label="$2"; _detail="$3"
    case "$_status" in
        ok)   printf '  \033[32m✓\033[0m  %-28s %s\n' "$_label" "$_detail"; pass=$((pass+1)) ;;
        warn) printf '  \033[33m!\033[0m  %-28s %s\n' "$_label" "$_detail"; warn=$((warn+1)) ;;
        no)   printf '  \033[31m✗\033[0m  %-28s %s\n' "$_label" "$_detail"; fail=$((fail+1)) ;;
        *)    printf '     %-28s %s\n' "$_label" "$_detail" ;;
    esac
}

printf '\033[1msetup-desktop capability probe\033[0m\n'
printf 'Host: %s   Date: %s\n' "$(hostname -s)" "$(date '+%Y-%m-%d %H:%M')"

# ---------------------------------------------------------------- system ----
section "System"

os_version="$(sw_vers -productVersion 2>/dev/null || echo unknown)"
arch="$(uname -m)"
report info "macOS version" "$os_version"
report info "Architecture" "$arch"
record OS_VERSION "$os_version"
record ARCH "$arch"

if [ "$arch" = "arm64" ]; then
    brew_prefix="/opt/homebrew"
else
    brew_prefix="/usr/local"
fi
record BREW_PREFIX "$brew_prefix"

# ----------------------------------------------------------------- admin ----
section "Privileges"

if id -Gn 2>/dev/null | tr ' ' '\n' | grep -qx admin; then
    report ok "Local admin" "yes — in the 'admin' group"
    record IS_ADMIN true
else
    report no "Local admin" "no — expect approval workflows for most installs"
    record IS_ADMIN false
fi

# Non-interactive sudo check. A password prompt means sudo works but is gated;
# we never actually prompt, so this stays safe to run unattended.
if sudo -n true 2>/dev/null; then
    report ok "sudo" "available without password (cached or NOPASSWD)"
    record HAS_SUDO true
elif sudo -n true 2>&1 | grep -q 'password is required'; then
    report ok "sudo" "available, password required"
    record HAS_SUDO true
else
    report no "sudo" "not available to this user"
    record HAS_SUDO false
fi

if [ -w /Applications ]; then
    report ok "/Applications writable" "yes — casks can install"
else
    report warn "/Applications writable" "no — casks will need sudo or admin"
fi

# ------------------------------------------------------------------- MDM ----
section "Management"

enrollment="$(profiles status -type enrollment 2>/dev/null || echo unavailable)"
if printf '%s' "$enrollment" | grep -qi 'MDM enrollment: Yes'; then
    if printf '%s' "$enrollment" | grep -qi 'User Approved'; then
        report warn "MDM enrollment" "enrolled, user-approved (full management)"
        record MDM user_approved
    else
        report warn "MDM enrollment" "enrolled"
        record MDM enrolled
    fi
else
    report ok "MDM enrollment" "not enrolled"
    record MDM none
fi

managed_count=0
if [ -d "/Library/Managed Preferences" ]; then
    managed_count=$(find "/Library/Managed Preferences" -name '*.plist' 2>/dev/null | wc -l | tr -d ' ')
fi
if [ "$managed_count" -gt 0 ]; then
    report warn "Managed preferences" "$managed_count policy payload(s) applied"
    record MANAGED_PREFS "$managed_count"
    # Captured first: a `|| fallback` after a pipeline tests only the LAST
    # command's status, and the trailing sed always succeeds.
    relevant="$(find "/Library/Managed Preferences" -name '*.plist' 2>/dev/null \
        | sed 's|.*/||; s|\.plist$||' \
        | grep -iE 'TCC|accessibility|systemextension|security|dock|spaces|keyboard|finder')"
    printf '     Payloads that may affect this setup:\n'
    if [ -n "$relevant" ]; then
        printf '%s\n' "$relevant" | sed 's/^/       - /'
    else
        printf '       (none matching)\n'
    fi
else
    report ok "Managed preferences" "none"
    record MANAGED_PREFS 0
fi

# Known management / endpoint agents. Informational only — their presence does
# not block anything, but it tells you who to expect a conversation with.
agents=""
[ -d "/Applications/Falcon.app" ] && agents="$agents CrowdStrike"
[ -d "/Applications/SentinelOne" ] && agents="$agents SentinelOne"
[ -d "/Library/Application Support/JAMF" ] && agents="$agents Jamf"
[ -d "/Library/Kandji" ] && agents="$agents Kandji"
[ -d "/Applications/Company Portal.app" ] && agents="$agents Intune"
if [ -n "$agents" ]; then
    report info "Management agents" "$(printf '%s' "$agents" | sed 's/^ //')"
    record AGENTS "$(printf '%s' "$agents" | sed 's/^ //; s/ /,/g')"
else
    report info "Management agents" "none detected"
fi

# ---------------------------------------------------------------- security --
section "Security posture"

# Same pipeline caveat as above — test the captured value, not the pipeline.
sip="$(csrutil status 2>/dev/null | sed 's/.*status: //; s/\.$//')"
[ -n "$sip" ] || sip="unknown"
report info "SIP" "$sip (AeroSpace does not require disabling this)"
record SIP "$sip"

gatekeeper="$(spctl --status 2>/dev/null | sed 's/assessments //')"
[ -n "$gatekeeper" ] || gatekeeper="unknown"
report info "Gatekeeper" "$gatekeeper"
record GATEKEEPER "$gatekeeper"

# -------------------------------------------------------- system extensions --
section "System extensions (gates Karabiner-Elements)"

if sysext="$(systemextensionsctl list 2>/dev/null)"; then
    # Match the per-extension state marker, not the word "enabled" — that also
    # appears in the column header printed for each category.
    ext_count=$(printf '%s' "$sysext" | grep -c '\[activated enabled\]' || true)
    if [ "$ext_count" -gt 0 ]; then
        report ok "Existing extensions" "$ext_count enabled — extensions are permitted here"
        record SYSEXT_ALLOWED likely
    else
        report warn "Existing extensions" "none installed — permission unproven either way"
        record SYSEXT_ALLOWED unknown
    fi
else
    report warn "Existing extensions" "could not query"
    record SYSEXT_ALLOWED unknown
fi

if [ -f "/Library/Managed Preferences/com.apple.system-extension-policy.plist" ]; then
    report warn "Extension policy" "MDM policy present — allowlist likely enforced"
    record SYSEXT_POLICY managed
else
    report ok "Extension policy" "no MDM allowlist payload found"
    record SYSEXT_POLICY none
fi

# ----------------------------------------------------------- accessibility --
section "Accessibility (gates AeroSpace, SketchyBar, JankyBorders, Alfred)"

# Functional test: this AppleScript needs the Accessibility permission for
# whichever app is running this shell. Error -1743 means not granted yet.
# Branch on osascript's exit status, not on whether it produced output. Any
# error message is non-empty output, so testing for content would report
# "granted" for unrelated failures — and run.sh would then enable the whole
# window-manager tier on a machine that cannot run it.
if ax_out="$(osascript -e 'tell application "System Events" to return name of first process' 2>&1)"; then
    report ok "Terminal has Accessibility" "granted — permission is user-grantable here"
    record AX_GRANTED true
elif printf '%s' "$ax_out" | grep -q '1743'; then
    report warn "Terminal has Accessibility" "not granted yet — this is expected on a fresh machine"
    record AX_GRANTED false
    printf '     Next: System Settings → Privacy & Security → Accessibility.\n'
    printf '     If the toggle is greyed out or the list is locked, it is MDM-enforced\n'
    printf '     and the window-manager half of this plan cannot proceed.\n'
else
    report warn "Terminal has Accessibility" "inconclusive: $ax_out"
    record AX_GRANTED unknown
fi

if [ -f "/Library/Managed Preferences/com.apple.TCC.configuration-profile-policy.plist" ]; then
    report warn "TCC policy (PPPC)" "MDM controls privacy permissions"
    record TCC_POLICY managed
else
    report ok "TCC policy (PPPC)" "no MDM privacy payload found"
    record TCC_POLICY none
fi

# --------------------------------------------------------------- toolchain --
section "Existing toolchain"

if command -v brew >/dev/null 2>&1; then
    report ok "Homebrew" "$(brew --version 2>/dev/null | head -1)"
    record HOMEBREW installed
elif [ -w "$(dirname "$brew_prefix")" ] || [ -w "$brew_prefix" ]; then
    report ok "Homebrew" "not installed; $brew_prefix is writable"
    record HOMEBREW installable
else
    report warn "Homebrew" "not installed; $brew_prefix not writable — needs admin or a user prefix"
    record HOMEBREW needs_admin
fi

if xcode-select -p >/dev/null 2>&1; then
    report ok "Xcode CLT" "$(xcode-select -p)"
    record XCODE_CLT true
else
    report warn "Xcode CLT" "missing — run: xcode-select --install"
    record XCODE_CLT false
fi

# ${SHELL:-} because `set -u` would abort the whole probe if it is unset.
report info "Default shell" "${SHELL:-unknown}"
report info "bash version" "${BASH_VERSION:-unknown} (system bash is 3.2; brew install bash)"
record SHELL_PATH "${SHELL:-unknown}"

for t in git tmux emacs python3 node; do
    if command -v "$t" >/dev/null 2>&1; then
        report ok "$t" "$(command -v $t)"
    else
        report info "$t" "not present"
    fi
done

# ------------------------------------------------------------------ spaces --
section "Window manager prerequisites"

spans="$(defaults read com.apple.spaces spans-displays 2>/dev/null || echo 0)"
if [ "$spans" = "1" ]; then
    report ok "Displays span Spaces" "already set — AeroSpace multi-monitor will work"
else
    report warn "Displays span Spaces" "off — must set before AeroSpace multi-monitor works"
fi
record SPANS_DISPLAYS "$spans"

# ------------------------------------------------------------------ verdict --
section "Verdict"

printf '  %d ok, %d warnings, %d blocked\n\n' "$pass" "$warn" "$fail"

ax="$(grep '^AX_GRANTED=' "$RESULTS" | cut -d= -f2)"
sysext="$(grep '^SYSEXT_ALLOWED=' "$RESULTS" | cut -d= -f2)"

printf '  Toolchain half (brew, emacs, alacritty, tmux, dotfiles): '
if grep -q '^HOMEBREW=needs_admin' "$RESULTS"; then
    printf 'needs admin first\n'
else
    printf 'proceed\n'
fi

printf '  Window manager half (aerospace, sketchybar, borders):    '
case "$ax" in
    true)  printf 'proceed\n' ;;
    false) printf 'grant Accessibility, then re-run this probe\n' ;;
    *)     printf 'unknown — check System Settings manually\n' ;;
esac

printf '  Caps Lock as Hyper (karabiner):                          '
case "$sysext" in
    likely) printf 'likely permitted — try it\n' ;;
    *)      printf 'unproven — use the alt-cmd fallback for now\n' ;;
esac

printf '\n  Results written to: %s\n' "$RESULTS"
printf '  Set SETUP_MOD in macos/config.sh based on the last line above.\n\n'
