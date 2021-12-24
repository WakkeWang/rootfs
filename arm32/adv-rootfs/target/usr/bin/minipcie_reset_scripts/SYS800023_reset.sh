#!/bin/sh

# MINIPCIE POWER RESET AND MODULE RESET  
# By Yafei.Wang

if [ "$1" != "PowerReset" ] && [ "$1" != "ModuleReset" ] && [ "$#" != "2" ];then
	echo ""
	echo "usage : minipcie_reset.sh PowerReset/ModuleReset BusNum"
	echo ""
	exit 0
fi

# SYS800023 : BusNum = 1(GPIO3_15 + GPIO2_23)

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

minipcie1_module_reset()  # gpio2_23 for ecu1050 ecu1251 ecu1051 
{
	/usr/bin/set_gpio.sh 2 23 1 >> /dev/null
	sleep 0.3
	/usr/bin/set_gpio.sh 2 23 0 >> /dev/null
	sleep 0.3
	/usr/bin/set_gpio.sh 2 23 1 >> /dev/null
	sleep 0.3
}

if [ "$HN" == "sys800023" ]; then
	# remove RS9113 and RS9116 driver
	lsusb | grep "1618:911" >> /dev/null
	if [ "$?" == "0" ];then 
		sh /usr/local/RS9113_Driver/remove_all.sh
	fi

	if [ "$1" == "PowerReset" ];then
		minipcie1_power_reset
		sleep 0.5
		minipcie1_module_reset
		sleep 0.5
	fi

	if [ "$1" == "ModuleReset" ];then
		minipcie1_module_reset
		sleep 0.5
	fi
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

