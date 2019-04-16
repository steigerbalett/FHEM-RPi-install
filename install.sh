#!/bin/sh

# Error out if anything fails.
set -e

#License
clear
echo 'MIT License'
echo ''
echo 'Copyright (c) 2019 steigerbalett'
echo ''
echo 'Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:'
echo ''
echo 'The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.'
echo ''
echo 'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.'
echo ''
echo 'Installation will continue in 3 seconds...'
echo ''
echo -e "\033[1;31mVERSION: 2019-04-12\033[0m"
echo -e "\033[1;31mFHEM 5.9\033[0m"
sleep 3

# Make sure script is run as root.
if [ "$(id -u)" != "0" ]; then
    echo -e "\033[1;31mDas Scrpit muss als root ausgeführt werden, sudo./install.sh\033[0m"
    echo -e '\033[36mMust be run as root with sudo! Try: sudo ./install.sh\033[0m'
  exit 1
fi

echo "Installing dependencies..."
echo "=========================="
apt update
apt -y full-upgrade
apt -y install perl-base libdevice-serialport-perl libwww-perl libio-socket-ssl-perl libcgi-pm-perl libjson-perl sqlite3 libdbd-sqlite3-perl libtext-diff-perl libtimedate-perl libmail-imapclient-perl libgd-graph-perl libtext-csv-perl libxml-simple-perl liblist-moreutils-perl ttf-liberation libimage-librsvg-perl libgd-text-perl libsocket6-perl libio-socket-inet6-perl libmime-base64-perl libimage-info-perl libusb-1.0-0-dev libnet-server-perl
apt -y install apt-transport-https ntpdate socat libnet-telnet-perl libcrypt-rijndael-perl libdatetime-format-strptime-perl libsoap-lite-perl libjson-xs-perl libxml-simple-perl libdigest-md5-perl libdigest-md5-file-perl liblwp-protocol-https-perl liblwp-protocol-http-socketunix-perl libio-socket-multicast-perl libcrypt-cbc-perl libcrypt-ecb-perl libtypes-path-tiny-perl librpc-xml-perl
ntpdate -u de.pool.ntp.org 
cpan Crypt::Cipher::AES
cpan Crypt::ECB


echo -e '\033[5mFHEM installieren\033[0m'
echo "=========================="
cd /tmp
wget http://fhem.de/fhem-5.9.deb
sudo dpkg -i fhem-5.9.deb

if grep gpu_mem /boot/config.txt; then
  echo "Not changing GPU memory since it's already set"
else
  echo "Decreasing GPU memory"
  echo "========================"
  echo "" >> /boot/config.txt
  echo "# Decrease GPU memory because its headless not needed" >> /boot/config.txt
  echo "gpu_mem=16" >> /boot/config.txt
fi

if grep hdmi_blanking=1 /boot/config.txt; then
  echo "HDMI tweak already set"
else
echo "Turn off HDMI without connected Monitor"
echo "========================"
echo "" >> /boot/config.txt
echo "# Turn off HDMI without connected Monitor to reduce inteference with HomematicIP Devices" >> /boot/config.txt
echo "hdmi_blanking=1" >> /boot/config.txt
echo "" >> /boot/config.txt
echo "# disable HDMI audio" >> /boot/config.txt
echo "hdmi_drive=1" >> /boot/config.txt
fi

echo "Some Tweaks"
echo "========================"
echo "" >> /boot/config.txt
echo "# disable the splash screen" >> /boot/config.txt
echo "disable_splash=1" >> /boot/config.txt
echo "" >> /boot/config.txt
echo "# disable overscan" >> /boot/config.txt
echo "disable_overscan=1" >> /boot/config.txt

echo "Enable Hardware watchdog"
echo "========================"
echo "" >> /boot/config.txt
echo "# activating the hardware watchdog" >> /boot/config.txt
echo "dtparam=watchdog=on" >> /boot/config.txt



# enable log-rotation
echo 'Step X: enable logrotation'
echo -n -e '\033[7mSoll das Logfile automatisch nach 20 Tagen überschrieben werden? [J/n]\033[0m'
echo -n 'Do you want to set up Log-Rotation after 20 days? [Y/n]\033[0m'
read logrotationdecision

if [[ $logrotationdecision =~ (J|j|Y|y) ]]
  then
sudo apt install logrotate -y
sudo bash -c 'cat &gt;&gt; /etc/logrotate.d/unifi &lt;&lt; EOF
/var/log/unifi/*.log {
    rotate 20
    daily
    missingok
    notifempty
    compress
    delaycompress
    copytruncate
}
EOF'
elif [[ $logrotationdecision =~ (n) ]]
  then
    echo 'Es wurde nichts verändert'
    echo -e '\033[36mNo modifications was made\033[0m'
else
    echo 'Invalid input!'
fi

# enable additional admin programs
echo 'Step X: Optionales Admin Programm'
echo 'Installation of optional Raspberry-Config UI: Webmin (recommend)'
echo -n -e '\033[7mMöchten Sie Webmin installieren (empfohlen) [J/n]\033[0m'
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

echo 'Auf Ihrem Raspberry wurde FHEM installiert'
echo 'https://raw.githubusercontent.com/steigerbalett/FHEM-RPi-install/master/rpi-install.sh'
echo ''
echo -e "\033[36mAccess FHEM: https://`hostname -I`:8083\033[0m"
echo -e "\033[36mAccess the Raspi-Config-UI Webmin at: https://`hostname -I`:10000\033[0m"
echo -e "\033[36mwith user: pi and your password (raspberry)\033[0m"
echo ''
echo ''
echo -e "\033[1;31mLoggen Sie sich in FHEM ein unter: https://`hostname -I`:8083\033[0m"
echo ''
echo -e "\033[1;31mLoggen Sie sich in die Raspi-Config-UI Webmin ein: https://`hostname -I`:10000\033[0m"
echo -e "\033[1;31mMit Ihrem Benutzer: pi  und Passwort: (raspberry)\033[0m"
echo ''
# reboot the raspi
echo -e '\033[7mSoll der RaspberryPi jetzt automatisch neu starten?\033[0m'
echo -e '\033[36mShould the the RaspberryPi now reboot directly or do you do this manually later?\033[0m'
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
