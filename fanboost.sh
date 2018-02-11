#!/bin/bash


CORE_SENSOR="/sys/devices/platform/coretemp.0/hwmon/hwmon1/temp1_input"
FAN_PATH="/sys/devices/platform/applesmc.768"

FAN_1="$FAN_PATH/fan1_"
FAN_2="$FAN_PATH/fan2_"

FAN_CURRENT_SPEED_PORT="input"
FAN_MAX_SPEED_PORT="max"
FAN_SPEED_SET_PORT="output"
FAN_MANUAL_MODE_PORT="manual"

function print_sensors() {
    CORE_TEMP=$(<$CORE_SENSOR)
    CORE_TEMP=$((CORE_TEMP / 1000))

    FAN_1_RPM=$(<$FAN_1$FAN_CURRENT_SPEED_PORT)
    FAN_2_RPM=$(<$FAN_2$FAN_CURRENT_SPEED_PORT)

    printf '%s\t%s%c\n' "Core temp:" "$CORE_TEMP" "c"
    printf '%s\t\t%s%s\n' "Fan 1:" "$FAN_1_RPM" "rpm"
    printf '%s\t\t%s%s\n' "Fan 2:" "$FAN_2_RPM" "rpm"
}

function check_root() {
    if [ $UID != 0 ]
    then
        echo "Please run this script with root to control fans."
        exit 1
    fi
}

if [ -z "$1" ]
then
    echo "No argument supplied!"
    ./"$0" -h
fi

if [ "$1" = "-h" ]
then
    printf '%s\n' "Available arguments:"
    printf '\t%s\t%c\t%s\n' "-h" "-" "prints this help."
    printf '\t%s\t%c\t%s\n' "-v" "-" "prints sensor values to screen."
    printf '\t%s\t%c\t%s\n' "--on" "-" "boosts fans. (required root)"
    printf '\t%s\t%c\t%s\n' "--off" "-" "returns fan speed control to system. (required root)"
fi

if [ "$1" = "-v" ]
then
    while true;
    do
        clear
        print_sensors
        sleep 0.3
    done
fi

if [ "$1" = "--on" ]
then
    check_root

    FAN_1_MAX_SPEED=$(<$FAN_1$FAN_MAX_SPEED_PORT)
    FAN_1_MAX_SPEED=$(($FAN_1_MAX_SPEED - 200))

    FAN_2_MAX_SPEED=$(<$FAN_2$FAN_MAX_SPEED_PORT)
    FAN_2_MAX_SPEED=$(($FAN_2_MAX_SPEED - 200))

    echo 1 > $FAN_1$FAN_MANUAL_MODE_PORT
    echo 1 > $FAN_2$FAN_MANUAL_MODE_PORT

    echo $FAN_1_MAX_SPEED > $FAN_1$FAN_SPEED_SET_PORT
    echo $FAN_2_MAX_SPEED > $FAN_2$FAN_SPEED_SET_PORT

    ./"$0" -v
elif [ "$1" = "--off" ]
then
    check_root

    echo 0 > $FAN_1$FAN_MANUAL_MODE_PORT
    echo 0 > $FAN_2$FAN_MANUAL_MODE_PORT

    ./"$0" -v
fi