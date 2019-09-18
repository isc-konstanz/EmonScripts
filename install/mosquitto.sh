#!/bin/bash
source load_config.sh

if [ "$install_mosquitto_server" = true ]; then
    echo "-------------------------------------------------------------"
    echo "Install Mosquitto Server"
    echo "-------------------------------------------------------------"
    sudo apt-get install -y mosquitto
    sudo apt-get install -y libmosquitto-dev

    # Disable mosquitto persistance
    sudo sed -i "s/^persistence true/persistence false/" /etc/mosquitto/mosquitto.conf
    # append line: allow_anonymous false
    sudo sed -i -n '/allow_anonymous false/!p;$a allow_anonymous false' /etc/mosquitto/mosquitto.conf
    # append line: password_file /etc/mosquitto/passwd
    sudo sed -i -n '/password_file \/etc\/mosquitto\/passwd/!p;$a password_file \/etc\/mosquitto\/passwd' /etc/mosquitto/mosquitto.conf
    # append line: log_type error
    sudo sed -i -n '/log_type error/!p;$a log_type error' /etc/mosquitto/mosquitto.conf

    # Create mosquitto password file
    sudo touch /etc/mosquitto/passwd
    sudo mosquitto_passwd -b /etc/mosquitto/passwd $mqtt_user $mqtt_password
fi

if [ "$install_mosquitto_client" = true ]; then
    echo "-------------------------------------------------------------"
    echo "Install Mosquitto Client"
    echo "-------------------------------------------------------------"
    sudo apt-get install -y libmosquitto-dev
    printf "\n" | sudo pecl install Mosquitto-beta
    echo "-------------------------------------------------------------"
    # Add mosquitto to php mods available
    PHP_VER=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d"." )
    printf "extension=mosquitto.so" | sudo tee /etc/php/$PHP_VER/mods-available/mosquitto.ini 1>&2
    sudo phpenmod mosquitto
fi
