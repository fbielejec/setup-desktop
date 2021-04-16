#!/bin/bash

echo "################################################################" 
echo "Installing dependencies..."

sudo apt-get install -y autoconf automake build-essential python-dev libtool libssl-dev libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1

echo "################################################################" 
echo "Installing kvm..."
sudo apt-get install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils
sudo usermod -aG kvm $USER

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
echo "Downloading android studio..."

# TODO : use most recent version
wget https://dl.google.com/dl/android/studio/ide-zips/3.4.1.0/android-studio-ide-183.5522156-linux.tar.gz

echo "Extracting archive..."
tar xvzf android-studio-ide-183.5522156-linux.tar.gz

mv android-studio /home/$USER/Programs

echo "Creating symlink..."
sudo ln -s -f /home/$USER/Programs/android-studio/bin/studio.sh /usr/bin/android-studio

echo "################################################################" 
echo "Done"

# mkdir -p ~/Android/Sdk/
# touch ~/.android/repositories.cfg

# wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
# unzip sdk-tools-linux-4333796.zip
# mv tools ~/Android/Sdk/
# rm sdk-tools-linux-4333796.zip

# #export PATH=$PATH:/home/$USER/Android/Sdk/tools/bin
# export ANDROID_SDK=/home/$USER/Android/Sdk/
# export PATH=$ANDROID_SDK/emulator:$ANDROID_SDK/tools:$ANDROID_SDK/tools/bin:$PATH

# sdkmanager "platform-tools" "platforms;android-28" "system-images;android-28;google_apis;x86"
#sdkmanager --licenses

#avdmanager create avd --package "system-images;android-28;google_apis;x86" --name "Pixel_API_28"
#emulator -list-avds
#emulator -avd "Pixel_API_28"
