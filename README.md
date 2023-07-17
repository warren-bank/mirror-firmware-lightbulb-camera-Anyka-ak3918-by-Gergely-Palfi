# Anyka_ak3918_hacking_journey

My attempt at reverse engineering and making use of a Chinese junk camera

# Summary

- I got a permanent exploit that keeps telnet open for me
- UART header gives debug info, u-boot delay = 0 so can't get in
- Created some scripts that halt the main app and handle wifi connection instead of it
- The camera can now operate in isolation from the internet
- Found snapshot examples and got bmp image on port 3000
- trying to get rtsp working at the moment

# Info Links

## Cool info:

https://github.com/ricardojlrufino/anyka_v380ipcam_experiments/tree/master

https://github.com/JayGoldberg/anyka-cams

blogs/articles with cool info:

https://ricardojlrufino.wordpress.com/2022/02/14/hack-ipcam-anyka-teardown-and-root-access/

https://ricardojlrufino.wordpress.com/2022/02/15/hack-ipcam-anyka-booting-rootfs-from-sdcard/
...(more pages)

https://lucasteske.dev/2019/06/reverse-engineering-cheap-chinese-vrcam-protocol/

https://boschko.ca/hardware_hacking_yo_male_fertility/ (weird, but ok)

Discussion:

https://github.com/e27-camera-hack/E27-Camera-Hack/discussions/1

https://github.com/alienatedsec/yi-hack-v5/discussions/236

## Toolchain

https://github.com/ricardojlrufino/arm-anykav200-crosstool

https://github.com/Lamobo/Lamobo-D1/tree/master (waaayyy too outdated)

## Source

https://github.com/burlizzi/anyka/tree/master
or https://github.com/jingwenyi/SmartCamera/tree/master (seems to be the same at a glance)

https://github.com/grangerecords/anyka/tree/master

https://github.com/mucephi/anyka_ak3918_kernel

https://github.com/Nemobi/Anyka/tree/main

https://github.com/ThatUsernameAlreadyExist/anyka-v4l2rtspserver
and https://github.com/ThatUsernameAlreadyExist/anyka-software (very recent and promising)

(v4lrtspserver, live555, lighttpd)

slightly newer SOC version (not very useful for me):

https://github.com/helloworld-spec/qiwen/tree/main/anycloud39ev300 (explanation in chinese, good reference)

https://github.com/Nemobi/ak3918ev300v18

## Other resources

https://www.linux4sam.org/bin/view/Linux4SAM/UsingIsi?skin=print.myskin

https://blog.51cto.com/chenguang/2379530

# Step Zero, Flash backup
(never start hacking until you have a safe recovery plan in case of a brick)

After opening the camera box, I got to work. Without even powering the camera on, just straight away opened the camra and removed the flash chip. [pictures of the insides](https://gitea.raspiweb.com:2053/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/Images)

Using an arduino Uno and a home made flash chip holder (fabricated from plastic card and some pin headers) I cloned the flash to an image file. Follow this guide: https://kaanlabs.com/bios-flashing-with-an-arduino-uno/

NOTE: the Arduino Uno is 5V logic, so a resistor array is needed as a voltage difider

The dump of the camera may be available in the future (should not contain personal info as it was made before first power on, but it still has a unique ID for the cloud). When I have completely made the camera independent of the chinese cloud servers, then the dump will be public. (questions: <admin@raspiweb.com>)

# Step One, UART
Soldered a pin header to the RX0 TX0 GND points next to the wifi chip. For UART converter I am using and ESP8266 (wemos D1 mini) arduino compatible board (CH340 serial chip). It is just a matter of bridging the reset pin to GND and connecting up the UART bus (`RX -> RXD, TX -> TXD, GND -> GND`) Note GND must be correct, but if the RT and TX are connected wrong and there is no output, just swap the wires, there is no harm.

NOTE: the esp8266 is 3.3v logic so direct connection is fine

This potentially gives access to U-Boot, but in my case not. This port provides essential information about the boot process and helps with debugging when errors are reported here.

# First power on
Not knowng much about the camera (have not analysed the flash dump yet), just set up the camera as usual with the broken english translated instructions. Now looking back at it, this is not necessary as FTP access should still work in AP mode and from then onward the wifi password (`/etc/jffs2/anyka_cfg.ini`) and exploit scripts can be inserted.

# Getting In
Based on the general info online there are 3 ways in
1) through U-Boot (set init to shell)
2) through open telnet port
3) through open FTP port `ftp ftp://root:@192.168.10.191`

(U-Boot time out is 0, so could not find a way to interrupt and get in, telnet port is not open, it gets killed by service.sh)

In my case options 1 and 2 were not available, but the FTP port was open. It just happens that the rw `/etc/jffs2/` folder has `time_zone.sh` which is a prime target for code execution.

# Permanent back door
The time_zone.sh script is overwritten each time the app finds the server and syncs time. So some simple bash scripting to create a daemon that repairs the exploit when removed solves that.
1) open ftp terminal from the scripts folder `ftp ftp://root:@192.168.10.191`
2) `cd /etc/jffs2`
3) `mput time_zone.sh`, `mput gergehack.sh`, and `mput gergedaemeon.sh`
4) `quit`

