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


logger "===== Running Advantech programming ======"


HN=`cat /proc/board | tr A-Z a-z`

eth_num=`ls /sys/class/net | grep eth |  wc -l`

for con in `ls /etc/NetworkManager/system-connections` ;
do
	nmcli con del $con
done
rm -rf /etc/NetworkManager/system-connections/* 
sync

for i in $(seq 0 `expr $eth_num - 1`)
do
	echo "Setting eth$i network..."
	nmcli con add con-name eth$i type Ethernet ifname eth$i
	nmcli con modify eth$i connection.autoconnect-priority 10 ipv4.may-fail no ipv4.dhcp-timeout 8

	nmcli con add con-name eth${i}-default type Ethernet ifname eth${i} ip4 1${i}.0.0.1/24
	nmcli con modify eth${i}-default connection.autoconnect-priority 2 ipv4.may-fail no
	
	ifconfig eth${i} up
	sleep 1

	if [ "`cat /sys/class/net/eth${i}/carrier`" == "1" ];then
        if ! nmcli con up eth$i ;then
                if ! nmcli con up eth$i ;then
                        nmcli con up eth${i}-default
                fi
        fi
	fi
done
if ifconfig -a | grep wlan0 > /dev/null;then
	ifconfig wlan0 down
	sleep 1
	ifconfig wlan0 up
fi

if [ "$HN" == "ecu1253" ];then
	ln -sf /dev/rtc0 /dev/rtc 
else
	ln -sf /dev/rtc1 /dev/rtc 
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

############ disk mount ###########
for i in `ls /dev/mmcblk*`
do
        BASENAME=`basename $i`
        DEVNAME=/dev/$BASENAME

        if cat /proc/mounts | grep "^$DEVNAME" >/dev/null;then
                continue
        fi
        if cat /etc/fstab | grep "^$DEVNAME" >/dev/null;then
                continue
        fi
        /usr/local/bin/disk-mount.sh add $BASENAME
done

for i in `ls /dev/sd[a-z][1-9]*`
do
        BASENAME=`basename $i`
        DEVNAME=/dev/$BASENAME

        if cat /proc/mounts | grep "^$DEVNAME" >/dev/null;then
                continue
        fi
        if cat /etc/fstab | grep "^$DEVNAME" >/dev/null;then
                continue
        fi
        /usr/local/bin/disk-mount.sh add $BASENAME
done



if [ "$HN" == "adam3600" ] || [ "$HN" == "adam3600ds" ] || [ "$HN" == "sys800" ] || [ "$HN" == "amcmq200n" ]; then
    ln -s /dev/ttyS0 /dev/ttyAP0
    ln -s /dev/ttyS1 /dev/ttyAP1
    ln -s /dev/ttyS2 /dev/ttyAP2
    ln -s /dev/ttyO1 /dev/ttyAP3
    ln -s /dev/ttyO3 /dev/ttyAP4
    ln -sf /dev/ttyO1 /dev/ttyS3
    ln -sf /dev/ttyO3 /dev/ttyS4
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP2
    chown -h root:dialout /dev/ttyAP3
    chown -h root:dialout /dev/ttyAP4
    chown -h root:dialout /dev/ttyS3
    chown -h root:dialout /dev/ttyS4
elif [ "$HN" == "ecu1152" ]; then
    ln -s /dev/ttyS0 /dev/ttyAP0
    ln -s /dev/ttyS1 /dev/ttyAP1
    ln -s /dev/ttyS2 /dev/ttyAP2
    ln -s /dev/ttyS3 /dev/ttyAP3
    ln -s /dev/ttyS4 /dev/ttyAP4
    ln -s /dev/ttyS5 /dev/ttyAP5
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP2
    chown -h root:dialout /dev/ttyAP3
elif [ "$HN" == "ecu1252" ]; then
    ln -s /dev/ttyO1 /dev/ttyAP0
    ln -s /dev/ttyO2 /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
elif [ "$HN" == "ecu1251" ] || [ "$HN" == "sys800021" ]; then
    ln -s /dev/ttyO1 /dev/ttyAP0
    ln -s /dev/ttyO2 /dev/ttyAP1
    ln -s /dev/ttyO3 /dev/ttyAP2
    ln -s /dev/ttyO4 /dev/ttyAP3
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP2
    chown -h root:dialout /dev/ttyAP3
elif [ "$HN" == "wise4610" ]; then
    ln -s /dev/ttyO1 /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP0
elif [ "$HN" == "ecu4552" ]; then
    ln -s /dev/ttyS0 /dev/ttyAP0
    ln -s /dev/ttyS1 /dev/ttyAP1
    ln -s /dev/ttyS2 /dev/ttyAP2
    ln -s /dev/ttyS3 /dev/ttyAP3
    ln -s /dev/ttyS4 /dev/ttyAP4
    ln -s /dev/ttyS5 /dev/ttyAP5
    ln -s /dev/ttyS6 /dev/ttyAP6
    ln -s /dev/ttyS7 /dev/ttyAP7
    ln -s /dev/ttyS8 /dev/ttyAP8
    ln -s /dev/ttyS9 /dev/ttyAP9
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP2
    chown -h root:dialout /dev/ttyAP3
    chown -h root:dialout /dev/ttyAP4
    chown -h root:dialout /dev/ttyAP5
    chown -h root:dialout /dev/ttyAP6
    chown -h root:dialout /dev/ttyAP7
    chown -h root:dialout /dev/ttyAP8
    chown -h root:dialout /dev/ttyAP9
elif [ "$HN" == "ecu4553" ]; then
    ln -s /dev/ttyS0 /dev/ttyAP0
    ln -s /dev/ttyS1 /dev/ttyAP1
    ln -s /dev/ttyS2 /dev/ttyAP2
    ln -s /dev/ttyS3 /dev/ttyAP3
    ln -s /dev/ttyS4 /dev/ttyAP4
    ln -s /dev/ttyS5 /dev/ttyAP5
    ln -s /dev/ttyS6 /dev/ttyAP6
    ln -s /dev/ttyS7 /dev/ttyAP7
    ln -s /dev/ttyS8 /dev/ttyAP8
    ln -s /dev/ttyS9 /dev/ttyAP9
    ln -s /dev/ttyS10 /dev/ttyAP10
    ln -s /dev/ttyS11 /dev/ttyAP11
    ln -s /dev/ttyS12 /dev/ttyAP12
    ln -s /dev/ttyS13 /dev/ttyAP13
    ln -s /dev/ttyS14 /dev/ttyAP14
    ln -s /dev/ttyS15 /dev/ttyAP15
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP2
    chown -h root:dialout /dev/ttyAP3
    chown -h root:dialout /dev/ttyAP4
    chown -h root:dialout /dev/ttyAP5
    chown -h root:dialout /dev/ttyAP6
    chown -h root:dialout /dev/ttyAP7
    chown -h root:dialout /dev/ttyAP8
    chown -h root:dialout /dev/ttyAP9
    chown -h root:dialout /dev/ttyAP10
    chown -h root:dialout /dev/ttyAP11
    chown -h root:dialout /dev/ttyAP12
    chown -h root:dialout /dev/ttyAP13
    chown -h root:dialout /dev/ttyAP14
    chown -h root:dialout /dev/ttyAP15
elif [ "$HN" == "ecu4553l" ]; then
    ln -s /dev/ttyS0 /dev/ttyAP0
    ln -s /dev/ttyS1 /dev/ttyAP1
    ln -s /dev/ttyS2 /dev/ttyAP2
    ln -s /dev/ttyS3 /dev/ttyAP3
    ln -s /dev/ttyS4 /dev/ttyAP4
    ln -s /dev/ttyS5 /dev/ttyAP5
    ln -s /dev/ttyS6 /dev/ttyAP6
    ln -s /dev/ttyS7 /dev/ttyAP7
    ln -s /dev/ttyS8 /dev/ttyAP8
    ln -s /dev/ttyS9 /dev/ttyAP9
    ln -s /dev/ttyS10 /dev/ttyAP10
    ln -s /dev/ttyS11 /dev/ttyAP11
    ln -s /dev/ttyS12 /dev/ttyAP12
    ln -s /dev/ttyS13 /dev/ttyAP13
    ln -s /dev/ttyS14 /dev/ttyAP14
    ln -s /dev/ttyS15 /dev/ttyAP15
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP2
    chown -h root:dialout /dev/ttyAP3
    chown -h root:dialout /dev/ttyAP4
    chown -h root:dialout /dev/ttyAP5
    chown -h root:dialout /dev/ttyAP6
    chown -h root:dialout /dev/ttyAP7
    chown -h root:dialout /dev/ttyAP8
    chown -h root:dialout /dev/ttyAP9
    chown -h root:dialout /dev/ttyAP10
    chown -h root:dialout /dev/ttyAP11
    chown -h root:dialout /dev/ttyAP12
    chown -h root:dialout /dev/ttyAP13
    chown -h root:dialout /dev/ttyAP14
    chown -h root:dialout /dev/ttyAP15
elif [ "$HN" == "adam5630" ]; then
    ln -s /dev/ttyO4 /dev/ttyAP0
    ln -s /dev/ttyO1 /dev/ttyAP1
    ln -s /dev/ttyO5 /dev/ttyAP2
    ln -s /dev/ttyS0 /dev/ttyAP3
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP2
    chown -h root:dialout /dev/ttyAP3
    ln -s /dev/mtd12 /dev/sram
elif [ "$HN" == "ecu1051" ] || [ "$HN" == "ecu1051e" ] || [ "$HN" == "ecu1051b" ] || [ "$HN" == "ecu1051bg" ]; then
    ln -s /dev/ttyO1 /dev/ttyAP0
    ln -s /dev/ttyO2 /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
    if [ "$HN" == "ecu1051b" ] || [ "$HN" == "ecu1051bg" ];then
        ln -sf /sys/class/spi_master/spi1/spi1.0/fram /dev/fram
    fi
elif [ "$HN" == "ecu1050" ]; then
    ln -s /dev/ttyO3 /dev/ttyAP0
    ln -s /dev/ttyO4 /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
elif [ "$HN" == "wise2834" ]; then
    ln -s /dev/ttyS0 /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP0
elif [ "$HN" == "adam67c1" ] || [ "$HN" == "adam6750" ] || [ "$HN" == "adam6717" ]; then
    ln -s /dev/ttyO1 /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP0
    ln -s /dev/ttyO4 /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP0
    /sbin/modprobe g_ether
elif [ "$HN" == "ecu1155" ]; then
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
elif [ "$HN" == "ecu1650" ]; then
    ln -s /dev/ttyS1 /dev/ttyAP0
    ln -s /dev/ttyS2 /dev/ttyAP1
    ln -s /dev/ttyS3 /dev/ttyAP2
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP2
else
    ln -s /dev/ttyS0 /dev/ttyAP0
    ln -s /dev/ttyS1 /dev/ttyAP1
    ln -s /dev/ttyS2 /dev/ttyAP2
    ln -s /dev/ttyO1 /dev/ttyAP3
    ln -s /dev/ttyO3 /dev/ttyAP4
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
    chown -h root:dialout /dev/ttyAP2
    chown -h root:dialout /dev/ttyAP3
    chown -h root:dialout /dev/ttyAP4
    chown -h root:dialout /dev/ttyAP5
fi


echo 1 4 1 7 > /proc/sys/kernel/printk
echo -e "\033[9;0]" > /dev/tty1

exit 0
