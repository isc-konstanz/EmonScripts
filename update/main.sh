#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR
source load_config.sh

echo "-------------------------------------------------------------"
echo "Update EmonPi stack"
echo "-------------------------------------------------------------"

type=$1
firmware=$2
serial_port=$3

datestr=$(date)

echo "Date:" $datestr
echo "EUID: $EUID"
echo "root: $openenergymonitor_dir"
echo "type: $type"
echo "firmware: $firmware"

if [ "$EUID" = "0" ] ; then
    # update is being ran mistakenly as root, switch to user
    echo "update running as root, switch to user"
    exit 0
fi

if [ "$emonSD_pi_env" = "1" ]; then
    if [ -f /dev/i2c-1 ] || [ -f /dev/i2c/1 ]; then
        # Check if we have an emonpi LCD connected, 
        # if we do assume EmonPi hardware else assume rfm2pi
        lcd27=$(sudo $openenergymonitor_dir/emonpi/lcd/emonPiLCD_detect.sh 27 1)
        lcd3f=$(sudo $openenergymonitor_dir/emonpi/lcd/emonPiLCD_detect.sh 3f 1)
        
        if [ $lcd27 == 'True' ] || [ $lcd3f == 'True' ]; then
            hardware="EmonPi"
        else
            hardware="rfm2pi"
        fi
    else
        hardware="custom"
    fi
    echo "Hardware detected: $hardware"
    
    if [ "$hardware" == "EmonPi" ]; then    
        # Stop emonPi LCD servcice
        echo "Stopping emonPiLCD service"
        sudo service emonPiLCD stop

        # Display update message on LCD
        echo "Display update message on LCD"
        sudo $openenergymonitor_dir/emonpi/lcd/./emonPiLCD_update.py
    fi
fi

# -----------------------------------------------------------------

if [ "$type" == "all" ]; then
    sudo rm -rf hardware/emonpi/emonpi2c/

    for repo in "emonpi" "RFM2Pi" "usefulscripts" "huawei-hilink-status" "oem_openHab" "oem_node-red"; do
        if [ -d $openenergymonitor_dir/$repo ]; then
            echo "git pull $openenergymonitor_dir/$repo"
            cd $openenergymonitor_dir/$repo
            git branch
            git status
            git fetch --all --prune
            git pull
			echo
        fi
    done
fi
cd $openenergymonitor_dir/EmonScripts/update

# -----------------------------------------------------------------

if [ "$type" == "all" ] || [ "$type" == "firmware" ]; then

    if [ "$firmware" == "emonpi" ]; then
        $openenergymonitor_dir/EmonScripts/update/emonpi.sh
		echo
    fi

    if [ "$firmware" == "rfm69pi" ]; then
        $openenergymonitor_dir/EmonScripts/update/rfm69pi.sh
		echo
    fi

    if [ "$firmware" == "rfm12pi" ]; then
        $openenergymonitor_dir/EmonScripts/update/rfm12pi.sh
		echo
    fi
    
    if [ "$firmware" == "emontxv3cm" ]; then
        $openenergymonitor_dir/EmonScripts/update/emontxv3cm.sh $serial_port
    fi
fi

# -----------------------------------------------------------------

if [ "$type" == "all" ] || [ "$type" == "emonhub" ]; then
    $openenergymonitor_dir/EmonScripts/update/emonhub.sh
    echo
fi

# -----------------------------------------------------------------

if [ "$type" == "all" ] || [ "$type" == "emonmuc" ]; then
    $openenergymonitor_dir/EmonScripts/update/emonmuc.sh
    echo
fi

# -----------------------------------------------------------------

if [ "$type" == "all" ] || [ "$type" == "emoncms" ]; then
    $openenergymonitor_dir/EmonScripts/update/emoncms_core.sh
    $openenergymonitor_dir/EmonScripts/update/emoncms_modules.sh
    echo
fi

# -----------------------------------------------------------------

if [ "$hardware" == "EmonPi" ]; then
    echo
    # Wait for update to finish
    echo "Starting emonPi LCD service.."
    sleep 5
    sudo service emonPiLCD restart
    echo
fi

# -----------------------------------------------------------------

datestr=$(date)
echo "-------------------------------------------------------------"
echo "EmonPi update done: $datestr" # this text string is used by service runner to stop the log window polling, DO NOT CHANGE!
echo "-------------------------------------------------------------"

# -----------------------------------------------------------------

if [ "$type" == "all" ] || [ "$type" == "emoncms" ]; then
    echo "restarting service-runner"
    sudo systemctl restart service-runner.service 
fi
