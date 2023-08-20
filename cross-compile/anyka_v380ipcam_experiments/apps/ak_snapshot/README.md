### Credits
this repo is based on the original work of:

https://github.com/ricardojlrufino/anyka_v380ipcam_experiments/tree/master

# sample snapshot using http server

Capture YUV snapshot from camera, convert to BMP and serve on port 3000

changes:
- removed QR code related stuff
- added option to flip image vertically and horizontally

This version is modified to take new snapshot when calling http://192.168.15.64:3000/snapshot.jpg or another invalid format. This saves the CPU from having to serve the image over http when using the local image in `/tmp/preview.bmp`.

At this time it is not possible to get a larger image, only 640x480. (bug?)

## Usage

Note that you need to chnage the `sensor.ko` to match the one in your camera.

Also make sure that the libs are loaded from the correct place.

```
insmod /usr/modules/sensor_sc1245.ko
insmod /usr/modules/akcamera.ko
insmod /usr/modules/ak_info_dump.ko

export LD_LIBRARY_PATH=/oldcam/lib:/oldcam/usr/lib
```

`./ak_snapshot`

*Access in Browser*

http://192.168.15.64:3000/snapshot.bmp

## Options

The app does not have `--help`, but it takes arguments
- `-d <save_location>` [ default /tmp ]
- `-w <width>` [ default 640 ]
- `-h <height>` [ default 480 ]

## Compiling

Run: `./build.sh`


