# Java
if [ "$(uname)" = "Darwin" ]; then
    # Homebrew's openjdk is keg-only, so jrunscript is never on PATH. java_home
    # reads the JDKs symlinked into /Library/Java/JavaVirtualMachines instead —
    # macos/java/setup-java.sh creates that symlink.
    if [ -x /usr/libexec/java_home ]; then
        _java_home="$(/usr/libexec/java_home 2>/dev/null)" || _java_home=""
        if [ -n "$_java_home" ]; then
            export JAVA_HOME="$_java_home"
            export PATH="$JAVA_HOME/bin:$PATH"
        fi
        unset _java_home
    fi
elif command -v java >/dev/null 2>&1; then
    # Resolved from the java binary on PATH rather than with `jrunscript -e`.
    # jrunscript needs a script engine, and Nashorn was removed from the JDK in
    # version 15 — so on Java 21 that call prints an error on every shell start
    # and leaves JAVA_HOME empty.
    _java_bin="$(readlink -f "$(command -v java)" 2>/dev/null)"
    if [ -n "$_java_bin" ]; then
        export JAVA_HOME="$(dirname "$(dirname "$_java_bin")")"
    fi
    unset _java_bin
fi
