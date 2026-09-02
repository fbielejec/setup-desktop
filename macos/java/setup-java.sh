#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Java..."

require_brew

FORMULA="openjdk@${SETUP_JAVA_VERSION}"

# Guarded separately: bundling maven into the JDK branch means a re-run after a
# partial failure would silently never install it.
brew_install "$FORMULA"
brew_install maven

# openjdk is keg-only: brew deliberately does not link it into the PATH, and
# without this symlink /usr/libexec/java_home cannot see it — which means
# JAVA_HOME resolution fails and every JVM tool reports "no Java runtime".
# This symlink is the whole macOS-specific part of Java setup.
JDK_SRC="$(brew --prefix)/opt/${FORMULA}/libexec/openjdk.jdk"
JDK_DIR="/Library/Java/JavaVirtualMachines"
JDK_DST="${JDK_DIR}/${FORMULA}.jdk"

if [ -d "$JDK_SRC" ] && [ ! -e "$JDK_DST" ]; then
    # The directory does not exist on a Mac that has never had a JDK, and
    # ln into a missing directory fails the whole step under `set -e`.
    log_info "Linking JDK into $JDK_DIR (needs sudo)..."
    sudo mkdir -p "$JDK_DIR"
    sudo ln -sfn "$JDK_SRC" "$JDK_DST"
fi

if /usr/libexec/java_home -v "$SETUP_JAVA_VERSION" >/dev/null 2>&1; then
    log_info "java_home resolves: $(/usr/libexec/java_home -v "$SETUP_JAVA_VERSION")"
else
    log_error "java_home cannot find version $SETUP_JAVA_VERSION — check the symlink above"
fi

log_info "Java setup complete"
