#!/bin/sh

case "$1" in
    start )
        ;;
    stop )
        exit 0
        ;;
esac

if [ -d /usr/local/net-snmp ]; then
    export SNMP_HOME=/usr/local/net-snmp
    export PATH=$PATH:${SNMP_HOME}/sbin:${SNMP_HOME}/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${SNMP_HOME}/lib
fi

TAGLINK_PATH=/home/sysuser
export TAGLINK_PATH
HN=`cat /proc/board | tr A-Z a-z`

if [ "$HN" == "adam3600" ] || [ "$HN" == "adam3600ds" ] || [ "$HN" == "amcmq200n" ];then
	if ! busybox lsusb | grep "0424:2512" | grep -v grep
	then
		echo "Can not find USB hub, will reboot"
    	reboot 
	fi	
fi

if [ -s $TAGLINK_PATH/driver/smscusbnet.ko ] && [ -s $TAGLINK_PATH/driver/smsc9500.ko ]; then
	insmod $TAGLINK_PATH/driver/smscusbnet.ko
	insmod $TAGLINK_PATH/driver/smsc9500.ko
fi

if [ -d $TAGLINK_PATH/bin ]; then
    PATH=$PATH:$TAGLINK_PATH/bin:$TAGLINK_PATH/util:$TAGLINK_PATH/user
    export PATH
fi

if [ -d $TAGLINK_PATH/lib ]; then
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TAGLINK_PATH/lib
    export LD_LIBRARY_PATH
fi
export LD_PRELOAD=/lib/preloadable_libiconv.so

if [ -d /usr/lib/jvm/java8/jre ]; then
    export JAVA_HOME=/usr/lib/jvm/java8/jre
    export CLASSPATH=.:${JAVA_HOME}/lib:${JAVA_HOME}/lib/ext/ojdbc6.jar
    export PATH=$PATH:${JAVA_HOME}/bin                                 
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${JAVA_HOME}/lib/arm:${JAVA_HOME}/lib/arm/client
fi

if [ -s /lib/modules/$(uname -r)/kernel/drivers/usb/class/cdc-acm.ko ]; then
    /sbin/modprobe -r cdc-acm
fi

if [ "$HN" == "ecu4553" ];then
	/sbin/modprobe dm9000
fi

if [ "$HN" == "ecu4553l" ];then
    /sbin/modprobe c_can_platform
	/sbin/modprobe smsc75xx
	if ! ifconfig -a | grep eth2 || ! ifconfig -a | grep eth3;then 
		# reset usb hub
		set_gpio.sh 0 7 reset
		sleep 2
		ifup eth2
		ifup eth3
	fi
fi

ME3760ID=19d2:0199
RET=`busybox lsusb | grep $ME3760ID | awk '{print $6}'`
if [ "$RET" == "$ME3760ID" ];then
	/sbin/modprobe qmi_wwan
	ifconfig wwan0 up
fi

line=`ifconfig -a | grep "eth" | wc -l`                                                         

if [ "$HN" != "ecu4553l" ];then
	for ((num=0;num<$((line));num=num+1))
	do
		/etc/udev/scripts/eth.sh eth$num
	done    
	for ((num=$((line));num<18;num=num+1))                                                          
	do
		if [ -e /etc/network/interfaces.d/eth$num ];then                                        
			rm /etc/network/interfaces.d/eth$num                                            
		fi  
		grep "eth$num" /etc/network/interfaces > /dev/null                                      
		if [ "$?" == "0" ];then                                                                 
			sed "/eth$num/d" -i /etc/network/interfaces                                     
		fi    
	done                                                               
fi

for ((i=0;i<$((line));i=i+1))                                                           
do
	busybox ifplugd -d 2 -I -i eth$i -r /etc/network/if.sh
done
ifup lo

#move to utilcheck.sh
#/usr/sbin/update-modules

