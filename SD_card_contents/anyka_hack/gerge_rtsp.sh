#!/bin/sh

#insmod /usr/modules/sensor_sc1245.ko
#insmod /usr/modules/akcamera.ko
#insmod /usr/modules/ak_info_dump.ko

export LD_LIBRARY_PATH=/mnt/anyka_hack/lib_rtsp:/mnt/anyka_hack/oldcam/usr/lib


./mnt/anyka_hack/ak_rtsp_demo

