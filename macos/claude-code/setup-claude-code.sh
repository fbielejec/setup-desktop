#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Claude Code..."

if ! is_installed npm; then
    log_error "npm is required but not installed. Run node setup first."
    exit 1
fi

if ! is_installed claude; then
    log_info "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
fi

if ! is_installed jq; then
    log_error "jq is required to build the settings file. Run the Brewfile step first."
    exit 1
fi

SHARED="$REPO_DIR/claude-code/settings.json"
BUILT="${TMPDIR:-/tmp}/claude-settings-macos.json"

# The shared settings file contains a // comment, which Claude Code tolerates
# but jq does not. Strip comment-only lines — matching on the first non-blank
# character rather than on "//" anywhere, so the metadata-endpoint URLs in the
# deny list survive.
sed '/^[[:space:]]*\/\//d' "$SHARED" > "${BUILT}.stripped"

# The only platform-specific part is the notification hook: paplay and dunstify
# do not exist here. Everything else — the whole deny list — is shared, so it
# is rewritten rather than duplicated.
HOOK_FILE="${TMPDIR:-/tmp}/claude-mac-hook.txt"
cat > "$HOOK_FILE" <<'HOOK'
NAME=$(jq -r '.name // empty' $HOME/.claude/sessions/$PPID.json 2>/dev/null); LABEL=${NAME:-$(basename $(pwd))}; afplay /System/Library/Sounds/Glass.aiff & terminal-notifier -title 'Claude Code' -subtitle "$LABEL" -message 'Needs your attention'
HOOK

jq --arg cmd "$(cat "$HOOK_FILE")" \
   '.hooks.Notification[0].hooks[0].command = $cmd' \
   "${BUILT}.stripped" > "$BUILT"

mkdir -p "$HOME/.claude"

if [ -f "$HOME/.claude/settings.json" ]; then
    jq -s '.[0] * .[1]' "$HOME/.claude/settings.json" "$BUILT" > "$HOME/.claude/settings.json.tmp"
    mv "$HOME/.claude/settings.json.tmp" "$HOME/.claude/settings.json"
    log_info "Merged Claude Code settings into ~/.claude/settings.json"
else
    cp "$BUILT" "$HOME/.claude/settings.json"
    log_info "Wrote ~/.claude/settings.json"
fi

rm -f "${BUILT}.stripped" "$HOOK_FILE"

if ! is_installed terminal-notifier; then
    log_error "terminal-notifier missing — notifications will fail silently."
    log_error "Install it with: brew install terminal-notifier"
fi

log_info "Claude Code setup complete"
