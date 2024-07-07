# Anyka_ak3918_hacking_journey

My attempt at reverse engineering and making use of a Chinese junk camera

# Summary
This is a simplified README with the latest features, to see the hacking process and more development details go to the [old readme version](https://gitea.raspiweb.com/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/hack_process).

### Working features
- RTSP stream (720p on http://IP:554/vs0)
- BMP snapshot (up to 720p) on port 3000
- JPEG snapshot
- H264 video recording (no mp4 yet)
- Audio playback
- Audio recording to mp3
- PTZ movement
- IR shutter
- combined web interface with ptz and IR on port 80
- Motion detection

The camera can now be connected to a video recorder or monitor software such as MotionEye.

# Quick Start SD card hack

This hack runs only when the SD card is inserted leaving the camera unmodified. It is beginner friendly, and requires zero coding/terminal skills. See more [here](https://gitea.raspiweb.com/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/SD_card_contents/Factory)

It is unlikely that this can cause any harm to your camera as the system remains original, but no matter how small the risk it is never zero (unless you have the exact same camera). Try any of these hacks at your own risk.

# Permanent Hack
This part is optional.
The SD hack should launch telnet. Connect with `telnet IP` (user: root, no password)

- `[root@anyka /mnt]$ cat /dev/mtdblock4 > /mnt/mtdblock4.bin`
- Compare your rootfs `mtdblock4.bin` on the SD card with the one in this repo (`diff file1 file2`), if it is the same you can just use the prepared `newroot.sqsh4` and skip to updating.
- `unsquashfs mtdblock4.bin` (if not installed `sudo apt install squashfs-tools`) this unpacks to `squashfs-root` folder
- Modify `/etc/init.d/rc.local` to not launch `/usr/sbin/service.sh` and `/usr/sbin/camera.sh`, instead add a line `/etc/jffs2/gergehack.sh`
- `mksquashfs squashfs-root newroot.sqsh4 -b 131072 -comp xz -Xdict-size 100%` and copy that newly packed `newroot.sqsh4` to your SD card
- Install the modified rootfs with `[root@anyka /mnt]$ updater local A=/mnt/newroot.sqsh4`

more detailed process log [here](http://gitea.raspiweb.com/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/newroot/updater.txt)

After the rootfs is modified, power off the camera and take out the SD card. `Factory` folder can be deleted, the new place for `gergesettings.txt` is in `anyka_hack`. Adjust the settings `rootfs_modified=1`. The settings will be applied using the [update](https://gitea.raspiweb.com/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/exploit_scripts) of the script from `anyka_hack` folder.

Enjoy a fully private camera and enable the apps you want.

**The rest of this repository was written during development and may not be up to date according to the latest user-friendly hack solution.**

# Info Links

These are a the most important links here (this is where 99% of the info and resources come from):

https://github.com/helloworld-spec/qiwen/tree/main/anycloud39ev300 (explanation in chinese, good reference)

https://github.com/ricardojlrufino/anyka_v380ipcam_experiments/tree/master (ak_snapshot original)

https://github.com/MuhammedKalkan/Anyka-Camera-Firmware (Muhammed's RTSP app + library, and more discussions)

https://github.com/e27-camera-hack/E27-Camera-Hack/discussions/1 (discussion where most of this was worked on)


# APPS and Available Functions
This is not a complete list. This is only the best feature list. The [old readme version](https://gitea.raspiweb.com/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/hack_process) was too long, but it has everything not listed here.

### Web Interface

I created a combined web interface using the features from `ptz_daemon`, `ak_snapshot`, and `busybox httpd`. The webpage is based on [another Chinese camera hack for Goke processors](https://github.com/dc35956/gk7102-hack).

![web_interface](https://gitea.raspiweb.com/Gerge/Anyka_ak3918_hacking_journey/raw/branch/main/Images/web_interface.png)


### Libre Anyka App

This is an app in development aimed to combine most features of the camera and make it small enough to run from flash without the SD card.

Currently contains features:
- JPEG snapshot
- RTSP stream
- Motion detection trigger
- H264 `.str` file recording to SD card

Does not have:
- sound (only RTSP stream has sound)

More info about the [app](https://gitea.raspiweb.com/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/SD_card_contents/anyka_hack/libre_anyka_app) and [source](https://gitea.raspiweb.com/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/cross-compile/libre_anyka_app).


### SSH
[Dropbear](https://gitea.raspiweb.com/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/SD_card_contents/anyka_hack/dropbear) can give ssh access if telnet is not your preference.


### Play Sound
**Extracted from camera.**

More info about the [app](https://gitea.raspiweb.com/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/SD_card_contents/anyka_hack/ak_adec_demo)


### Record Sound
**mp3 recording works.**

More info about the [app](https://gitea.raspiweb.com/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/SD_card_contents/anyka_hack/aenc_demo) and [source](https://gitea.raspiweb.com/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/cross-compile/aenc_demo).
