#!/bin/bash


CORE_SENSOR="/sys/devices/platform/coretemp.0/hwmon/hwmon1/temp1_input"
FAN_PATH="/sys/devices/platform/applesmc.768"

FAN_1="$FAN_PATH/fan1_"
FAN_2="$FAN_PATH/fan2_"

FAN_CURRENT_SPEED_PORT="input"
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

if [ -z "$1" ]
then
    echo "No argument supplied!"
    exit 1
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