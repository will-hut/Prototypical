#!/bin/sh

repo_name = "hub75-fpga"

#Check for sudo access
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


echo Beginning setup...
sleep 3


echo Making sure packages are up to date:
apt update
apt upgrade -y


echo Installing build tools:
apt install build-essential -y


echo Grabbing latest repository:
git clone https://github.com/will-hut/$repo_name
cd $repo_name/SW/SenderService

echo Building FTDI sender program:
make

echo Adding systemd service:
cp sender /usr/local/bin/
cp screen.service /lib/systemd/system/
systemctl enable screen.service
systemctl start screen.service

echo Blacklisting ftdi_sio module
cp blacklist-ftdi.conf /etc/modprobe.d/

echo Done! Please reboot.