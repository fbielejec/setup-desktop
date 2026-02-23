# Java
if command -v jrunscript >/dev/null 2>&1; then
    export JAVA_HOME="$(jrunscript -e 'java.lang.System.out.println(java.lang.System.getProperty("java.home"));')"
fi
