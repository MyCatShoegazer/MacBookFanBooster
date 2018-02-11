#!/bin/bash


CORE_SENSOR="/sys/devices/platform/coretemp.0/hwmon/hwmon1/temp1_input"
FAN_PATH="/sys/devices/platform/applesmc.768/"

FAN_1_MANUAL="$FAN_PATH/fan1_manual"
FAN_1_CURRENT_SPEED="$FAN_PATH/fan1_input"
FAN_1_SPEED_SET="$FAN_PATH/fan1_output"

FAN_2_MANUAL="$FAN_PATH/fan2_manual"
FAN_2_CURRENT_SPEED="$FAN_PATH/fan2_input"
FAN_2_SPEED_SET="$FAN_PATH/fan2_output"

