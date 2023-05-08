#!/bin/bash
set -e
#
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. AT YOUR OWN RISK.
#
##################################################################################################################

echo "##################################################"
echo "Latest possible version of i3 with gaps"
echo "##################################################"

# installing i3 gap

rm -rf /tmp/i3

git clone https://github.com/i3/i3 /tmp/i3
cd /tmp/i3

# compile & install
autoreconf --force --install
rm -rf build/
mkdir -p build && cd build/

# Disabling sanitizers is important for release versions!
# The prefix and sysconfdir are, obviously, dependent on the distribution.
../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers

make && sudo make install

rm -rf /tmp/i3

echo "You installed the following version"
echo
echo
i3 --version
echo
echo
echo "##################################################"
echo "Latest possible version of i3 with gaps installed"
echo "##################################################"
sleep 1
