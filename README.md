# FHEM-RPi-install
## DE
Installationsscript für eine automatische Installation von [FHEM](https://forum.fhem.de) und vorbereitende Installation für diverse Zusatzmodule auf einem RaspberryPi ([mit Raspberry Pi OS 11 Lite (Bullseye)](https://downloads.raspberrypi.org/raspios_lite_armhf_latest))
Einfach per SSH auf den RaspberryPi oder direkt auf dem RaspberryPi folgendes eingeben:
```
cd /tmp

wget https://raw.githubusercontent.com/steigerbalett/FHEM-RPi-install/master/install.sh

sudo bash install.sh
```

Nach der Installation & einem Reboot kann man FHEM im Browser von einem anderen PC im Netzwerk unter: http://fhempi:8083 erreichen.


## EN
Installscript for [FHEM](https://forum.fhem.de) on RaspberryPi ([with Raspberry Pi OS 11 Lite (Bullseye)](https://downloads.raspberrypi.org/raspios_lite_armhf_latest))

Just type in the command shell:
```
cd /tmp

wget https://raw.githubusercontent.com/steigerbalett/FHEM-RPi-install/master/install.sh

sudo bash install.sh
```

After installation & reboot you can access FHEM at port 8083: http://fhempi:8083
