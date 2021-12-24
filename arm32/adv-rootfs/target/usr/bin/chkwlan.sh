#!/bin/sh

NUM=`cat /proc/net/dev |grep wlan0 |awk '{print $10}'`
sleep 5
NUM2=`cat /proc/net/dev |grep wlan0 |awk '{print $10}'`
if [ $NUM != $NUM2 ]; then
	echo "wlan0 is up"
else
	echo "wlan0 is down"
	/usr/bin/wlan.sh up
fi

exit 0

