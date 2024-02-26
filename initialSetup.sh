#! /usr/bin/env bash

echo "Unattended-Upgrade::Automatic-Reboot \"true\";" >> /etc/apt/apt.conf.d/50unattended-upgrades
echo "Unattended-Upgrade::Automatic-Reboot-WithUsers \"true\";" >> /etc/apt/apt.conf.d/50unattended-upgrades

sudo apt-get update -y
sudo apt-cache search openjdk
sudo apt-get install openjdk-17-jdk -y
sudo apt-get install maven -y

source /etc/environment
echo "$JAVA_HOME"

sudo apt-get install make -y
sudo apt-get install gcc -y
sudo apt-get install tcl -y
sudo apt-get install build-essential -y

sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python2.7 -y

wget -O- https://raw.githubusercontent.com/nicolargo/glancesautoinstall/master/install.sh | sudo /bin/bash


wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
sudo mkdir -p /usr/local/bin/
sudo mv ./lein* /usr/local/bin/lein
sudo chmod a+x /usr/local/bin/lein
export PATH=$PATH:/usr/local/bin


