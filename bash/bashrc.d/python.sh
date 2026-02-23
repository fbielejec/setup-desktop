# Python: pyenv + default venv
export PATH="$HOME/.local/bin:$PATH"
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    [ -d "$PYENV_ROOT/bin" ] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - bash)"
fi
[ -f "$HOME/.venv/default/bin/activate" ] && source "$HOME/.venv/default/bin/activate"
