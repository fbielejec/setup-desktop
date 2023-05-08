#!/bin/bash

curl https://sh.rustup.rs -sSf | sh
rustup default stable
rustup update
rustup update nightly
rustup target add wasm32-unknown-unknown --toolchain nightly
rustup component add rustfmt
