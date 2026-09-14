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

# Native pixel size of the main display, e.g. "3024x1964". system_profiler
# prints "Resolution:" before "Main Display: Yes" within each display block.
MAIN_SIZE="$(system_profiler SPDisplaysDataType 2>/dev/null | awk '
    /Resolution:/     { r = $2 "x" $4 }
    /Main Display: Yes/ { print r; exit }')"
if [ -n "$MAIN_SIZE" ]; then
    case " ${SIZES[*]} " in
        *" $MAIN_SIZE "*) ;;
        *) SIZES+=("$MAIN_SIZE") ;;
    esac
fi

# --- browser ----------------------------------------------------------------
BROWSER=""
for b in chromium chromium-browser google-chrome google-chrome-stable; do
    command -v "$b" >/dev/null 2>&1 && { BROWSER="$b"; break; }
done
# Chrome comes from Jamf as an app bundle, which puts nothing on PATH.
if [ -z "$BROWSER" ]; then
    for b in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
             "$HOME/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; do
        [ -x "$b" ] && { BROWSER="$b"; break; }
    done
fi
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

# --- set ---------------------------------------------------------------------
# Copied out of the repo so the wallpaper survives the checkout moving, the way
# the Linux side keeps ~/.fehbg.png. The name carries a content hash because
# macOS caches the wallpaper by path: re-setting the same path after a rebuild
# keeps showing the old image.
SRC="$OUT/cheatsheet-${MAIN_SIZE}.png"
if [ -z "$MAIN_SIZE" ] || [ ! -f "$SRC" ]; then
    log_error "Could not detect the main display size; set one of the PNGs above by hand"
    exit 0
fi

DEST_DIR="$HOME/.wallpaper"
mkdir -p "$DEST_DIR"
DEST="$DEST_DIR/cheatsheet-$(shasum "$SRC" | cut -c1-12).png"
if [ ! -f "$DEST" ]; then
    rm -f "$DEST_DIR"/cheatsheet-*.png
    cp "$SRC" "$DEST"
fi

# Needs the Automation permission (terminal → System Events), not
# Accessibility; macOS prompts for it on first use. Jamf can pin the wallpaper
# with a profile, in which case this succeeds and is silently reverted.
if osascript -e "tell application \"System Events\" to set picture of every desktop to POSIX file \"$DEST\"" >/dev/null; then
    log_info "Wallpaper set: $DEST"
else
    log_error "Could not set the wallpaper (Automation permission denied?)"
    log_error "  System Settings → Wallpaper → Add Photo → $DEST"
fi
