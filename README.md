# Anyka_ak3918_hacking_journey

My attempt at reverse engineering and making use of a Chinese junk camera

# Summary
- Original firmware dump
- UART header gives debug info, and backup console if wifi fails
- Created some scripts that kill the main app and handle wifi connection instead of it
- I got a permanent exploit (ftp, telnet, ssh, password protected)
- The camera can now operate in isolation from the internet
- Able to modify the file-system safely (truely permanent)

### Working features
- 640x480 bmp snapshot on port 3000
- (work in progress) video recording
- Audio playback
- Audio recording (only pcm raw recording) (work in progress)
- PTZ movement
- IR shutter

The goal is trying to get rtsp or onvif video feed working to have a usable camera.

# Info Links

## Cool info:

https://github.com/ricardojlrufino/anyka_v380ipcam_experiments/tree/master

https://github.com/JayGoldberg/anyka-cams

blogs/articles with cool info:

https://ricardojlrufino.wordpress.com/2022/02/14/hack-ipcam-anyka-teardown-and-root-access/

https://ricardojlrufino.wordpress.com/2022/02/15/hack-ipcam-anyka-booting-rootfs-from-sdcard/
...(more pages)

https://lucasteske.dev/2019/06/reverse-engineering-cheap-chinese-vrcam-protocol/

https://github.com/c0decave/yoosee-ipc/tree/main

https://boschko.ca/hardware_hacking_yo_male_fertility/ (weird, but ok)

Discussion:

https://github.com/e27-camera-hack/E27-Camera-Hack/discussions/1

https://github.com/alienatedsec/yi-hack-v5/discussions/236

https://github.com/EliasKotlyar/Xiaomi-Dafang-Hacks/issues/1672

## Toolchain

https://github.com/ricardojlrufino/arm-anykav200-crosstool

https://github.com/Lamobo/Lamobo-D1/tree/master (waaayyy too outdated)

## Source

https://github.com/burlizzi/anyka/tree/master
or https://github.com/jingwenyi/SmartCamera/tree/master (seems to be the same at a glance)

https://github.com/grangerecords/anyka/tree/master

https://github.com/mucephi/anyka_ak3918_kernel

https://github.com/Nemobi/Anyka/tree/main

https://github.com/burlizzi/qiwen/tree/main

slightly newer SOC version (not very useful for me):

https://github.com/helloworld-spec/qiwen/tree/main/anycloud39ev300 (explanation in chinese, good reference)

https://github.com/Nemobi/ak3918ev300v18

## Apps and mods

https://github.com/ThatUsernameAlreadyExist/anyka-v4l2rtspserver
and https://github.com/ThatUsernameAlreadyExist/anyka-software (very recent and promising)

(v4lrtspserver, live555, lighttpd)

https://github.com/Lamobo/Lamobo-D1/tree/master

https://github.com/kuhnchris/IOT-ANYKA-PTZdaemon

https://blog.caller.xyz/v380-ipcam-firmware-patching/

## Other resources

https://www.linux4sam.org/bin/view/Linux4SAM/UsingIsi?skin=print.myskin

https://blog.51cto.com/chenguang/2379530

# Step Zero, Flash backup
(never start hacking until you have a safe recovery plan in case of a brick)

After opening the camera box, I got to work. Without even powering the camera on, just straight away opened it and removed the flash chip. [pictures of the insides](https://gitea.raspiweb.com:2053/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/Images)

Using an arduino Uno and a home made flash chip holder (fabricated from plastic card and some pin headers) I cloned the flash to an image file. Follow this guide: https://kaanlabs.com/bios-flashing-with-an-arduino-uno/

NOTE: the Arduino Uno is 5V logic, so a resistor array is needed as a voltage divider

The dump of the camera may be available in the future (should not contain personal info as it was made before first power on, but it still has a unique ID for the cloud). When I have completely made the camera independent of the chinese cloud servers, then the dump will be public. (questions: <admin@raspiweb.com>)

# Step One, UART
Soldered a pin header to the RX0 TX0 GND points next to the wifi chip. For UART converter I am using and ESP8266 (wemos D1 mini) arduino compatible board (CH340 serial chip). It is just a matter of bridging the reset pin to GND and connecting up the UART bus (`RX -> RXD, TX -> TXD, GND -> GND`) Note GND must be correct, for RT and TX just swap the wires and see what happens, there is no harm.

NOTE: the esp8266 is 3.3v logic so direct connection is fine

For software to connect anything works:
- Arduino IDE serial monitor baud: 115200 (line ending "carriage return")
- `minicom -b 115200 -D /dev/ttyUSB0` (you can exit with ctrl-A then q)
- `stty 115200 -F /dev/ttyUSB0 raw -echo` and `cat /dev/ttyUSB0` (not interactive) BONUS: it is colourful, this is my preffered way to view log

This potentially gives access to U-Boot, but in my case boot delay is zero, so could not get in. This port provides essential information about the boot process and helps with debugging when errors are reported here. Also, when the boot process is complete and messages calm down, it can be used as a backup console (if for example wifi fails, or got locked out for some reason).

# First power on
Not knowng much about the camera (have not analysed the flash dump yet), just set up the camera as usual with the broken english translated instructions. Now looking back at it, this is not necessary as FTP access should still work in AP mode and from then onward the wifi password (`/etc/jffs2/anyka_cfg.ini`) and exploit scripts can be inserted.

# Getting In
Based on the general info online there are 3 ways in
1) through UART
2) through open telnet port
3) through open FTP port `ftp ftp://root:@192.168.10.191`


