#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
log_info "Copying i3 config files..."

# Move an existing config aside rather than deleting it. The clean-slate intent
# is kept — stale files really do go away — but a hand-tuned config that predates
# this repo is recoverable. Only fires when the content actually differs, so
# re-running does not litter the home directory with identical copies.
if [ -d "$HOME/.config/i3" ] && [ -n "$(ls -A "$HOME/.config/i3" 2>/dev/null)" ]; then
	# Compare entry by entry over the same glob the copy below uses, rather than
	# `diff -rq` on the whole directory. The glob skips dotfiles, so a whole-tree
	# diff would report a permanent difference for anything hidden in config/
	# and this guard would never fire.
	current=true
	for f in "$SCRIPT_DIR"/config/*; do
		[ -e "$f" ] || continue
		if ! diff -rq "$f" "$HOME/.config/i3/$(basename "$f")" >/dev/null 2>&1; then
			current=false
			break
		fi
	done
	if [ "$current" = true ]; then
		log_info "i3 config already current, skipping"
		exit 0
	fi
	backup="$HOME/.config/i3.bak-$(date +%Y%m%d-%H%M%S)"
	# Two runs inside the same second would otherwise `mv` the directory *into*
	# the existing backup rather than alongside it.
	[ -e "$backup" ] && backup="$backup-$$"
	mv "$HOME/.config/i3" "$backup"
	log_info "Backed up existing i3 config to $backup"
fi

mkdir -p "$HOME/.config/i3"

cp -rf "$SCRIPT_DIR"/config/* "$HOME/.config/i3"

log_info "i3 config files copied"
