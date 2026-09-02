#!/bin/bash
#
# generate-wallpaper.sh — render a keyboard-shortcut cheat-sheet wallpaper.
#
#   macos/wallpaper/generate-wallpaper.sh [WIDTHxHEIGHT ...]
#
# Defaults to the three common MacBook Retina sizes. Output goes to
# macos/wallpaper/out/.
#
# Content comes from shortcuts.tsv. Every AeroSpace chord listed there is
# cross-checked against the rendered ~/.aerospace.toml keymap, in both
# directions — an undocumented binding or a documented non-binding is an error.
# That is what stops the wallpaper drifting away from the actual config.

set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/out"
TSV="$HERE/shortcuts.tsv"
mkdir -p "$OUT"

SIZES=("$@")
[ ${#SIZES[@]} -eq 0 ] && SIZES=(3456x2234 3024x1964 2880x1800)

# --- browser ----------------------------------------------------------------
BROWSER=""
for b in chromium chromium-browser google-chrome google-chrome-stable; do
    command -v "$b" >/dev/null 2>&1 && { BROWSER="$b"; break; }
done
[ -z "$BROWSER" ] && { log_error "Need chromium or google-chrome to render."; exit 1; }

# --- build the keymap this wallpaper documents -------------------------------
KEYMAP="$OUT/.keymap.toml"
render_bindings() {
    sed -e "s|@MOD_SHIFT@|${1}-shift|g" -e "s|@MOD@|${1}|g" \
        "$HERE/../aerospace/aerospace.bindings.toml.template"
}
{
    render_bindings "$SETUP_MOD"
    [ -n "${SETUP_MOD_FALLBACK:-}" ] && [ "$SETUP_MOD_FALLBACK" != "$SETUP_MOD" ] \
        && render_bindings "$SETUP_MOD_FALLBACK"
    cat "$HERE/../aerospace/aerospace.tail.toml.template"
} > "$KEYMAP"

# --- cross-check -------------------------------------------------------------
# Bindings actually in the keymap (main mode only; resize mode is a submode and
# is described on the wallpaper as prose rather than per-key).
awk '/^\[mode\.resize/{exit} /^[a-z0-9-]+[[:space:]]*=/{k=$0;sub(/[[:space:]]*=.*/,"",k);print k}' \
    "$KEYMAP" | sort -u > "$OUT/.in-config"

# Chords documented on the wallpaper.
awk -F'\t' '!/^#/ && NF==3 && $1!="EMACS" && $1!="EMACS-MAC" {print $2}' "$TSV" \
    | sort -u > "$OUT/.in-sheet"

missing="$(comm -13 "$OUT/.in-config" "$OUT/.in-sheet")"
undocumented="$(comm -23 "$OUT/.in-config" "$OUT/.in-sheet")"

if [ -n "$missing" ]; then
    log_error "shortcuts.tsv lists chords that are NOT in the keymap:"
    printf '%s\n' "$missing" | sed 's/^/    /'
    exit 1
fi
if [ -n "$undocumented" ]; then
    log_error "keymap has bindings missing from shortcuts.tsv:"
    printf '%s\n' "$undocumented" | sed 's/^/    /'
    exit 1
fi
log_info "Cross-check passed: $(wc -l < "$OUT/.in-sheet" | tr -d ' ') chords match the keymap"

# --- html --------------------------------------------------------------------
HTML="$OUT/wallpaper.html"
python3 "$HERE/render.py" "$TSV" "$HTML" "$SETUP_MOD"

# --- screenshot --------------------------------------------------------------
for size in "${SIZES[@]}"; do
    w="${size%x*}"; h="${size#*x}"
    png="$OUT/cheatsheet-${size}.png"
    "$BROWSER" --headless --disable-gpu --hide-scrollbars \
        --force-device-scale-factor=1 \
        --screenshot="$png" --window-size="${w},${h}" \
        --default-background-color=00000000 \
        "file://$HTML" >/dev/null 2>&1
    if [ -f "$png" ]; then
        log_info "Rendered $png"
    else
        log_error "Failed to render $size"
    fi
done

rm -f "$OUT/.in-config" "$OUT/.in-sheet" "$KEYMAP"

log_info "Set one as the wallpaper:"
log_info "  System Settings → Wallpaper → Add Photo, or:"
log_info "  osascript -e 'tell application \"System Events\" to set picture of every desktop to \"<path>\"'"