if [ -L "/sys/bus/usb/drivers/usb/usb1" ] || [ -L "/sys/bus/usb/drivers/usb/usb2" ]; then
RT5370_ID=148f:5370
RET=`busybox lsusb | grep $RT5370_ID | awk '{print $6}'`
if [[ $RET == "$RT5370_ID" ]]; then
	/sbin/insmod /lib/modules/$(uname -r)/updates/rt5370sta.ko
fi
LILY_W131_ID=1286:2049
LILY_W131_ID2=1286:204a
MOD_ID=`busybox lsusb | grep $LILY_W131_ID | awk '{print $6}'`
MOD_ID2=`busybox lsusb | grep $LILY_W131_ID2 | awk '{print $6}'`
if [[ $MOD_ID == "$LILY_W131_ID" ]] || [[ $MOD_ID2 == "$LILY_W131_ID2" ]]; then
    /sbin/modprobe usb8801 cfg80211_wext=0xf drv_mode=1 sta_name="wlan"
fi
CH340_ID=1a86:7523
RET=`busybox lsusb | grep $CH340_ID | awk '{print $6}'`
if [[ $RET == "$CH340_ID" ]]; then
    /sbin/modprobe ch34x
fi
/sbin/modprobe tun
/sbin/modprobe option
/sbin/modprobe ti_am335x_adc
AMP570_ID=1ecb:0202
RET=`busybox lsusb | grep $AMP570_ID | awk '{print $6}'`
if [[ $RET == "$AMP570_ID" ]]; then
    /sbin/modprobe -r option
    /sbin/modprobe -r usb_wwan
    /sbin/modprobe -r cdc-acm
    /sbin/modprobe cdc-acm
    /sbin/modprobe usb_wwan
    /sbin/modprobe option
fi
fi

iptables-restore < /etc/iptables.up.rules
if [ -e /dev/mmcblk0p4 ]; then
    if [ -d "/media/mmcblk0p4" ]; then
        rm -rf /media/mmcblk0p4
        sync
    fi

    if [ ! -L "/media/mmcblk0p4" ]; then
        ln -s /home /media/mmcblk0p4
        sync
    fi
fi

if [ -e /dev/mmcblk0p3 ]; then                                                 
    UPDIR=/media/mmcblk0p3                                             
elif [ -e /dev/ubi1_0 ]; then                                                               
    UPDIR=/media/recovery                                             
fi                                                         
if [ -d "$UPDIR" ]; then                                
    mkdir -p $UPDIR/uploads                                                    
    chown -R sysuser:sysuser $UPDIR/uploads                                    
    sync                                                               
fi

#if [ -f $TAGLINK_PATH/.version ]; then
#    ln -sf $TAGLINK_PATH/.version /etc/issue 
#fi

#if [ -d $TAGLINK_PATH ]; then
#    sed "s#\/home\/root#$TAGLINK_PATH#g" -i /etc/lighttpd.conf && sync
#fi

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
elif [ "$HN" == "ecu1051" ] || [ "$HN" == "ecu1051e" ] || [ "$HN" == "ecu1051b" ] || [ "$HN" == "ecu1051bg" ] || [ "$HN" == "ecu1251d" ] || [ "$HN" == "sys800023" ] || [ "$HN" == "sys800024" ]; then
    ln -s /dev/ttyO1 /dev/ttyAP0   
    ln -s /dev/ttyO2 /dev/ttyAP1   
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
    if [ "$HN" == "ecu1051b" ] || [ "$HN" == "ecu1051bg" ] || [ "$HN" == "ecu1251d" ] || [ "$HN" == "sys800023" ];then
        ln -sf /sys/class/spi_master/spi1/spi1.0/fram /dev/fram
    fi
elif [ "$HN" == "ecu1050" ] || [ "$HN" == "sys800024" ]; then  
    ln -s /dev/ttyO3 /dev/ttyAP0   
    ln -s /dev/ttyO4 /dev/ttyAP1   
    chown -h root:dialout /dev/ttyAP0
    chown -h root:dialout /dev/ttyAP1
