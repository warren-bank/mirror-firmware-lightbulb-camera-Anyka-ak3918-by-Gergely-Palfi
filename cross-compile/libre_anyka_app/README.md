# Credits
this repo is based on the [original work of Ricardo](https://github.com/ricardojlrufino/anyka_v380ipcam_experiments/tree/master) and [MuhammedKalkan](https://github.com/MuhammedKalkan/Anyka-Camera-Firmware). The code has been modified a lot.

# Improvements and changes from Ricardo's work
- Loads image from memory and does not write to filesystem (as suggested by Ricardo's TODO comments)
- Uses hardware JPEG encoding for smaller filesize and faster process time
- Continuous encoding of images (encoding stops some time after no more previews are requested)
- Fixed resolution limitations (allows all resolutions up to 1280x720 as long as the size is a multiple of 4)
- Merged with RTSP stream app

# How it works

The `capture_loop` continuously takes YUV input and encodes jpeg images as long as there are requests for snapshots (if no https requests are made only RTSP runs)

There are two jpeg stream buffers (rotating between writing and ready to serve). This way an image can be served immediately on request.

The http server is waiting for requests in a separate thread.

RTSP stream runs on separate thread (framerate does suffer a bit if many JPEGs are requested)

## Usage

`run_libre_anyka_app.sh` script included which will load the kernel modules and start the app

The kernel module(s) needs to be adjusted to refer to the one for your sensor.
You can also edit the resolution arguments the snapshot app starts up with.

*Access in Browser*

http://IP:3000/snapshot.jpeg

*Access in VLC, ffplay, Motioneye or other DVR*

rtsp://IP:554/vs0 [MAIN] or rtsp://IP:554/vs1 [SUB]

## Options

The app does not have `--help`, but it takes arguments
- `-w <width>` [ default 1280 ]
- `-h <height>` [ default 720 ]

# Compiling

Make sure you have the [cross-compiler installed](https://gitea.raspiweb.com/Gerge/Anyka_ak3918_hacking_journey/src/branch/main/cross-compile).

Run: `./build.sh` (you may need to set execute permission first)


