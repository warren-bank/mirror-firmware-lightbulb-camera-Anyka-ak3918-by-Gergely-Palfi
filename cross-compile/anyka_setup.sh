#!/bin/bash

sudo dpkg --add-architecture i386
sudo apt update
sudo apt install git libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 -y
# get chinese anyka SDK
git clone https://github.com/helloworld-spec/qiwen.git
cd qiwen/anycloud39ev300/SDK/tools/
# unpack to system /opt
sudo tar -Pxvf  anyka_uclibc_gcc.tar.bz2
#test
export PATH=$PATH:/opt/arm-anykav200-crosstool/usr/bin
arm-anykav200-linux-uclibcgnueabi-gcc –v

echo "don't forget to set path in any terminal you use with:"
echo 'export PATH=$PATH:/opt/arm-anykav200-crosstool/usr/bin'