By default the ports on the camera are:
```
$> nmap -p 1-10000 192.168.10.191
Starting Nmap 7.80 ( https://nmap.org ) at 2023-07-18 13:00 CEST
Nmap scan report for 192.168.10.191
Host is up (0.024s latency).
Not shown: 9996 closed ports
PORT     STATE SERVICE
21/tcp   open  ftp
6789/tcp open  ibm-db2-admin
6790/tcp open  hnmp

Nmap done: 1 IP address (1 host up) scanned in 5.03 seconds
```

-The UART output with the app running is cluttered with messages (usable if anyka_ipc is not running)
-Telnet port is not open

In my case FTP port was the convenient way in. Laid with red carpet, doors wide open, no password. It just happens that the rw `/etc/jffs2/` folder has `time_zone.sh` which is a prime target for code execution.

# Permanent back door
The time_zone.sh script is overwritten each time the app finds the server and syncs time. So some simple bash scripting to create a daemon that repairs the exploit when removed solves that.
1) open ftp terminal from the scripts folder `ftp ftp://root:@192.168.10.191`
2) `cd /etc/jffs2`
3) `mput time_zone.sh`, `mput gergesettings.txt`, `mput gergehack.sh`, and `mput gergedaemeon.sh`
4) `quit`

reboot the camera, then telnet will be open every time. Connect with: `telnet 192.168.10.191` (root, no password)

# Closing the main app
The main app connects to external Chinese servers and is garbage in general, worst of all the camera refuses to work if it is blocked from accessing the internet. With the goal of using RTSP instead, there is no need for it to run at all. The exploit scripts take care of that, stopping the daemon's watchdog process allows killing the anyka_ipc app.

At this point we pretty much have a plain Linux base running with most of the crap removed. The exploit script also launches the necessary network connection scripts which was previously done by the app. The camera is much safer and can finally operate on an isolated VLAN without internet access (as all IOT devices should be).

# Security
To have a secure login password instead of the default blank we can modify the shadow and passwd files in `/etc/jffs2/`. These files are simlinked to `/etc/` meaning any changes can be written in `jffs2` will apply system-wide without needing to modify the root filesystem.

1) `mkpasswd --method=md5` (if you need, install with `sudo apt install whois`)
2) specify the password you want
3) copy the hash given into shadow file `root:<myhash>:`
4) make sure `passwd` file has `root:x:` so that the password is actually used (if the x is missing then the password is ignored)
5) TEST login from a different terminal before you log out!

## SSH
Dropbear can give ssh access if telnet is not your preference.

# APPS and Available Functions
All the functions listed here can be enabled in gergesettings.txt and will be launched at boot.

### Snapshot
The [anyka_v380ipcam_experiments](https://github.com/ricardojlrufino/anyka_v380ipcam_experiments/tree/master) repo has a good Snapshot app that provides `bmp (640x480)` snapshots on `http://IP:3000/Snapshot.bmp`. All files are available for the SD card. I also created a daemon script for this app to make sure it is restarted if crashed (when trying to load a new image too soon)

### Video
work in progress

### Play Sound
The camera has `/usr/bin/ak_adec_demo` which allows playing sound files over the built in speaker. There is one small issue, it is waaayyyy too loud and makes the plastic casing resonate horribly, so I recommend lowering the volume of the mp3 file, especially if you use the camera indoors.
```
[root@anyka /usr/bin]$ ./ak_adec_demo --help
usage: ./ak_adec_demo [sample rate] [channel num] [type] [audio file path]
eg.: ./ak_adec_demo 8000 2 mp3 /mnt/20161123-153020.mp3
support type: [mp3/amr/aac/g711a/g711u/pcm]
```
1) lower the volume of your chosen file `ffmpeg -i Tutturuu.mp3 -af "volume=0.3" Tutturuu_low.mp3` (I went as low as 0.1)
2) copy the sound file over (and the `ak_adec_demo` if you don't have it) with ftp or just put it on the SD card
3) play the sound `ak_adec_demo 41100 1 mp3 /etc/jffs2/Tutturuu_low.mp3`

Warning: small audio files and executables should fit in the jffs2, but I recommend using SD storage to be safe.

### Record Sound
work in progress

