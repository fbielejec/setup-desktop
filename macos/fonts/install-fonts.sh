#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Installing fonts..."

# The .ttf files in fonts/ are platform-neutral — only the destination differs
# (~/Library/Fonts rather than ~/.fonts), so the repo's font collection is
# reused directly instead of being duplicated as brew casks.
DEST="$HOME/Library/Fonts"
mkdir -p "$DEST"

count=0
for f in "$REPO_DIR"/fonts/*.ttf "$REPO_DIR"/fonts/*.otf; do
    [ -f "$f" ] || continue
    cp "$f" "$DEST/"
    count=$((count + 1))
done
log_info "Copied $count font file(s) to $DEST"

# SketchyBar needs a Nerd Font for its glyphs and none of the repo's fonts
# carry them, so this one comes from brew.
if is_installed brew && ! is_cask_installed font-hack-nerd-font; then
    brew install --cask font-hack-nerd-font
fi

log_info "Font installation complete"
