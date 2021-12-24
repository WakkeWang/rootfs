#!/bin/sh
### BEGIN INIT INFO
# Provides: banner
# Required-Start:
# Required-Stop:
# Default-Start:     S
# Default-Stop:
### END INIT INFO

#mount /dev/ubi_0 for nand devcie
if [ -e /dev/ubi1_0 ];then
if [ ! -d /media/recovery ];then
   mkdir /media/recovery
fi
  echo "mount media recovery directory"
  mount -t ubifs /dev/ubi1_0 /media/recovery 
fi

#check whether  is first run
if [ ! -d /etc/etcbak ]; then
	exit 0
fi

TAGLINK_PATH=/home/sysuser
export TAGLINK_PATH

#set device env
first_run_link(){
 echo "set first run config"
 rm -rf /home/etc
 setcap "cap_net_bind_service=+eip" /usr/sbin/lighttpd
 mv /etc/etcbak /home/etc
}

#set edgelink evn
edgelink_env(){
echo "set edgelink env"
if [ -f $TAGLINK_PATH/.version ]; then
    ln -sf $TAGLINK_PATH/.version /etc/issue
fi
    ln -sf $TAGLINK_PATH/project/ntp.conf /etc/ntp.conf

if [ -d $TAGLINK_PATH ]; then
    sed "s#\/home\/root#$TAGLINK_PATH#g" -i /etc/lighttpd.conf && sync
fi
}

#set device config
 mount -o remount,rw /
 first_run_link
if [ -d $TAGLINK_PATH/project ]; then
   edgelink_env 
fi
 sync
 sync
 mount -o remount,ro /
exit 0
