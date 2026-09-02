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
elif command -v jrunscript >/dev/null 2>&1; then
    export JAVA_HOME="$(jrunscript -e 'java.lang.System.out.println(java.lang.System.getProperty("java.home"));')"
fi
