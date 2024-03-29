#!/bin/sh
# Error out if anything fails.
#set -e
#License
clear
echo '
                   GNU GENERAL PUBLIC LICENSE
                         FHEM-RPi-install
              Copyright (c) 2019-2023 steigerbalett

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

For a copy of the GNU General Public License see <http://www.gnu.org/licenses/>.
'
echo ''
echo ''
echo '███████╗██╗░░██╗███████╗███╗░░░███╗'
echo '██╔════╝██║░░██║██╔════╝████╗░████║'
echo '█████╗░░███████║█████╗░░██╔████╔██║'
echo '██╔══╝░░██╔══██║██╔══╝░░██║╚██╔╝██║'
echo '██║░░░░░██║░░██║███████╗██║░╚═╝░██║'
echo '╚═╝░░░░░╚═╝░░╚═╝╚══════╝╚═╝░░░░░╚═╝'
echo ''
echo ''
echo -e "\033[1;31mVERSION: 2023-03-15\033[0m"
echo -e "\033[1;31mFHEM 6.2\033[0m"
echo ''
echo 'Please update your RaspberryPi OS to newest version'
echo 'with: sudo apt update && sudo apt full-upgrade'
echo ''
echo ''
echo 'Installation will continue in 3 seconds...'
sleep 3

# Make sure script is run as root.
if [ "$(id -u)" != "0" ]; then
    echo -e "\033[1;31mDas Scrpit muss als root ausgeführt werden, sudo./install.sh\033[0m"
    echo -e '\033[36mMust be run as root with sudo! Try: sudo ./install.sh\033[0m'
  exit 1
fi

# Checking Memory Requirements
echo ''
echo "Checking minimum system memory requirements ..."
echo ''
memtotal=$(cat /proc/meminfo | grep MemTotal | grep -o '[0-9]*')
swaptotal=$(cat /proc/meminfo | grep SwapTotal | grep -o '[0-9]*')
echo "Your total system memory is $memtotal"
echo "Your total system swap is $swaptotal"
totalmem=$(($memtotal + $swaptotal))
echo "Your effective total system memory is $totalmem"

if [[ $totalmem -lt 900000 ]]
  then
    echo 'You have low memory'
  else
    echo 'You have enough memory to meet the requirements! :-)'
fi
    echo ''
    echo -n 'Do you want to create a 1 G swap file? [Y/n] '
    echo ''
    read swapfiledecision
      if [[ $swapfiledecision =~ (Y|y) ]]
        then
          echo 'Creating 1 G swap file...'
            sudo fallocate -l 1G /swapfile
            sudo chmod 600 /swapfile
            sudo mkswap /swapfile
            sudo swapon /swapfile
            sudo cp /etc/fstab /etc/fstab.bak
            echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null
          echo '1 G swap file successfully created!'
      elif [[ $swapfiledecision =~ (n) ]]
        then
          echo 'No swap file was created!'
      else
        echo Input error!
        echo No swap file was created!
        echo Please start again
      fi

echo 'Step 1:' 
echo "Installing dependencies..."
echo "=========================="
apt update
apt -y full-upgrade

apt -y install perl-base libdevice-serialport-perl libwww-perl libio-socket-ssl-perl libcgi-pm-perl libjson-perl sqlite3 libdbd-sqlite3-perl libtext-diff-perl libtimedate-perl libmail-imapclient-perl libgd-graph-perl libtext-csv-perl libxml-simple-perl liblist-moreutils-perl fonts-liberation libimage-librsvg-perl libgd-text-perl libsocket6-perl libio-socket-inet6-perl libmime-base64-perl libimage-info-perl libusb-1.0-0-dev libnet-server-perl
apt -y install libdate-manip-perl libhtml-treebuilder-xpath-perl libmojolicious-perl libxml-bare-perl libauthen-oath-perl libconvert-base32-perl libmodule-pluggable-perl libnet-bonjour-perl libcrypt-urandom-perl nodejs npm libnet-dbus-perl
apt -y install apt-transport-https ntpdate socat libnet-telnet-perl libcrypt-rijndael-perl libdatetime-format-strptime-perl libsoap-lite-perl libjson-xs-perl libxml-simple-perl libdigest-md5-file-perl liblwp-protocol-https-perl liblwp-protocol-http-socketunix-perl libio-socket-multicast-perl libcrypt-cbc-perl libcrypt-ecb-perl libtypes-path-tiny-perl librpc-xml-perl libdatetime-perl libmodule-pluggable-perl libreadonly-perl libjson-maybexs-perl
apt -y install libcryptx-perl avrdude libprotocol-websocket-perl libdigest-crc-perl libcpanel-json-xs-perl libio-socket-inet6-perl libperl-prereqscanner-notquitelite-perl libimage-librsvg-perl
apt -y install vlan

ntpdate -u de.pool.ntp.org

# Einstellen der Zeitzone und Zeitsynchronisierung per Internet: Berlin
sudo timedatectl set-timezone Europe/Berlin
sudo timedatectl set-ntp true

