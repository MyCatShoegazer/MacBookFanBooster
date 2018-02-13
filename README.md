# MacFanBooster

Is a simple script for boosting fans on MacBooks under linux. This script controls cooling system via applesmc driver installed in system.

> Warning: this script works only with MacBooks with **two** fans and only if applesmc driver is **installed** in system.

## Installing

To install MacFanBooster you need execute *install.sh* as root: `sudo ./install.sh`

If you can't execute install script then try `chmod +x install.sh` before installing.

## Using

Using MacFanBooster script is very simple. To show help text type: `fanboost -h` in your terminal. It will print:
```
Available arguments:
-h              -   prints this help.
-v              -   prints sensor values to screen.
--on            -   enable fan boost. (required root)
--off           -   return fan speed control to system. (required root)
--auto min max  -   automaticaly controls fans rpm between min and max core temperature (required root).
```

### Enabling boost

To boost your fans type `sudo fanboost --on` in your termnial. It will spin fans to their max RPM - 200 and print status of core temperature and fan RPMs.

To close status printing provide `ctrl+c` on your keyboard.

> Fan allways will be rotated to their max speed - 200 RPM for safety. **Do not modify boost script!**

> Note: that script will continue to work in background.

### Disabling boost

For returning to default RPMs type `sudo fanboost --off` in your terminal. Also it is applicable 
for auto mode.

To close status printing provide `ctrl+c` on your keyboard.

> Note: that script will continue to work in background.

### Enabling auto mode

Auto mode is recommended in most cases except you want to staticaly boost your fans. To run script
in this mode you need to provide `sudo fanboost --auto min max` in your terminal. **min** is a
treshold after which auto mode starting cooling your system and trying to keep temperature before
max.

To close status printing provide `ctrl+c` on your keyboard.

> Note: that script will continue to work in background.

## Removing

To complete booster script removing provide:
``` shell
sudo rm /usr/sbin/fanboost
sudo rm /usr/bin/fanboost
```

## Latest release

This link providing
[latest release page](https://github.com/MyCatShoegazer/MacBookFanBooster/releases/latest).