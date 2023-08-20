#! /bin/sh

restart_process()
{
  echo 'restarting web interface...'
  export LD_LIBRARY_PATH=/mnt/anyka_hack/web_interface/lib
  /mnt/anyka_hack/web_interface/busybox httpd -p 8080 -h /mnt/anyka_hack/web_interface/www
}

check_process_health()
{
  myresult=$( top -n 1 | grep snapshot | grep -v grep | grep -v daemon )
  echo $myresult
  if [[ ${#myresult} -lt 5 ]]; then
    restart_process
  fi
}

#load kernel modules for camera
#insmod /usr/modules/sensor_h63.ko
#insmod /usr/modules/akcamera.ko
#insmod /usr/modules/ak_info_dump.ko

#while [ 1 ]; do
  #check_process_health
  restart_process
  sleep 5
#done
