#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up local coding harness (server)..."

# The GPU box only, and off by default — exactly one machine is ever the server.
# Gating lives in run.sh, not here, so `bash local-harness/setup-local-harness-server.sh`
# stays the way to retry this one step.
#
# Everything this touches — the CUDA llama.cpp build, the ~16 GiB GGUF pull, the
# rag-mcp binary, the systemd units and the compose stacks — belongs to the
# harness repo, next to the units and the README that describe them. `make
# install-server` is guarded tier by tier and RESTARTS NOTHING: a changed unit is
# reported, and `make -C "$SETUP_HARNESS_DIR" restart-server` takes the downtime
# deliberately.
if [ -d "$SETUP_HARNESS_DIR" ]; then
    log_info "Harness repo already present at $SETUP_HARNESS_DIR, skipping clone"
else
    log_info "Cloning harness repo to $SETUP_HARNESS_DIR..."
    git clone git@github.com:fbielejec/local-harness.git "$SETUP_HARNESS_DIR"
fi

make -C "$SETUP_HARNESS_DIR" install-server

log_info "Local coding harness server setup complete"
