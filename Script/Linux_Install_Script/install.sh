#!/bin/sh

repo_name="hub75-fpga"


echo [Beginning setup]
echo Attempting to get sudo...
if [[ ! $(sudo echo 0) ]]; then exit; fi


echo [Making sure packages are up to date]
sudo apt update
sudo upgrade -y


echo [Installing build tools]
sudo install build-essential -y


echo [Grabbing latest repository]
git clone https://github.com/will-hut/$repo_name
cd $repo_name/SW/SenderService

echo [Building FTDI sender program]
make

echo [Adding systemd service]
sudo cp sender /usr/local/bin/
sudo cp screen.service /etc/systemd/system/
sudo systemctl enable screen.service
sudo systemctl start screen.service

echo [Blacklisting ftdi_sio module]
sudo cp blacklist-ftdi.conf /etc/modprobe.d/

echo Done! Please reboot.