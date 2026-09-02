# Homebrew — macOS only.
# Deployed from macos/bash/bashrc.d/, not the shared bash/bashrc.d/.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew "$HOME/homebrew/bin/brew"; do
    if [ -x "$_brew" ]; then
        eval "$("$_brew" shellenv)"
        break
    fi
done
unset _brew

# GNU userland ahead of the BSD tools, so scripts written against GNU flags
# behave the same here as they do on the Linux machine. gawk is deliberately
# absent: it installs awk/gawk straight into bin and has no gnubin directory.
if _prefix="$(brew --prefix 2>/dev/null)"; then
    for _gnu in coreutils findutils gnu-sed; do
        [ -d "$_prefix/opt/$_gnu/libexec/gnubin" ] && \
            export PATH="$_prefix/opt/$_gnu/libexec/gnubin:$PATH"
    done
fi
unset _prefix _gnu