# Konfigurieren der lokale Sprache: deutsch 
sudo sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen 
sudo locale-gen 
sudo localectl set-locale LANG=de_DE.UTF-8 LANGUAGE=de_DE

echo 'Step 2:'
echo "Tweaks"
echo "========================"
echo ''
echo "Decreasing GPU memory"
echo "========================"
if grep gpu_mem /boot/config.txt; then
  echo "Not changing GPU memory since it's already set"
else
  echo "# Decrease GPU memory because its headless not needed" >> /boot/config.txt
  echo "gpu_mem=16" >> /boot/config.txt
fi
echo ''
echo "Turn off HDMI without connected Monitor"
echo "========================"
if grep hdmi_blanking=1 /boot/config.txt; then
  echo "HDMI tweak already set"
else
echo "# Turn off HDMI without connected Monitor to reduce inteference with HomematicIP Devices" >> /boot/config.txt
echo "hdmi_blanking=1" >> /boot/config.txt
fi
echo ''
echo "Turn on HDMI audio"
echo "========================"
if grep hdmi_drive=2 /boot/config.txt; then
  echo "HDMI audio tweak already set"
else
echo "# Turn on HDMI Audio" >> /boot/config.txt
echo "hdmi_drive=2" >> /boot/config.txt
fi
echo ''
if disable_splash=1 /boot/config.txt; then
  echo "Disable Splashscreen already set"
else
echo "" >> /boot/config.txt
echo "# disable the splash screen" >> /boot/config.txt
echo "disable_splash=1" >> /boot/config.txt
fi
echo ''
if grep disable_overscan=1 /boot/config.txt; then
  echo "Disable overscan already set"
else
echo "" >> /boot/config.txt
echo "# disable overscan" >> /boot/config.txt
echo "disable_overscan=1" >> /boot/config.txt
fi
echo ''
echo "Enable Hardware watchdog"
echo "========================"
if grep dtparam=watchdog=on /boot/config.txt; then
  echo "Watchdog already set"
else
echo "" >> /boot/config.txt
echo "# activating the hardware watchdog" >> /boot/config.txt
echo "dtparam=watchdog=on" >> /boot/config.txt
fi
echo ''
echo "Disable search for SD after USB boot"
echo "========================"
if grep dtoverlay=sdtweak,poll_once /boot/config.txt; then
  echo "SD-Tweak already set"
else
echo "" >> /boot/config.txt
echo "# stopp searching for SD-Card after boot" >> /boot/config.txt
echo "dtoverlay=sdtweak,poll_once" >> /boot/config.txt
fi

echo ''
echo 'Step 3:' 
echo -e '\033[5mFHEM installieren\033[0m'
echo "=========================="
echo ''
wget -O- https://debian.fhem.de/archive.key | gpg --dearmor > /usr/share/keyrings/debianfhemde-archive-keyring.gpg
sudo echo "deb [signed-by=/usr/share/keyrings/debianfhemde-archive-keyring.gpg] https://debian.fhem.de/nightly/ /" >> /etc/apt/sources.list
sudo apt update
sudo apt install fhem -y

# enable additional admin programs
echo 'Step 4: Optionales Admin Programm'
echo ''
echo 'Installation of optional Raspberry-Config UI: Webmin (recommend)'
echo ''
echo -n -e '\033[7mMöchten Sie Webmin installieren (empfohlen) [J/n]\033[0m'
echo ''
echo -n -e '\033[36mDo you want to install Webmin [Y/n]\033[0m'
read webmindecision

if [[ $webmindecision =~ (J|j|Y|y) ]]
  then
echo 'deb https://download.webmin.com/download/repository sarge contrib' | sudo tee /etc/apt/sources.list.d/100-webmin.list
cd ../root
wget http://www.webmin.com/jcameron-key.asc
sudo apt-key add jcameron-key.asc 
sudo apt update
sudo apt install webmin -y
elif [[ $webmindecision =~ (n) ]]
  then
    echo 'Es wurde nichts verändert'
    echo -e '\033[36mNo modifications was made\033[0m'
else
    echo 'Invalid input!'
fi

echo 'Step 5: Optionaler Dateiexplorer'
echo ''
echo 'Installation of optional Raspberry-Filemanager: Midnight Commander (recommend)'
echo 'https://www.linode.com/docs/guides/how-to-install-midnight-commander/'
echo ''
echo -n -e '\033[7mMöchten Sie Midnight Commander installieren (empfohlen) [J/n]\033[0m'
echo ''
echo -n -e '\033[36mDo you want to install Midnight Commander [Y/n]\033[0m'
read mcdecision

if [[ $mcdecision =~ (J|j|Y|y) ]]
  then
sudo apt install mc -y
elif [[ $mcdecision =~ (n) ]]
  then
    echo 'Es wurde nichts verändert'
    echo -e '\033[36mNo modifications was made\033[0m'
else
    echo 'Invalid input!'
fi

