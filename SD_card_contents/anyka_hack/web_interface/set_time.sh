#!/bin/sh

monthnumber() {
    month=$1
    months="JanFebMarAprMayJunJulAugSepOctNovDec"
    tmp=${months%%$month*}
    month=${#tmp}
    monthnumber=$((month/3+1))
    printf "%02d\n" $monthnumber
}

#import settings
source /etc/jffs2/gergesettings.txt

sleep 30 #wait for wifi to connect and only try to get time after

export LD_LIBRARY_PATH=/mnt/anyka_hack/web_interface/lib
NET_DATE="$(/mnt/anyka_hack/web_interface/curl -s --head $time_source | grep '^Date:' | cut -d' ' -f 3-6)"
#echo $NET_DATE
HMS=${NET_DATE##* } #the last part is hour:min:sec
#echo $HMS
NET_DATE=${NET_DATE% *}
YEAR=${NET_DATE##* } #the last part is year
#echo $YEAR
NET_DATE=${NET_DATE% *}
MONTH=${NET_DATE##* } #the last part is month
#echo $MONTH
DAY=${NET_DATE% *}
#echo $DAY

BB_DATE="$YEAR-$(monthnumber $MONTH)-$DAY $HMS"
#echo 'Date is' $BB_DATE
date -s "$BB_DATE" 
