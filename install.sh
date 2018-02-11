#!/bin/bash

if [ $UID != 0 ]
then
    echo "Please, run this script as root."
    exit 1
else
    cp -v ./fanboost.sh /usr/sbin/fanboost.sh
    chmod +x /usr/sbin/fanboost.sh
    ln -s /usr/sbin/fanboost.sh /usr/bin/fanboost.sh

    echo "Installed!"
fi