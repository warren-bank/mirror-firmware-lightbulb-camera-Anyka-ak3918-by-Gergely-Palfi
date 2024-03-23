# Set up cross-compile tools
The cross-compiler is 32bit so using an older OS for better support is worth it. (maybe could even use a 32bit system, but this example is with running 32bit on 64bit linux)

These steps are based on translating [chinese instructions](https://github.com/helloworld-spec/qiwen/blob/main/anycloud39ev300/SDK/Quick%20Start%20Guide.txt) of the SDK.

- Ubuntu 16.04 live USB (so I don't destroy my distro)
- connect to internet for install
- `dpkg --add-architecture i386`
- `sudo apt update`
- `sudo apt install git libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386`
- `git clone https://github.com/helloworld-spec/qiwen.git`
- `sudo tar -Pxvf  anyka_uclibc_gcc.tar.bz2` (this will set up the compiler in /opt/)

These steps are included in a convenient bash script that can be launched on the live OS after connecting to internet.

## To Use
- `export PATH=$PATH:/opt/arm-anykav200-crosstool/usr/bin` (this is usually part of the build scripts)
- test with `arm-anykav200-linux-uclibcgnueabi-gcc –v`

# Compile example:
This is an example of how to compile the `ak_snapshot` app from start to finish

- Start a live USB version of Ubuntu 16.04 (other versions may work too, not tested)
- Connect to the internet
- copy `setup.sh` and the source code `anyka_v380ipcam_experiments` to the home folder `/home/ubuntu`
- open terminal in home folder and run `./setup.sh` (when it is done it should print the gcc version of the anyka compiler)
- copy the last line `export PATH=$PATH:/opt/arm-anykav200-crosstool/usr/bin`
- `cd anyka_v380ipcam_experiments/apps/ak_snapshot/`
- paste `export PATH=$PATH:/opt/arm-anykav200-crosstool/usr/bin` (this is usually part of the build scripts, so not really needed)
- `./build` (the compiled `ak_snapshot` will appear)

# Easiest way

The way I do my cross compiling is with a dedicated live USB of Ubuntu 16, which has been modified to include the cross-compiler (using CUBES). This means after startup I can run `./build.sh` as the compiler is part of the OS image. The ISO is very large, but if there is interest I may create a share link. Feel free to contact me (admin@raspiweb.com)
