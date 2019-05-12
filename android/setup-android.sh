#!/bin/bash

echo "################################################################" 
echo "Installing dependencies..."

sudo apt-get install -y autoconf automake build-essential python-dev libtool libssl-dev

#if ! location="$(type -p "watchman")" || [ -z "watchman" ]; then  
if [ ! -d /home/$USER/Programs/watchman ]; then   

  echo "################################################################" 
  echo "WATCHMEN not found, installing"
  
  mkdir -p ~/Programs/
  cd ~/Programs/
  
  git clone https://github.com/facebook/watchman.git 
  cd watchman
  git checkout v4.7.0  # the latest stable release : https://github.com/facebook/watchman/releases
  git clean -dfx # clean state if previous installation
  ./autogen.sh
  ./configure
  make
  sudo make install

fi

echo "################################################################" 
echo "Installing android tools..."

mkdir -p ~/Android/Sdk/
touch ~/.android/repositories.cfg

# TODO : use most recent version
wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
unzip sdk-tools-linux-4333796.zip
mv tools ~/Android/Sdk/
rm sdk-tools-linux-4333796.zip

#export PATH=$PATH:/home/$USER/Android/Sdk/tools/bin
export ANDROID_SDK=/home/$USER/Android/Sdk/
export PATH=$ANDROID_SDK/emulator:$ANDROID_SDK/tools:$ANDROID_SDK/tools/bin:$PATH

sdkmanager "platform-tools" "platforms;android-28" "system-images;android-28;google_apis;x86"
#sdkmanager --licenses

#avdmanager create avd --package "system-images;android-28;google_apis;x86" --name "Pixel_API_28"
#emulator -list-avds
#emulator -avd "Pixel_API_28"

echo "################################################################" 
echo "Done"
