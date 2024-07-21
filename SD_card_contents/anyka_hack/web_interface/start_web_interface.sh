#! /bin/sh

restart_process()
{
  echo 'restarting web interface...'
  /mnt/anyka_hack/web_interface/busybox httpd -p 80 -h /mnt/anyka_hack/web_interface/www
}

update_webui()
{
  if [[ -f /etc/jffs2/www/index.html ]]; then
    webuifiles=$(ls /mnt/anyka_hack/web_interface/www/cgi-bin/*)

    for i in $webuifiles; do
      filename="${i##*/}"
      echo "check $filename"
      if [[ -f /etc/jffs2/www/cgi-bin/$filename ]]; then
        myresult=$( diff /mnt/anyka_hack/web_interface/www/cgi-bin/$filename /etc/jffs2/www/cgi-bin/$filename )
        if [[ ${#myresult} -gt 0 ]]; then
          cp /mnt/anyka_hack/web_interface/www/cgi-bin/$filename /etc/jffs2/www/cgi-bin/$filename
        fi
      else
        cp /mnt/anyka_hack/web_interface/www/cgi-bin/$filename /etc/jffs2/www/cgi-bin/$filename
      fi
    done
  else
    mkdir /etc/jffs2/www
    cp -r /mnt/anyka_hack/web_interface/www/cgi-bin /etc/jffs2/www/
    cp /mnt/anyka_hack/web_interface/www/styles.css /etc/jffs2/www/
    cp /mnt/anyka_hack/web_interface/www/index.html /etc/jffs2/www/
  fi
}
update_webui
/mnt/anyka_hack/ffmpeg/app_restarter.sh &
restart_process

