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
