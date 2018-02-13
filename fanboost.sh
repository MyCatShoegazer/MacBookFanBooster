#!/bin/bash

# Script name
SCRIPT_NAME="mac_fan_booster"

# Path to the core temperature system sensor
CORE_SENSOR="/sys/devices/platform/coretemp.0/hwmon/hwmon1/temp1_input"

# Path to apple smc driver config path
FAN_PATH="/sys/devices/platform/applesmc.768"

# First fan macro
FAN_1="$FAN_PATH/fan1_"

# Second fan macro
FAN_2="$FAN_PATH/fan2_"

# Current fan speed macro
RPM_IN="input"

# Speed set for fan macro
RPM_OUT="output"

# Manual mode set for fan macro
MANUAL_OUT="manual"

# Safe rpm substructor for max speed
SAFE_RPM=200

# Fan 1 minimal RPM
FAN_1_MIN_RPM=$(<$FAN_1"min")

# Fan 1 maximal RPM
FAN_1_MAX_RPM=$(<$FAN_1"max")
FAN_1_MAX_RPM=$((FAN_1_MAX_RPM - SAFE_RPM))

# Fan 2 minimal RPM
FAN_2_MIN_RPM=$(<$FAN_1"min")

# Fan 2 maximal RPM
FAN_2_MAX_RPM=$(<$FAN_2"max")
FAN_2_MAX_RPM=$((FAN_2_MAX_RPM - SAFE_RPM))

# Prints sensor values to standard output
function print_sensors() {
    # Current core temperature in thousands
    CORE_TEMP=$(<$CORE_SENSOR)

    # Current temperature in C
    CORE_TEMP=$((CORE_TEMP / 1000))

    # Fan 1 current RPM
    FAN_1_RPM=$(<$FAN_1$RPM_IN)

    # Fan 2 current RPM
    FAN_2_RPM=$(<$FAN_2$RPM_IN)

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
        echo "Please, run this script with root to control fans."

        # Write result to syslog
        logger -t $SCRIPT_NAME "Can't execute with $1 without root."

        exit 1
    fi
}

# Main condition sequence
if [ "$1" = "--on" ]
then
    # If first argument is --on

    # Call root cheking
    check_root "$@"

    # Write boosting enabled event to syslog
    logger -t $SCRIPT_NAME "Boosting fans..."

    # Set manual mode for Fan 1 and Fan 2
    echo 1 > $FAN_1$MANUAL_OUT
    echo 1 > $FAN_2$MANUAL_OUT

    # Set speed for Fan 1 and Fan 2
    echo $FAN_1_MAX_RPM > $FAN_1$RPM_OUT
    echo $FAN_2_MAX_RPM > $FAN_2$RPM_OUT

    # Call script itself with -v arg
    "$0" -v
elif [ "$1" = "--off" ]
then
    # If first argument is --off

    # Call root checking
    check_root "$@"

    # Write fan speed control returned to system event to syslog
    logger -t $SCRIPT_NAME "Boosting disabling. Returning fan speed control to system..."

    # Return Fan 1 and Fan 2 speed control to system
    echo 0 > $FAN_1$MANUAL_OUT
    echo 0 > $FAN_2$MANUAL_OUT

    # Call script itself with -v arg
    "$0" -v
elif [ "$1" = "-v" ]
then
    # If -v argument is provided

    # Write status printing to terminal event to syslog
    logger -t $SCRIPT_NAME "Printing status..."

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
    printf '\t%s\t\t%c\t%s\n' "-h" "-" "prints this help."
    printf '\t%s\t\t%c\t%s\n' "-v" "-" "prints sensor values to screen."
    printf '\t%s\t\t%c\t%s\n' "--on" "-" "boosts fans. (required root)"
    printf '\t%s\t\t%c\t%s\n' "--off" "-" "returns fan speed control to system. (required root)"
    printf '\t%s\t%c\t%s\n' "--auto min max" "-" "automaticaly controls fans rpm between min and max core temp"
elif [[ "$1" = "--auto" && "$2" =~ ^[0-9]+$ && "$3" =~ ^[0-9]+$ ]]
then
    # If --auto argument is provided

    # Call root cheking
    check_root "$@"

    # Temperature after which cooling will be enabled
    TRESHOLD_TEMP=$2

    # Maximal temperature
    MAX_TEMP=$3

    if [ "$TRESHOLD_TEMP" -gt "$MAX_TEMP" ]
    then
        # If treshold temperature is greater than maximal temperature

        echo "Minimal treshold temperature can't be greater than maximum core temperature!"
        exit 1
    elif [ "$TRESHOLD_TEMP" = 0 -o "$MAX_TEMP" = 0 ]
    then
        # If treshold temperature of maximal temperature are zeroes

        echo "Minimal treshold or maximum core temperature can't be zero!"
        exit 1
    fi

    # Write event to syslog
    logger $SCRIPT_NAME "Working in auto mode. Treshold ($2) -> Max ($3)."

    # Available temperature degrees for current temperature range
    AVAIL_DEGREES=$((MAX_TEMP - TRESHOLD_TEMP))

    # Available fan rpm to work with
    FAN_1_AVAIL_RPM=$((FAN_1_MAX_RPM - FAN_1_MIN_RPM))

    # Incrementing rpm step
    FAN_1_RPM_STEP=$((FAN_1_AVAIL_RPM / AVAIL_DEGREES))

    # Available fan rpm to work with
    FAN_2_AVAIL_RPM=$((FAN_2_MAX_RPM - FAN_2_MIN_RPM))

    # Incrementing rpm step
    FAN_2_RPM_STEP=$((FAN_2_AVAIL_RPM / AVAIL_DEGREES))

    # Set manual mode for Fan 1 and Fan 2
    echo 1 > $FAN_1$MANUAL_OUT
    echo 1 > $FAN_2$MANUAL_OUT

    # Cooling loop
    while true;
    do
        # Take current core temp
        CURRENT_TEMP=$(<$CORE_SENSOR)
        # Divide it by 1000 to get traditional degrees
        CURRENT_TEMP=$((CURRENT_TEMP / 1000))

        if [[ ! $CURRENT_TEMP < $TRESHOLD_TEMP ]]
        then
            # If current core temp rised greter than treshold

            TEMP_OFFSET=$((MAX_TEMP - CURRENT_TEMP))
            TEMP_STEP=$((AVAIL_DEGREES - TEMP_OFFSET))

            FAN_1_RPM=$((FAN_1_RPM_STEP * TEMP_STEP + FAN_1_MIN_RPM))
            FAN_2_RPM=$((FAN_2_RPM_STEP * TEMP_STEP + FAN_2_MIN_RPM))

            # Set fans speed
            echo $FAN_1_RPM > $FAN_1$RPM_OUT
            echo $FAN_2_RPM > $FAN_2$RPM_OUT
        elif [[ $CURRENT_TEMP < $TRESHOLD_TEMP ]]
        then
            # If current core temp is less than treshold

            # Set minimal fans speed
            echo $FAN_1_MIN_RPM > $FAN_1$RPM_OUT
            echo $FAN_2_MIN_RPM > $FAN_2$RPM_OUT
        fi

        # Need to sleep cause to very fast rpm changing
        sleep 1
    done
else
    # Else print that provided argument is unknown
    echo "Unknown argument: $1!"

    # Call script itself with -h arg
    "$0" -h
fi