#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up containers..."

require_brew

# colima rather than Docker Desktop. Docker Desktop requires a paid commercial
# subscription for companies above 250 employees or $10M revenue, which Kraken
# comfortably exceeds — so installing it on a work machine creates a licensing
# problem rather than solving a tooling one. colima is Apache-2.0 and provides
# the same docker CLI against a Lima VM.
brew_install colima docker docker-compose docker-buildx

# compose and buildx are CLI *plugins*: the docker binary only finds them
# through ~/.docker/cli-plugins, so without these symlinks `docker compose`
# reports an unknown command even though the formula is installed.
PLUGIN_DIR="$HOME/.docker/cli-plugins"
mkdir -p "$PLUGIN_DIR"
for plugin in docker-compose docker-buildx; do
    src="$(brew --prefix)/opt/${plugin}/bin/${plugin}"
    [ -x "$src" ] && ln -sfn "$src" "$PLUGIN_DIR/${plugin}"
done
log_info "Linked compose and buildx into $PLUGIN_DIR"

if colima status >/dev/null 2>&1; then
    log_info "colima VM already running"
else
    log_info "Starting colima VM (first start downloads an image, be patient)..."
    colima start --cpu 4 --memory 8 --disk 60
fi

if docker info >/dev/null 2>&1; then
    log_info "docker CLI is talking to colima"
else
    log_error "docker cannot reach the daemon. Try: colima start"
fi

log_info "Container setup complete"
