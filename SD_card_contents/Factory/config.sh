#! /bin/sh
telnetd &
if [[ -f /mnt/Factory/gergehack.sh ]]; then
  if ! [[ -f /etc/jffs2/gergehack.sh ]]; then
    #not installed yet, so copy it
    cp /mnt/Factory/gergehack.sh /etc/jffs2/gergehack.sh
  else
    #check for new version
    myresult=$( diff /mnt/Factory/gergehack.sh /etc/jffs2/gergehack.sh )
    if [[ ${#myresult} -gt 0 ]]; then
        echo 'install new gergehack from SD...'
        cp /mnt/Factory/gergehack.sh /etc/jffs2/gergehack.sh
    fi
  fi
fi
if [[ -f /mnt/Factory/gergesettings.txt ]]; then
  if ! [[ -f /etc/jffs2/gergesettings.txt ]]; then
    #not installed yet, so copy it
    cp /mnt/Factory/gergesettings.txt /etc/jffs2/gergesettings.txt
  else
    #check for new version
    myresult=$( diff /mnt/Factory/gergesettings.txt /etc/jffs2/gergesettings.txt )
    if [[ ${#myresult} -gt 0 ]]; then
        echo 'install new gergesettings from SD...'
        cp /mnt/Factory/gergesettings.txt /etc/jffs2/gergesettings.txt
    fi
  fi
fi
#gergedaemon and time_zone are not needed for the SD exploit
/etc/jffs2/gergehack.sh
