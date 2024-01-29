# Another exploit
The script `/usr/sbin/service.sh` which starts the `anyka_ipc` app on the default camera has some checks for updates and tests on the SD card.
If the `Factory` folder is present on the SD, then the camera thinks that there is a factory test script to run in there.

This script can be used to automate the hacking of the camera.

**This method is completely safe as no modifications are made to the camera.** The worst that can happen is that the hack does not work, but your camera will remain functional as original.

This is a tested and validated method on one of my cameras with factory reset firmware. Works out of the box, you never have to use the app as wifi will be set up.

1A) Simply copy the `anyka_hack` and `Factory` folder with the `config.sh`, `gergehack.sh` and `gergesettings.txt` to the SD card.

1B) Make sure to check all the settings in `gergesettings.txt` (especially the `rootfs_modified=0` must be set) and add the wifi credentials.

Never put `gergehack.sh` or `gergesettings.txt` in the `anyka_hack` folder if using this method, because they will conflict with the SD hack. Only leave the apps in there.

2) Put the SD card into the camera and power it on

## The camera will work with the hack applications when the SD card is plugged in.
## If there is no SD card with `Factory` folder, the camera will work as original without modifications.
