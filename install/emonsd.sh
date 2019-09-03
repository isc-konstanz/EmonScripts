#!/bin/bash
source config.ini

# --------------------------------------------------------------------------------
# Install log2ram, so that logging is on RAM to reduce SD card wear.
# Logs are written to disk every hour or at shutdown
# log2ram forked from @pb66 repo here https://github.com/pb66/log2ram
# --------------------------------------------------------------------------------
cd $openenergymonitor_dir
git clone -b rsync_mods https://github.com/openenergymonitor/log2ram.git
cd log2ram
chmod +x install.sh && sudo ./install.sh
cd ..
rm -rf log2ram

# --------------------------------------------------------------------------------
# Install custom logrotate
# --------------------------------------------------------------------------------
# logrotate log
if [ ! -d /var/log/logrotate ]; then
  sudo mkdir /var/log/logrotate
  sudo chown -R root:adm /var/log/logrotate
fi
# custom logrotate config
sudo ln -sf $openenergymonitor_dir/EmonScripts/defaults/etc/logrotate.d/00_defaults /etc/logrotate.d/00_defaults
sudo ln -sf $openenergymonitor_dir/EmonScripts/defaults/etc/logrotate.d/emonhub /etc/logrotate.d/emonhub
sudo ln -sf $openenergymonitor_dir/EmonScripts/defaults/etc/logrotate.d/emoncms /etc/logrotate.d/emoncms

sudo chown root /etc/logrotate.d/00_defaults
sudo chown root /etc/logrotate.d/emonhub
sudo chown root /etc/logrotate.d/emoncms

# log2ram cron hourly entry
sudo ln -sf $openenergymonitor_dir/EmonScripts/defaults/etc/cron.hourly/log2ram /etc/cron.hourly/log2ram
sudo chmod +x /etc/cron.hourly/log2ram
# copy in commented out placeholder logrotate file
sudo cp $openenergymonitor_dir/EmonScripts/defaults/etc/cron.daily/logrotate /etc/cron.daily/logrotate

# --------------------------------------------------------------------------------
# UFW firewall
# --------------------------------------------------------------------------------
# Review: reboot required before running:
#sudo apt-get install -y ufw
# sudo ufw allow 80/tcp
# sudo ufw allow 443/tcp (optional, HTTPS not present)
# sudo ufw allow 22/tcp
# sudo ufw allow 1883/tcp #(optional, Mosquitto)
# sudo ufw enable

# Review: Memory Tweak
# Append gpu_mem=16 to /boot/config.txt this caps the RAM available to the GPU. 
# Since we are running headless this will give us more RAM at the expense of the GPU
# gpu_mem=16

# Review: change elevator=deadline to elevator=noop
# sudo nano /boot/cmdline.txt
# see: https://github.com/openenergymonitor/emonpi/blob/master/docs/SD-card-build.md#raspi-serial-port-setup

# Review: Force NTP update 
# is this needed now that image is not read only?
# 0 * * * * /home/pi/emonpi/ntp_update.sh >> /var/log/ntp_update.log 2>&1

# Review automated install: Emoncms Language Support
# sudo dpkg-reconfigure locales

# Setup user group to enable reading GPU temperature (pi only)
# sudo usermod -a -G video www-data

# Wifi setup
sudo ln -s $openenergymonitor_dir/emonpi/wifi-check /usr/local/bin/wifi-check

sudo crontab -l > mycron
if grep -Fq "wifi-check" mycron; then
    echo "wifi-check already present in crontab"
else
    echo "*/5 * * * * /usr/local/bin/wifi-check > /var/log/emoncms/wificheck.log 2>&1" >> mycron
    sudo crontab mycron
    rm mycron
fi

# --------------------------------------------------------------------------------
# Misc
# --------------------------------------------------------------------------------
# Review: provide configuration file for default password and hostname

# Set hostname
sudo sed -i "s/raspberrypi/$hostname/g" /etc/hosts
printf $hostname | sudo tee /etc/hostname > /dev/null

echo "Please enter a new SSH password to secure your system"
read ssh_password
# Set default SSH password:
printf "raspberry\n$ssh_password\n$ssh_password" | passwd
