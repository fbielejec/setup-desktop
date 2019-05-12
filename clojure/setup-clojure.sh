#!/bin/bash

echo "#################################################"
echo "installing clojure"

curl -O https://download.clojure.org/install/linux-install-1.10.0.442.sh
chmod +x linux-install-1.10.0.442.sh
sudo ./linux-install-1.10.0.442.sh
rm linux-install-1.10.0.442.sh

echo "#################################################"
echo "installing rebel-readline"

mv deps.edn /home/$USER/.clojure/deps.edn
touch /home/$USER/Programs/rebel-readline.sh
echo "clojure -R:rebel -m rebel-readline.main" >> /home/$USER/Programs/rebel-readline.sh
chmod +x /home/$USER/Programs/rebel-readline.sh
sudo ln -s -f /home/filip/Programs/rebel-readline.sh /usr/bin/rebel-readline

# echo "#################################################"
# echo "installing lein"

wget "https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein"
chmod a+x lein
sudo mv lein /usr/bin/lein

lein --version