I was able to compile a [working audio input demo](https://gitea.raspiweb.com:2053/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/SD_card_contents/anyka_hack/audio_in_raw_demo) from the [chinese repo here](https://github.com/helloworld-spec/qiwen/tree/main/anycloud39ev300). It is very basic, there are no settings and it just records audio at 8k samples/s for 10s to a raw pcm file. The goal is to get the aenc_demo working and have proper encoded mp3 audio instead of raw pcm. At least the mic is usable.

After getting the file from the camera (over FTP or SD) `ffplay -f s16le -ar 8k -ac 1 19700101-023156.pcm` will play the file.

### Movement with PTZ Daemon
There is a great [ptz motion daemon](https://github.com/kuhnchris/IOT-ANYKA-PTZdaemon) which I was able to compile. My finished executable is provided [here](https://gitea.raspiweb.com:2053/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/SD_card_contents/anyka_hack/ptz/ptz_daemon).

1) open one telnet and run it `./ptz_daemon` (or use gergehack to auto-start it on boot)
2) open second telnet and home the camera axes `echo "init" > /tmp/ptz.daemon`
3) move to whatever position you want `echo "t2p 190 95" > /tmp/ptz.daemon` 190 degree horizontal, 40 vertical (0 is top)
4) quit the daemon if you want with `echo "q" > /tmp/ptz.daemon`, but it can just always run in the background

More instructions to use are on the [original page](https://github.com/kuhnchris/IOT-ANYKA-PTZdaemon)

### IR filter
The infra-red filter can be turned on/off in two ways. Using the `ak_drv_ir_demo` as described [here](http://gitea.raspiweb.com:2053/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/IR_shutter.txt), or using the `ptz_daemon` with command `irinit` then `irsetircut 0` or `irsetircut 1` (use with echo as above). Both of these require that the `cmd_serverd` is running, so make sure to set `run_cmd_server=1` in `gergesettings.txt`. For some reason the IR feature is not even mentioned in the original ptz repo documentation, I found it by reading the source.

# Somewhat functional
With the main anyka_ipc app and daemon listening processes removed, as well as the simple snapshot capability and telnet ports added the portscan looks like this:
```
$> nmap -p 1-10000 192.168.10.191
Starting Nmap 7.80 ( https://nmap.org ) at 2023-07-18 13:34 CEST
Nmap scan report for 192.168.10.191
Host is up (0.024s latency).
Not shown: 9997 closed ports
PORT     STATE SERVICE
21/tcp   open  ftp
23/tcp   open  telnet
3000/tcp open  ppp

Nmap done: 1 IP address (1 host up) scanned in 5.28 seconds
```
The ftp port could also be closed by `killall /usr/bin/tcpsvd`, but for hacking it is a nice bonus. Either way the open ports are no longer an issue because the camera is on an isolated VLAN and we can set passwords.

# How to compile for AK3918?

This is a summary of how the ptz_daemon was compiled. Install the tools:
```
sudo apt install gcc-arm-linux-gnueabi g++-arm-linux-gnueabi binutils-arm-linux-gnueabi
```
I decided to compile everything I can as static (there is plenty of space on the SD card, so the larger size is worth the convenience on not having to look for all the libraries in the camera system). This makes distribution easy, just download and run it on the camera. I have to mention that I had to look for `.a` [static libraries](https://github.com/ricardojlrufino/anyka_v380ipcam_experiments/tree/master/akv300-extract/libplat/lib) that I can compile into it.

I used the following command (with static libs copied to libs/ folder):

`arm-linux-gnueabi-g++ ptz_daemon_cpp.cpp -L./libs -ldl -lplat_drv -lplat_common -lplat_thread -lpthread -D_GLIBCXX_USE_CXX11_ABI=0 -static -o ptz_daemon`

Then it is a matter of copy and run on the camera.

(PS: I still need to learn how to properly use libraries and compile with dynamic libs, this is my first time using gcc)

# Modify file-system
The camera runs on squashfs, so it will be read-only. However, we can create a new squashfs filesystem with modified files and overwrite the current one with `updater`.

This process works for rootfs (`mtdblock4`) and usrfs (`mtdblock5`). `mtdblock6` is jffs2, which you can edit anyway.

1) `[root@anyka /mnt]$ cat /dev/mtdblock4 > /mnt/mtdblock4.bin`
2) `unsquashfs mtdblock4.bin`
3) `mksquashfs squashfs-root newroot.sqsh4 -b 131072 -comp xz -Xdict-size 100%`
4) `[root@anyka /mnt]$ updater local A=/mnt/newroot.sqsh4`

more detailed process [here](http://gitea.raspiweb.com:2053/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/newroot/updater.txt)

# RTSP
work in progress

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
(with modified rootfs `camera.sh`, `service.sh` and `anyka_ipc.sh` can be left out)
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
 |_____________________________| (anyka_ipc gets terminated along with the watchdog)
                |
                V
  _____________________________
 |                             |
 |   /etc/jffs2/time_zone.sh   | (with the expoit lines present: launch telnet, call gergehack.sh)
 |_____________________________|
                |
                V
  _____________________________
 |                             | [kill the watchdog and anyka_ipc]
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
