#!/bin/bash

if [ $UID != 0 ]
then
    echo "Please, run this script as root."
    exit 1
else
    cp -v ./fanboost.sh /usr/sbin/fanboost
    chmod +x /usr/sbin/fanboost
    ln -s /usr/sbin/fanboost /usr/bin/fanboost

    logger -t "mac_fan_booster" "Installed successfully."
    echo "Installed!"
fi