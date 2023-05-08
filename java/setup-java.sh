#!/bin/bash

echo "################################################################" 
echo "Installing Java 16..."

sudo add-apt-repository ppa:linuxuprising/java
sudo apt-get update
sudo apt install -y oracle-java16-installer oracle-java16-set-default

# echo "################################################################" 
# echo "Installing Java 8..."

# sudo apt-get install openjdk-8-jre openjdk-8-jdk

echo "################################################################" 
echo "Setting default Java version..."

echo 3 | sudo update-alternatives --config java
java -version

echo "################################################################" 
echo "Instaling maven..."

sudo apt-get install maven
mvn --version