reboot the camera, then telnet will be open every time. Connect with: `telnet 192.168.10.191` (root no password)

# Halting the main app
The main app connects to external Chinese servers and is garbage in general, worst of all the camera refuses to work if it is blocked from accessing the internet. With the goal of using RTSP instead, there is no need for it to run at all. The exploit scripts take care of that, as they halt the init processes of the app with some time wasting sleep loops.

At this point we pretty much have a plain Linux base running with most of the crap halted. The exploit script also launches the necessary network connection scripts which was previously done by the app. At this point the camera is much safer and can finally operate on an isolated VLAN without internet access (as all IOT devices should be).

# Snapshot app
The [anyka_v380ipcam_experiments](https://github.com/ricardojlrufino/anyka_v380ipcam_experiments/tree/master) repo has a good Snapshot app that provides `bmp (640x480)` snapshots on `http://IP:3000/Snapshot.bmp`. Simply copy the necessary oldcam library folder along with the executable to the SD in anyka_hack folder (`/mnt/anyka_hack/` in the system when mounted) and the exploit will launch it. I also created a daemon script for this app to make sure it is restarted if crashed (when trying to load a new image too soon)

# RTSP
Using the [Nemobi/Anyka](https://github.com/Nemobi/Anyka/tree/main/device/squashfs-root) repo rtsp demo executable results in a lot of errors. The libs are loaded similarly to the snapshot app, 

`LD_LIBRARY_PATH=/mnt/anyka_hack/lib_rtsp:/mnt/anyka_hack/oldcam/usr/lib` (from SD card folder)

before launching the executable. First of all my camera does not support `/etc/jffs2/` folder path for H63 sensor conf file, I had to modify the 2 bytes of the binary to point to `/etc/jffs2/c`. When that was done, it complained that the conf file was too old version and needed `version 3`, so using an [alternative conf file](https://github.com/Nemobi/Anyka/blob/main/device/squashfs-root/local/isp_h63_mipi_1lane_101402.conf) for the same sensor solved that. Then it could finally launch rtsp, but right away gives error. (full log available in [folder](https://gitea.raspiweb.com:2053/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/SD_card_contents/anyka_hack/rtsp/manual_launch.log))

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

# Boot Process Map
The boot process looks something like this:
```
  ________________________
 |                        |
 |         U-Boot         | (interrupt delay is 0, can't get in)
 |________________________|
              |
              V
  ________________________
 |                        |
 |         Kernel         | (Kernel command line: console=ttySAK0,115200n8 root=/dev/mtdblock4
 |________________________| rootfstype=squashfs init=/sbin/init mem=64M memsize=64M)
              |
              V
  ________________________
 |          init          |
 |     /etc/init.d/rcS    | (mounts filesystem, sets hostname)
 |________________________|
              |
              V
  ________________________
 |                        |
 |  /etc/init.d/rc.local  | (mount squashfs, mount jffs2, ftp server, ramdisk)
 |________________________|
              |
              V
  ________________________
 |                        |
 |  /usr/sbin/camera.sh   | (load modules)
 |________________________|
              |
              V
  ________________________
 |                        |
 |  /usr/sbin/service.sh  | (cmd_serverd, check sd card for factory tests and debug modes)
 |________________________| [NOTE: this check of the SD card is also a potential code execution entry point]
              |
              V
  _____________________________
 |                             |
 |/usr/sbin/anyka_ipc.sh start | (this process loads /etc/jffs2/time_zone.sh before calling the /bin/anyka_ipc app)
 |_____________________________| (It never gets to the /bin/anyka_ipc app)
                |
                V
  _____________________________
 |                             |
 |   /etc/jffs2/time_zone.sh   | (with the expoit lines present: launch telnet, call gergehack.sh)
 |_____________________________|
                |
                V
  _____________________________
 |                             | [holds the first 2 processes of anyka_ipc in a sleep loop]
 |   /etc/jffs2/gergehack.sh   | (launch gergedaemeon.sh, launch wifi_manage.sh, launch snapshot_daemon.sh)
 |_____________________________|
                |__________________________________________________________________________
                V                                      |                                   |
  ____________________________________                 |                                   |
 |                                    |                |                                   |
 | /mnt/anyka_hack/snapshot_daemon.sh |                |                                   |
 |____________________________________|                V                                   |
     (restart snapshot if crashed)        ____________________________                     |
                   |                     |                            |                    |
                   |                     | /etc/jffs2/gergedaemeon.sh |                    |
                   |                     |____________________________|                    V
                   V                         (fix exploit if needed)       ________________________________
  ______________________________________                                  |                                |
 |                                      |                                 | /usr/sbin/wifi_manage.sh start |
 | /mnt/anyka_hack/snapshot/ak_snapshot |                                 |________________________________|
 |______________________________________|                       (takes care of wifi connection and network setup)
             (port 3000)
```
