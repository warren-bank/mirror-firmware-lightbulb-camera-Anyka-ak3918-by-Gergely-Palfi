# Another exploit
The script `/usr/sbin/service.sh` which starts the `anyka_ipc` app on the default camera has some checks for updates and tests on the SD card.
If the `Factory` folder is present on the SD, then the camera thinks that there is a factory test script to run in there.

This script can be used to automate the hacking of the camera. Simply copy the `Factory` folder with the `config.sh` and also add the exploit scripts in here to the SD card.

1A) Simply copy the `Factory` folder with the `config.sh` and also add the exploit scripts in here to the SD card.

1B) Make sure to check all the settings in `gergesettings.txt` (especially the `rootfs_modified=0` must be set) and add the wifi credentials.

The exploit scripts and settings must be deleted from `anyka_hack` folder if using this method, because they will conflict with each other. Only leave the apps in there.

2) Put the SD card into the camera and power it on

The camera will work with the hack applications when the SD card is plugged in, if there is no SD card with `Factory` folder, the camera will work as original without modifications.
