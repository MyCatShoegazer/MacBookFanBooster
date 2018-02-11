#!/bin/bash


# Path to the core temperature system sensor
CORE_SENSOR="/sys/devices/platform/coretemp.0/hwmon/hwmon1/temp1_input"

# Path to apple smc driver config path
FAN_PATH="/sys/devices/platform/applesmc.768"

# First fan macro
FAN_1="$FAN_PATH/fan1_"

# Second fan macro
FAN_2="$FAN_PATH/fan2_"

# Current fan speed macro
FAN_CURRENT_SPEED_PORT="input"

# Max available speed for fan macro
FAN_MAX_SPEED_PORT="max"

# Speed set for fan macro
FAN_SPEED_SET_PORT="output"

# Manual mode set for fan macro
FAN_MANUAL_MODE_PORT="manual"

# Prints sensor values to standard output
function print_sensors() {
    # Current core temperature in thousands
    CORE_TEMP=$(<$CORE_SENSOR)

    # Current temperature in C
    CORE_TEMP=$((CORE_TEMP / 1000))

    # Fan 1 current RPM
    FAN_1_RPM=$(<$FAN_1$FAN_CURRENT_SPEED_PORT)

    # Fan 2 current RPM
    FAN_2_RPM=$(<$FAN_2$FAN_CURRENT_SPEED_PORT)

    # Print values
    printf '%s\t%s%c\n' "Core temp:" "$CORE_TEMP" "c"
    printf '%s\t\t%s%s\n' "Fan 1:" "$FAN_1_RPM" "rpm"
    printf '%s\t\t%s%s\n' "Fan 2:" "$FAN_2_RPM" "rpm"
}

# Checks root rights for user running this script
function check_root() {
    if [ $UID != 0 ]
    then
        # If user isn't root print message and exit with code 1
        echo "Please run this script with root to control fans."
        exit 1
    fi
}

# Main condition sequence
if [ "$1" = "--on" ]
then
    # If first argument is --on

    # Call root cheking
    check_root

    # Get fan 1 max available speed in RPMs
    FAN_1_MAX_SPEED=$(<$FAN_1$FAN_MAX_SPEED_PORT)

    # Substruct fan 1 max speed with 200 RPMs for safety spinning
    FAN_1_MAX_SPEED=$(($FAN_1_MAX_SPEED - 200))

    # Get fan 2 max available speed in RPMs
    FAN_2_MAX_SPEED=$(<$FAN_2$FAN_MAX_SPEED_PORT)

    # Substruct fan 2 max speed with 200 RPMs for safety spinning
    FAN_2_MAX_SPEED=$(($FAN_2_MAX_SPEED - 200))

    # Set manual mode for Fan 1 and Fan 2
    echo 1 > $FAN_1$FAN_MANUAL_MODE_PORT
    echo 1 > $FAN_2$FAN_MANUAL_MODE_PORT

    # Set speed for Fan 1 and Fan 2
    echo $FAN_1_MAX_SPEED > $FAN_1$FAN_SPEED_SET_PORT
    echo $FAN_2_MAX_SPEED > $FAN_2$FAN_SPEED_SET_PORT

    # Call script itself with -v arg
    ./"$0" -v
elif [ "$1" = "--off" ]
then
    # If first argument is --off

    # Call root checking
    check_root

    # Return Fan 1 and Fan 2 speed control to system
    echo 0 > $FAN_1$FAN_MANUAL_MODE_PORT
    echo 0 > $FAN_2$FAN_MANUAL_MODE_PORT

    # Call script itself with -v arg
    ./"$0" -v
elif [ "$1" = "-v" ]
then
    # If -v argument is provided

    # Clear screen, call print sensors with 0.3 sec pause in loop
    while true;
        do
            clear
            print_sensors
            sleep 0.3
        done
elif [ "$1" = "-h" ]
then
    # If -h argument is provided

    # Print help text
    printf '%s\n' "Available arguments:"
    printf '\t%s\t%c\t%s\n' "-h" "-" "prints this help."
    printf '\t%s\t%c\t%s\n' "-v" "-" "prints sensor values to screen."
    printf '\t%s\t%c\t%s\n' "--on" "-" "boosts fans. (required root)"
    printf '\t%s\t%c\t%s\n' "--off" "-" "returns fan speed control to system. (required root)"
else
    # Else print that provided argument is unknown
    echo "Unknown argument: $1!"

    # Call script itself with -h arg
    ./"$0" -h
fi