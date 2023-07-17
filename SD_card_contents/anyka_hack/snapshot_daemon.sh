#! /bin/sh

restart_procest()
{
  export LD_LIBRARY_PATH=/mnt/anyka_hack/oldcam/lib:/mnt/anyka_hack/oldcam/usr/lib
  ./mnt/anyka_hack/ak_snapshot
}

check_process_health()
{
  myresult=$( top -n 1 | grep snapshot | grep -v grep | grep -v daemon )
  echo $myresult
  if [[ ${#myresult} -lt 5 ]]; then
    echo 'restarting snapshot service...'
    restart_process
  fi
}

while [ 1 ]; do
  check_process_health
  sleep 5
done
