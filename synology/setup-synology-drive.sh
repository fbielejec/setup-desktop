#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up Synology Drive client..."

if is_installed synology-drive; then
    log_info "Synology Drive client already installed, skipping"
    exit 0
fi

# Two things about this URL are counter-intuitive and cost a round of 404s to
# find. The release string is a directory but only the build number appears in
# the filename; and there is NO x86_64/ path segment, despite the filename
# itself carrying .x86_64.deb.
build="${SETUP_SYNOLOGY_DRIVE_RELEASE##*-}"
url="https://global.synologydownload.com/download/Utility/SynologyDriveClient/${SETUP_SYNOLOGY_DRIVE_RELEASE}/Ubuntu/Installer/synology-drive-client-${build}.x86_64.deb"

log_info "Downloading Synology Drive client ${SETUP_SYNOLOGY_DRIVE_RELEASE}..."
wget -O /tmp/synology-drive.deb "$url"
sudo dpkg -i /tmp/synology-drive.deb || sudo apt-get install -f -y
rm -f /tmp/synology-drive.deb

# Autostart needs no work here: i3/config/config already carries
# `exec synology-drive`, so the daemon starts with the i3 session.
log_info "Synology Drive client installed"
log_info "Sync folder pairs are a first-run GUI step — launch synology-drive to configure"
