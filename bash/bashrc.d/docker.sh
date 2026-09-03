# Docker Compose interpolates ${UID}/${GID}, and bash exports neither by default.
# Assigning UID is not an option: bash 5.2 (Ubuntu 24.04 and up) declares it
# readonly, so `export UID=$(id -u)` prints "UID: readonly variable" in every new
# shell. bash 5.1 does not, which is why this stayed invisible on the older box.
# Export the value bash already set instead; GID is not readonly and has none of
# this trouble.
export UID
export GID=$(id -g)
