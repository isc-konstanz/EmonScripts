# --------------------------------------------------------------------------------
# RaspberryPi Strech Build Script
# Emoncms, Emoncms Modules, EmonHub & dependencies
#
# Tested with: Raspbian Strech
# Date: 19 March 2019
#
# Status: Work in Progress
# --------------------------------------------------------------------------------

# Review splitting this up into seperate scripts
# - emoncms installer
# - emonhub installer
# Format as documentation

#!/bin/bash
source config.ini

echo "-------------------------------------------------------------"
echo "EmonSD Install"
echo "-------------------------------------------------------------"

if [ "$apt_get_upgrade_and_clean" = true ]; then
    echo "apt-get update"
    sudo apt-get update -y
    echo "-------------------------------------------------------------"
    echo "apt-get upgrade"
    sudo apt-get upgrade -y
    echo "-------------------------------------------------------------"
    echo "apt-get dist-upgrade"
    sudo apt-get dist-upgrade -y
    echo "-------------------------------------------------------------"
    echo "apt-get clean"
    sudo apt-get clean

    # Needed on stock raspbian lite 19th March 2019
    sudo apt --fix-broken install
fi

# Required for backup, emonpiLCD, wifi, rfm69pi firmware (review)
if [ ! -d $openenergymonitor_dir/data ]; then mkdir $openenergymonitor_dir/data; fi

echo "-------------------------------------------------------------"
sudo apt-get install -y git build-essential python-pip python-dev gettext
echo "-------------------------------------------------------------"

if [ "$install_apache" = true ]; then $openenergymonitor_dir/EmonScripts/install/apache.sh; fi
if [ "$install_mysql" = true ]; then $openenergymonitor_dir/EmonScripts/install/mysql.sh; fi
if [ "$install_php" = true ]; then $openenergymonitor_dir/EmonScripts/install/php.sh; fi
if [ "$install_redis" = true ]; then $openenergymonitor_dir/EmonScripts/install/redis.sh; fi
if [ "$install_mosquitto" = true ]; then $openenergymonitor_dir/EmonScripts/install/mosquitto.sh; fi
if [ "$install_emoncms_core" = true ]; then $openenergymonitor_dir/EmonScripts/install/emoncms_core.sh; fi
if [ "$install_emoncms_modules" = true ]; then $openenergymonitor_dir/EmonScripts/install/emoncms_modules.sh; fi
if [ "$install_emonhub" = true ]; then $openenergymonitor_dir/EmonScripts/install/emonhub.sh; fi
if [ "$install_emonmuc" = true ]; then $openenergymonitor_dir/EmonScripts/install/emonmuc.sh; fi

if [ "$emonSD_pi_env" = "1" ]; then
    if [ "$install_firmware" = true ]; then $openenergymonitor_dir/EmonScripts/install/firmware.sh; fi
    if [ "$install_emonpilcd" = true ]; then $openenergymonitor_dir/EmonScripts/install/emonpilcd.sh; fi
    if [ "$install_wifiap" = true ]; then $openenergymonitor_dir/EmonScripts/install/wifiap.sh; fi
    if [ "$install_emonsd" = true ]; then $openenergymonitor_dir/EmonScripts/install/emonsd.sh; fi

    # Enable service-runner update
    # update checks for image type and only runs with a valid image name file in the boot partition
    sudo touch /boot/emonSD-30Oct18
    exit 0
    # Reboot to complete
    sudo reboot
fi
