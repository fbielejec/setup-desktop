# Rust toolchain
if [ -d "$HOME/.cargo" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
    export CARGO_HOME="$HOME/.cargo"
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    if command -v rustc >/dev/null 2>&1; then
        export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
    fi
fi
