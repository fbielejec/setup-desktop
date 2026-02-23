#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up Java..."

JAVA_PKG="openjdk-${SETUP_JAVA_VERSION}-jdk"

if is_apt_installed "$JAVA_PKG"; then
    log_info "Java ($JAVA_PKG) already installed, skipping"
    exit 0
fi

log_info "Installing $JAVA_PKG and Maven..."
sudo apt-get install -y "$JAVA_PKG" maven

log_info "Java setup complete"
