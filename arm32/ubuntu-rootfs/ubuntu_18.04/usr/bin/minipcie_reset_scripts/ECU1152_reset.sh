#!/bin/sh

# MINIPCIE POWER RESET AND MODULE RESET  
# By Yafei.Wang

if [ "$1" != "PowerReset" ] && [ "$1" != "ModuleReset" ] && [ "$#" != "2" ];then
	echo ""
	echo "usage : minipcie_reset.sh PowerReset/ModuleReset BusNum"
	echo ""
	exit 0
fi

# ECU1152 : BusNum = 1(GPIO3_15)

if [ "$2" != "1" ] && [ "$2" != "2" ];then
	echo "No BusNum found :$2"
	exit 0
fi

HN=`cat /proc/board | tr A-Z a-z`                                                          

minipcie1_power_reset()  # gpio3_15
{
	/usr/bin/set_gpio.sh 3 15 1 >> /dev/null
	sleep 0.3
	/usr/bin/set_gpio.sh 3 15 0 >> /dev/null
	sleep 5
	/usr/bin/set_gpio.sh 3 15 1 >> /dev/null
	sleep 0.3
}


if [ "$HN" == "ecu1152" ]; then

	if [ "$1" != "PowerReset" ];then
		echo "ECU1152 only support Power Reset."
		exit 0
	fi

	# skip RS9113 and RS9116
	lsusb | grep "1618:911" >> /dev/null
	if [ "$?" == "0" ];then 
		busnum=`lsusb | grep "1618:911" | awk '{ print $2}'`
		if [ "$busnum" == "00$2" ];then  # RS9113 is in the same slot as BusNum
			echo "Detected RS9113 or RS9116, the module should not power reset at ECU1152 ,exit"
			exit 0  
		fi
	fi 	
	
	minipcie1_power_reset
else
	exit 0
fi

for i in $(seq 20); do 
    ls /dev/ttyUSB* -l 2> /dev/null
	if [ "$?" == "0" ];then
		echo "Modem initial Success...."         
        sleep 3 
		exit 0
	fi
	sleep 1
done

 
exit -1

