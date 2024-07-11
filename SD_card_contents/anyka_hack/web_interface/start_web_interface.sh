#! /bin/sh

restart_process()
{
  echo 'restarting web interface...'
  /mnt/anyka_hack/web_interface/busybox httpd -p 80 -h /mnt/anyka_hack/web_interface/www
}

restart_process
