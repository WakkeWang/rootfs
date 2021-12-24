#!/bin/bash
### BEGIN INIT INFO
# Provides:          Advantech
# Required-Start:    None
# Required-Stop:     None
# Default-Start:     0
# Default-Stop:      0 
# Short-Description: start XXX
# Description:       start XXX
### END INIT INFO


logger "================================"
logger "Running Advantech programming...."
logger "================================"

/etc/init.d/hostname.sh start

HN=`cat /proc/board | tr A-Z a-z`

eth_num=`ifconfig -a | grep eth | wc -l`

for con in `ls /etc/NetworkManager/system-connections` ;
do
	nmcli con del $con
done
killall dhclient
rm -rf /etc/NetworkManager/system-connections/* 
sync

for i in $(seq 0 `expr $eth_num - 1`)
do
	echo "Setting eth$i network..."
	nmcli con add con-name eth$i type Ethernet ifname eth$i
	nmcli con modify eth$i connection.autoconnect-priority 10 ipv4.may-fail no ipv4.dhcp-timeout 8

	nmcli con add con-name eth${i}-default type Ethernet ifname eth${i} ip4 1${i}.0.0.1/24
	nmcli con modify eth${i}-default connection.autoconnect-priority 2 ipv4.may-fail no

	if [ "`cat /sys/class/net/eth${i}/carrier`" == "1" ];then
        if ! nmcli con up eth$i ;then
                if ! nmcli con up eth$i ;then
                        nmcli con up eth${i}-default
                fi
        fi
	fi
done


if [ "$HN" == "ecu1155" ];then
    ln -s /dev/ttymxc1 /dev/ttyAP0
    ln -s /dev/ttymxc2 /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
    ln -s /dev/spidev2.1 /dev/spidev1.0
	ln -s /dev/spidev3.0 /dev/spidev2.0
	ln -sf /sys/class/spi_master/spi1/spi1.0/fram /dev/fram
elif [ "$HN" == "ecu1253" ]; then  
    ln -s /dev/ttyS0 /dev/ttyAP0   
    ln -s /dev/ttyS1 /dev/ttyAP1   
    ln -s /dev/ttyS5 /dev/ttyAP2   
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP2
fi

export TAGLINK_PATH=/home/root
if [ -s $TAGLINK_PATH/driver/gpioinfo.ko ]; then
    insmod $TAGLINK_PATH/driver/gpioinfo.ko
elif [ -s /home/root/driver/gpioinfo.ko ]; then
    insmod /home/root/driver/gpioinfo.ko
fi
if [ -s $TAGLINK_PATH/driver/biokernbase.ko ]; then
    insmod $TAGLINK_PATH/driver/biokernbase.ko
elif [ -s /home/root/driver/biokernbase.ko ]; then
    insmod /home/root/driver/biokernbase.ko
fi
if [ -s $TAGLINK_PATH/driver/adam3600io.ko ]; then
    insmod $TAGLINK_PATH/driver/adam3600io.ko
elif [ -s /home/root/driver/adam3600io.ko ]; then
    insmod /home/root/driver/adam3600io.ko
fi
if [ -s $TAGLINK_PATH/driver/boardio.ko ]; then
    insmod $TAGLINK_PATH/driver/boardio.ko
elif [ -s /home/root/driver/boardio.ko ]; then
    insmod /home/root/driver/boardio.ko
fi



echo 1 4 1 7 > /proc/sys/kernel/printk
echo -e "\033[9;0]" > /dev/tty1