# Prepare for piVCCU
echo 'Step 6:'
echo 'Prepare: piVCCU for Homematic'
echo ''
echo 'Do you want to use piVCCU on this RaspberryPi?'
echo ''
echo -n -e '\033[7mMöchten Sie piVCCU auf diesem RaspberryPi nutzen? [J/n]\033[0m'
echo ''
echo -n -e '\033[36mDo you want to use piVCCU on this device? [Y/n]\033[0m'
read pivccudecision

if [[ $pivccudecision =~ (J|j|Y|y|z) ]]
  then
sudo bash -c 'cat << EOT >> /boot/config.txt
dtoverlay=pi3-miniuart-bt
enable_uart=1
force_turbo=1
core_freq=250
EOT'

sudo wget -q -O - https://www.pivccu.de/piVCCU/public.key | sudo apt-key add -
sudo bash -c 'echo "deb https://www.pivccu.de/piVCCU stable main" > /etc/apt/sources.list.d/pivccu.list'
sudo apt update
sudo apt -y install build-essential bison flex libssl-dev
sudo apt -y install raspberrypi-kernel-headers pivccu-modules-dkms
sudo apt -y install pivccu-modules-raspberrypi
sudo sed -i /boot/cmdline.txt -e "s/console=serial0,[0-9]\+ //"
sudo sed -i /boot/cmdline.txt -e "s/console=ttyAMA0,[0-9]\+ //"
sudo apt -y remove dhcpcd5
sudo apt -y install bridge-utils
sudo bash -c 'cat << EOT > /etc/network/interfaces
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

iface eth0 inet manual

auto br0
iface br0 inet dhcp
  bridge_ports eth0
EOT'

echo ''
echo ''
echo ''
echo 'Ein Neustart ist erforderlich um die Installation von piVCCU fortzusetzen'
echo 'Installieren sie nach dem Neustart piVCCU mit dem Befehl:'
echo 'sudo apt install pivccu3'
echo ''
echo 'Start installation of piVCCU after reboot with:'
echo 'sudo apt install pivccu3'

elif [[ $pivccudecision =~ (n) ]]
  then
    echo 'Es wurde nichts verändert'
    echo -e '\033[36mNo modifications was made\033[0m'
else
    echo 'Invalid input!'
fi
sleep 3

# Hostname setzen
echo 'Step 7:'
echo 'Change hostname'
echo ''
echo -n -e '\033[7mMöchten Sie den Hostnamen dieses RaspberryPi in fhempi ändern? [J/n]\033[0m'
echo ''
echo -n -e '\033[36mDDo you want to change the hostname to fhempi? [Y/n]\033[0m'
read hostnamedecision
if [[ $hostnamedecision =~ (J|j|Y|y|z) ]]
  then
sudo hostnamectl set-hostname fhempi
elif [[ $hostnamedecision =~ (n) ]]
  then
    echo 'Es wurde nichts verändert'
    echo -e '\033[36mNo modifications was made\033[0m'
else
    echo 'Invalid input!'
fi
sleep 3

echo ''
echo ''
echo ''
echo '##########################################'
echo ''
echo 'Auf Ihrem Raspberry wurde FHEM installiert'
echo ''
echo 'https://raw.githubusercontent.com/steigerbalett/FHEM-RPi-install/master/rpi-install.sh'
echo ''
echo -e "\033[36mAccess FHEM: http://`hostname -I`:8083\033[0m"
echo ''
echo -e "\033[36mAccess the Raspi-Config-UI Webmin at: http\033[42ms\033[0m\033[1;31m://`hostname -I`:10000\033[0m"
echo ''
echo -e "\033[36mwith user: pi and your password (raspberry)\033[0m"
echo ''
echo -e "\033[1;31mYou could start Midnight Commander by typing: mc\033[0m"
echo ''
echo ''
echo -e "\033[1;31mLoggen Sie sich in FHEM ein unter: http://`hostname -I`:8083\033[0m"
echo ''
echo -e "\033[1;31mLoggen Sie sich in die Raspi-Config-UI Webmin ein: http\033[42ms\033[0m\033[1;31m://`hostname -I`:10000\033[0m"
echo ''
echo -e "\033[1;31mMit Ihrem Benutzer: pi  und Passwort: (raspberry)\033[0m"
echo ''
echo -e "\033[1;31mMidnight Commander kann einfach gestartet werden mit: mc\033[0m"
echo ''
# reboot the raspi
echo -e '\033[7mSoll der RaspberryPi jetzt automatisch neu starten?\033[0m'
echo ''
echo -e '\033[36mShould the the RaspberryPi now reboot directly or do you do this manually later?\033[0m'
echo ''
echo -n -e '\033[36mDo you want to reboot now [Y/n]\033[0m'
read rebootdecision

if [[ $rebootdecision =~ (J|j|Y|y) ]]
  then
echo ''
echo 'System will reboot in 3 seconds'
sleep 3
sudo shutdown -r now
elif [[ $rebootdecision =~ (n) ]]
  then
    echo 'Please reboot to activate the changes'
else
    echo 'Invalid input!'
fi
echo 'Reboot the RaspberryPi now with: sudo reboot now'
exit
