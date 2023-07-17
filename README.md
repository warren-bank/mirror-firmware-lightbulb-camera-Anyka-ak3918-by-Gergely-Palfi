# Anyka_ak3918_hacking_journey

My attempt at reverse engineering and making use of a Chinese junk camera

# Info Links

cool info:

https://github.com/ricardojlrufino/anyka_v380ipcam_experiments/tree/master

https://github.com/JayGoldberg/anyka-cams

blog:

https://ricardojlrufino.wordpress.com/2022/02/14/hack-ipcam-anyka-teardown-and-root-access/

https://ricardojlrufino.wordpress.com/2022/02/15/hack-ipcam-anyka-booting-rootfs-from-sdcard/
...(more pages)

Discussion:

https://github.com/e27-camera-hack/E27-Camera-Hack/discussions/1

toolchain:

https://github.com/ricardojlrufino/arm-anykav200-crosstool

source of example modules and firmware parts (rtsp)

https://github.com/Nemobi/Anyka/tree/main/device/squashfs-root

source (seems to be the same at a glance)

https://github.com/burlizzi/anyka/tree/master/source

https://github.com/jingwenyi/SmartCamera/tree/master/source/updater

slightly newer SOC version (not very useful for me):

https://github.com/mucephi/anyka_ak3918_kernel

https://github.com/helloworld-spec/qiwen/tree/6c86facd09a5c2efe5314a669f653fa90acbc999/anycloud39ev300

# Step Zero, Flash backup
(never start hacking until you have a safe recovery plan in case of a brick)

After opening the camera box, I got to work. Without even powering the camera on, just straight away opened the camra and removed the flash chip. (pictures of the insides included)

Using an arduino Uno and a home made flash chip holder (fabricated from plastic card and some pin headers) I cloned the flash to an image file. Follow this guide: https://kaanlabs.com/bios-flashing-with-an-arduino-uno/

# Step One, UART
Soldered a pin header to the RX0 TX0 GND points next to the wifi chip. For UART converter I am using and ESP8266 (wemos D1 mini) arduino compatible board (CH340 serial chip). It is just a matter of bridging the reset pin to GND and connecting up the UART bus (`RX -> RXD, TX -> TXD, GND -> GND`) Note GND must be correct, but if the RT and TX are connected wrong and there is no output, just swap the wires, there is no harm.

This potentially gives access to U-Boot, but in my case not. This port provides essential information about the boot process and helps with debugging when errors are reported here.

# First power on
Not knowng much about the camera (have not analysed the flash dump yet), just set up the camera as usual with the broken english translated instructions. Now looking back at it, this is not necessary as FTP access should still work in AP mode and from then onward the wifi password (`/etc/jffs2anyka_cfg.ini`) and exploit scripts can be inserted.

# Getting In
Based on the general info online there are 3 ways in
1) through U-Boot (set init to shell)
2) through open telnet port
3) through open FTP port

(U-Boot time out is 0, so could not find a way to interrupt and get in, telnet port is not open, it gets killed by service.sh)

In my case options 1 and 2 were not available, but the FTP port was open. It just happens that the rw `/etc/jffs2/` folder has `time_zone.sh` which is a prime target for code execution.

# Permanent back door
The time_zone.sh script is overwritten each time the app finds the server and syncs time. So some simple bash scripting to create a daemon to repair the exploit when removed solves that.

# Halting the main app
The main app connects to external Chinese servers and is garbage in general, worst of all the camera refuses to work if it is blocked from accessing the internet. With the goal of using RTSP instead, there is no need for it to run at all. The exploit scripts take care of that, as they halt the init processes of the app with some time wasting sleep loops.

At this point we pretty much have a plain Linux base running with most of the crap halted. The exploit script also launches the necessary network connection scripts which was previously done by the app. At this point the camera is much safer and can finally operate on an isolated VLAN without internet access (as all IOT devices should be).

# Snapshot app
The `anyka_v380ipcam_experiments` repo has a good Snapshot app that provides `bmp (640x480)` snapshots on `http://IP:3000/Snapshot.bmp`. Simply copy the necessary oldcam library folder along with the executable to the SD in anyka_hack folder (`/mnt/anyka_hack/` in the system when mounted) and the exploit will launch it. I also created a daemon script for this app to make sure it is restarted if crashed (when trying to load a new image too soon)

# RTSP
Using the `Nemobi/Anyka` repo rtsp demo executable results in a lot of errors. The libs are loaded similarly to the snapshot app, 

`LD_LIBRARY_PATH=/mnt/anyka_hack/lib_rtsp:/mnt/anyka_hack/oldcam/usr/lib` (from SD card folder)

before launching the executable. First of all my camera does not support `/etc/jffs2/` folder path for H63 sensor conf file, I had to modify the 2 bytes of the binary to point to `/etc/jffs2/c`. When that was done, it complained that the conf file was too old version and needed `version 3`, so using an alternative conf file (https://github.com/Nemobi/Anyka/blob/main/device/squashfs-root/local/isp_h63_mipi_1lane_101402.conf) for the same sensor solved that. Then it could finally launch rtsp, but right away gives error.

```
[get_v4l2_ptr:408] select timeout!

[isp_vi_capture_on:724] get v4l2 frame ptr failed!

[ak_rtsp_vi_init:150] start capture failed
```

This is as far as I got.

The point of attention now is `libplat_vi.so` which contains the offending `get_v4l2_ptr`, but it could just as well be caused by a module. `ak_info_dump.ko` or `akcamera.ko`, which seem to be outdated. I could not load newer versions from SD card, `insmod` throws an error:

```
insmod: can't insert 'akcamera.ko': unknown symbol in module, or unknown parameter
insmod: can't insert 'ak_info_dump.ko': unknown symbol in module, or unknown parameter
```
