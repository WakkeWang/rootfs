#!/bin/sh
### BEGIN INIT INFO
# Provides:          hostname
# Required-Start:
# Required-Stop:
# Default-Start:     S
# Default-Stop:
# Short-Description: Set hostname based on /etc/hostname
### END INIT INFO

HN=`cat /proc/board | tr A-Z a-z`

pri=`mount | grep "dev/root" | awk '{print $6}' | cut -b "2-3"`

if [ "$pri" == "ro" ];then
    mount -o remount,rw /
fi

if [ "$HN" != "" ]; then
    echo $HN > /etc/hostname
else
    echo "Adv335x" > /etc/hostname
fi

if test -f /etc/hostname
then
	hostname -F /etc/hostname
fi

if [ "$pri" == "ro" ];then
    mount -o remount,ro /
fi