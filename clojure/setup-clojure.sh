#!/bin/bash

echo "#################################################"
echo "installing Clojure"

CLOJURE_VERSION=1.10.0.442

curl -O https://download.clojure.org/install/linux-install-$CLOJURE_VERSION.sh
chmod +x linux-install-$CLOJURE_VERSION.sh
sudo ./linux-install-$CLOJURE_VERSION.sh
rm linux-install-$CLOJURE_VERSION.sh

#echo "#################################################"
#echo "installing rebel-readline"
#
#cp deps.edn /home/$USER/.clojure/deps.edn
#touch /home/$USER/Programs/rebel-readline.sh
#echo "clojure -R:rebel -m rebel-readline.main" >> /home/$USER/Programs/rebel-readline.sh
#chmod +x /home/$USER/Programs/rebel-readline.sh
#sudo ln -s -f /home/filip/Programs/rebel-readline.sh /usr/bin/rebel-readline

#echo "#################################################"
#echo "installing lein"
#
#wget "https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein"
#chmod a+x lein
#sudo mv lein /usr/bin/lein
#
#echo "#################################################"
#echo "creating lein :user profile"
#mkdir /home/$USER/.lein
#cp profiles.clj /home/$USER/.lein/profiles.clj
#
#lein --version
