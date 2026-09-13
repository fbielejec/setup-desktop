#!/bin/bash
#
# generate-wallpaper.sh — render a keyboard-shortcut cheat-sheet wallpaper.
#
#   i3/wallpaper/generate-wallpaper.sh [WIDTHxHEIGHT ...]
#
# Defaults to the largest mode xrandr reports as active, else 1920x1080.
# Output goes to i3/wallpaper/out/cheatsheet-<size>.png.
#
# Content comes from shortcuts.tsv. Every default-mode bindsym in
# i3/config/config is cross-checked against it, in both directions — an
# undocumented binding or a documented non-binding is an error. That is what
# stops the wallpaper drifting away from the actual config.
#
# Linux sibling of macos/wallpaper/generate-wallpaper.sh. Deliberately a copy,
# not a shared script: the keymap source, chord notation and layout all differ.

set -e
source "$(dirname "$0")/../../lib/common.sh"

HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/out"
TSV="$HERE/shortcuts.tsv"
I3_CONFIG="$HERE/../config/config"
mkdir -p "$OUT"

SIZES=("$@")
if [ ${#SIZES[@]} -eq 0 ]; then
    # Largest active mode: feh --bg-scale puts the same image on every output,
    # and downscaling text reads far better than upscaling it.
    size="$(xrandr --current 2>/dev/null \
        | awk '$2 ~ /\*/ {split($1, d, "x"); if (d[1] * d[2] > best) {best = d[1] * d[2]; s = $1}} END {print s}')"
    SIZES=("${size:-1920x1080}")
fi

# --- cross-check -------------------------------------------------------------
# One normaliser for both sides, so the TSV may spell a chord any way i3
# accepts: $mod+Shift+Left, Mod4+shift+left and Shift+Super+Left are one chord.
NORMALISE='
function norm(chord,    n, p, i, t, m, key, out) {
    n = split(chord, p, "+")
    for (i = 1; i <= n; i++) {
        t = tolower(p[i])
        if (t == "$mod") t = tolower(MOD)
        if (t == "mod4" || t == "super") m["super"] = 1
        else if (t == "mod1" || t == "alt") m["alt"] = 1
        else if (t == "ctrl" || t == "control") m["ctrl"] = 1
        else if (t == "shift") m["shift"] = 1
        else key = t
    }
    out = ""
    if (m["ctrl"])  out = out "ctrl+"
    if (m["alt"])   out = out "alt+"
    if (m["shift"]) out = out "shift+"
    if (m["super"]) out = out "super+"
    return out key
}'

MOD="$(awk '$1 == "set" && $2 == "$mod" {print $3; exit}' "$I3_CONFIG")"
[ -z "$MOD" ] && { log_error "No 'set \$mod' in $I3_CONFIG"; exit 1; }

# Bindings actually in the config — default mode only. Submodes (resize,
# system) are entered by a default-mode chord and described in the footer.
awk -v MOD="$MOD" "$NORMALISE"'
    /^[[:space:]]*mode[[:space:]].*\{[[:space:]]*$/ { inmode = 1; next }
    inmode && /^[[:space:]]*\}/                      { inmode = 0; next }
    !inmode && $1 == "bindsym" {
        i = 2
        while ($i ~ /^--/) i++
        print norm($i)
    }' "$I3_CONFIG" | sort -u > "$OUT/.in-config"

# Chords documented on the wallpaper.
awk -F'\t' -v MOD="$MOD" "$NORMALISE"'
    !/^#/ && NF == 3 && $1 !~ /^EMACS/ { print norm($2) }' "$TSV" \
    | sort -u > "$OUT/.in-sheet"

missing="$(comm -13 "$OUT/.in-config" "$OUT/.in-sheet")"
undocumented="$(comm -23 "$OUT/.in-config" "$OUT/.in-sheet")"
rm -f "$OUT/.in-config" "$OUT/.in-sheet"

if [ -n "$missing" ]; then
    log_error "shortcuts.tsv lists chords that are NOT bound in i3/config/config:"
    printf '%s\n' "$missing" | sed 's/^/    /'
    exit 1
fi
if [ -n "$undocumented" ]; then
    log_error "i3/config/config has bindings missing from shortcuts.tsv:"
    printf '%s\n' "$undocumented" | sed 's/^/    /'
    exit 1
fi
log_info "Cross-check passed: every i3 binding is on the wallpaper"

# --- browser ----------------------------------------------------------------
# Checked after the cross-check, so a stale shortcuts.tsv fails even on a
# machine that cannot render. Exit 3 = "no renderer", which
# 150-install-wallpaper.sh treats as "fall back to the static image".
BROWSER=""
for b in google-chrome google-chrome-stable chromium chromium-browser; do
    command -v "$b" >/dev/null 2>&1 && { BROWSER="$b"; break; }
done
[ -z "$BROWSER" ] && { log_error "Need google-chrome or chromium to render."; exit 3; }

# --- html --------------------------------------------------------------------
HTML="$OUT/wallpaper.html"
python3 "$HERE/render.py" "$TSV" "$HTML" "$MOD"

# --- screenshot --------------------------------------------------------------
for size in "${SIZES[@]}"; do
    w="${size%x*}"; h="${size#*x}"
    png="$OUT/cheatsheet-${size}.png"
    rm -f "$png"
    "$BROWSER" --headless --disable-gpu --hide-scrollbars \
        --force-device-scale-factor=1 \
        --screenshot="$png" --window-size="${w},${h}" \
        "file://$HTML" >/dev/null 2>&1 || true
    if [ -f "$png" ]; then
        log_info "Rendered $png"
    else
        log_error "Failed to render $size"
        exit 1
    fi
done
