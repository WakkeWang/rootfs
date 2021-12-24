#!/bin/sh
### BEGIN INIT INFO
# Provides: banner
# Required-Start:
# Required-Stop:
# Default-Start:     S
# Default-Stop:
### END INIT INFO

#check whether  is first run

TAGLINK_PATH=/home/sysuser
export TAGLINK_PATH

#set device config
cat /proc/mounts  | grep root | grep rw > /dev/null
if [ $? == "0" ];then
        RO=0
else
        RO=1
fi

echo $RO

if [ $RO == "1" ];then
 mount -o remount,rw /
fi

/usr/sbin/update-modules

 sync
 sync
if [ $RO == "1" ];then
 mount -o remount,ro /
fi


exit 0
