#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up Java..."

JAVA_PKG="openjdk-${SETUP_JAVA_VERSION}-jdk"

# Guarded separately. A single guard on the JDK also skipped Maven, so a machine
# that already had a JDK — installed by hand, or by a distro metapackage — never
# got Maven at all and the step reported success.
if is_apt_installed "$JAVA_PKG"; then
    log_info "Java ($JAVA_PKG) already installed, skipping"
else
    log_info "Installing $JAVA_PKG..."
    sudo apt-get install -y "$JAVA_PKG"
fi

if is_apt_installed maven; then
    log_info "Maven already installed, skipping"
else
    log_info "Installing Maven..."
    sudo apt-get install -y maven
fi

log_info "Java setup complete"
