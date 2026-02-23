# Go (optional)
if [ -d "/usr/local/go" ]; then
    export GOPATH="$HOME/go"
    export GOROOT="/usr/local/go"
    export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"
fi
