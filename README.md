# MacFanBooster

Is a simple script for boosting fans on MacBooks under linux. This script controls cooling system via applesmc driver installed in system.

> Warning: this scripts works only with MacBooks with **two** fans and only if applesmc driver is **installed** in system.

## Installing

To install MacFanBooster you need execute *install.sh* as root: `sudo ./install.sh`

If you can't execute install script then try `chmod +x install.sh` before installing.

## Using

Using MacFanBooster script is very simple. To show help text type: `fanboost -h` in your terminal. It will print:
```
Available arguments:
-h      -   prints this help.
-v      -   prints sensor values to screen.
--on    -   enable fan boost. (required root)
--off   -   return fan speed control to system. (required root)
```

### Enabling boost

To boost your fans type `sudo fanboost.sh --on` in your termnial. It will spin fans to their max RPM - 200 and print status of core temperature and fan RPMs.

To close status printing provide `ctrl+c` on your keyboard.

> Fan allways will be rotated to their max speed - 200 RPM for safety. **Do not modify boost script!**

### Disabling boost

For returning to default RPMs type `sudo fanboost --off` in your terminal.

To close status printing provide `ctrl+c` on your keyboard.

## Removing

To complete booster script removing provide:
``` shell
sudo rm /usr/sbin/fanboost.sh
sudo rm /usr/bin/fanboost.sh
```