elif [ "$HN" == "wise2834" ]; then  
    ln -s /dev/ttyS0 /dev/ttyAP0   
    chown -h root:dialout /dev/ttyAP0
elif [ "$HN" == "adam67c1" ] || [ "$HN" == "adam6750" ] || [ "$HN" == "adam6717" ] || [ "$HN" == "adam6760d" ]; then  
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

ulimit -S -c 0 > /dev/null 2>&1
#ulimit -c unlimited
#echo "$TAGLINK_PATH/bin/core_%e_%s_%t" > /proc/sys/kernel/core_pattern
# only executable filename
echo "$TAGLINK_PATH/bin/core_%e" > /proc/sys/kernel/core_pattern

# Load RS9113/RS9116 Driver
RS_SIG=0
if busybox lsusb | grep "1618:9113" 2> /dev/null;then
	RS_SIG=3
fi
if busybox lsusb | grep "1618:9116" 2> /dev/null;then
	RS_SIG=6
fi

if [ "$HN" != "ecu4553l" ];then
	if [ $RS_SIG -gt 0 ];then
		/usr/local/RS911${RS_SIG}_Driver/rs911${RS_SIG}_drv_enable.sh sta 
		ifconfig rpine0 up
		ifconfig wlan0 up
		hciconfig hci0 up
	fi
fi

sh /etc/init.d/sd_detect.sh pre_exec front

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
if [ -s $TAGLINK_PATH/driver/adam5630io.ko ]; then
    insmod $TAGLINK_PATH/driver/adam5630io.ko
fi                                   
if [ -x $TAGLINK_PATH/bin/isa_tool ]; then                                                  
    $TAGLINK_PATH/bin/isa_tool -a -p 0x04000000 -n bio5630 -m adam5630io
fi
if [ -s $TAGLINK_PATH/driver/adam5117.ko ]; then
    insmod $TAGLINK_PATH/driver/adam5117.ko
fi                                   
if [ "$HN" == "amcmq200n" ]; then
    if [ -f /media/mmcblk1p1/BIOT_CERT.cer ]; then
        cp -f /media/mmcblk1p1/BIOT_CERT.cer /opt/app_conf/certificates
    fi
fi
if [ "$HN" == "adam5630" ]; then
    if [ -f $TAGLINK_PATH/project/snmpd.conf ]; then
        snmpd -Lf /var/log/snmpd.log -DlibadvantechIOCommon,dlmod -c $TAGLINK_PATH/project/snmpd.conf
    fi
fi
if [ -x $TAGLINK_PATH/util/AdvFirmupdate ]; then
    $TAGLINK_PATH/util/AdvFirmupdate -u
elif [ -x /home/root/util/AdvFirmupdate ]; then
    /home/root/util/AdvFirmupdate -u
fi
if [ -x $TAGLINK_PATH/bin/AdvProgramMgr ]; then
    $TAGLINK_PATH/bin/AdvProgramMgr -d
elif [ -x /home/root/bin/AdvProgramMgr ]; then
    /home/root/bin/AdvProgramMgr -d
elif [ -x /home/root/bin/AdvAgentMain ]; then
    /home/root/bin/AdvAgentMain -d
fi
if [ -s $TAGLINK_PATH/driver/irig.ko ]; then
    insmod $TAGLINK_PATH/driver/irig.ko
elif [ -s /home/root/driver/irig.ko ]; then
    insmod /home/root/driver/irig.ko
fi
if [ -x $TAGLINK_PATH/bin/wdtd ]; then
    $TAGLINK_PATH/bin/wdtd -d
elif [ -x /home/root/bin/wdtd ]; then
    /home/root/bin/wdtd -d
fi

echo 1 4 1 7 > /proc/sys/kernel/printk
echo -e "\033[9;0]" > /dev/tty1

sh /etc/init.d/sd_detect.sh post_exec background
