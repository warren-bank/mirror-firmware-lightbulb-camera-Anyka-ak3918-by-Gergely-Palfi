#!/bin/bash

arm-linux-gnueabi-g++ ptz_daemon_cpp.cpp -L./libs -ldl -lplat_drv -lplat_common -lplat_thread -lpthread -D_GLIBCXX_USE_CXX11_ABI=0 -static -o ptz_daemon
