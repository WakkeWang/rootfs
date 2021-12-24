#!/bin/sh

# MINIPCIE POWER RESET AND MODULE RESET  

if [ "$1" != "PowerReset" ] && [ "$1" != "ModuleReset" ] && [ "$#" != "2" ];then
	echo ""
	echo "usage : minipcie_reset.sh PowerReset/ModuleReset BusNum"
	echo "ModuleReset only support : ECU1251, ECU1051, ECU1051E, ECU1050 or its ODM devices"
	echo "ADAM3600, ADAM3600DS, ECU1152 and its ODM devices only support PowerReset"
	echo ""
	exit 0
fi

# ECU1050 : BusNum = 1(GPIO3_15 + GPIO2_23) BusNum = 2 (GPIO3_16 + GPIO2_24)
# ADAM3600 : BusNum = 1(GPIO0_4)  BusNum = 2 (GPIO3_15)
# Other devices only have one minipcie slot (GPIO3_15)

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

minipcie2_power_reset_for_ecu1050()  # gpio3_16  for ecu1050
{
	/usr/bin/set_gpio.sh 3 16 1 >> /dev/null
	sleep 0.3
	/usr/bin/set_gpio.sh 3 16 0 >> /dev/null
	sleep 5
	/usr/bin/set_gpio.sh 3 16 1 >> /dev/null
	sleep 0.3
}

minipcie2_power_reset_for_adam3600()  # gpio0_4  for adam3600
{
	/usr/bin/set_gpio.sh 0 4 1 >> /dev/null
	sleep 0.3
	/usr/bin/set_gpio.sh 0 4 0 >> /dev/null
	sleep 5
	/usr/bin/set_gpio.sh 0 4 1 >> /dev/null
	sleep 0.3
}

minipcie1_module_reset()  # gpio2_23 for ecu1050 ecu1251 ecu1051 ecu1051e
{
	/usr/bin/set_gpio.sh 2 23 1 >> /dev/null
	sleep 0.3
	/usr/bin/set_gpio.sh 2 23 0 >> /dev/null
	sleep 0.3
	/usr/bin/set_gpio.sh 2 23 1 >> /dev/null
	sleep 0.3
}

minipcie2_module_reset()  # gpio2_24 for ecu1050
{
	/usr/bin/set_gpio.sh 2 24 1 >> /dev/null
	sleep 0.3
	/usr/bin/set_gpio.sh 2 24 0 >> /dev/null
	sleep 0.3
	/usr/bin/set_gpio.sh 2 24 1 >> /dev/null
	sleep 0.3
}

if [ "$HN" == "adam3600" ] || [ "$HN" == "adam3600ds" ] || [ "$HN" == "sys800" ] || [ "$HN" == "amcmq200n" ] || [ "$HN" == "tms10" ] || [ "$HN" == "ecu1152" ]; then

	if [ "$1" != "PowerReset" ];then
		echo "ADAM3600 only support Power Reset."
		exit 0
	fi

	# skip RS9113 and RS9116
	lsusb | grep "1618:911" >> /dev/null
	if [ "$?" == "0" ];then 
		busnum=`lsusb | grep "1618:911" | awk '{ print $2}'`
		if [ "$busnum" == "00$2" ];then  # RS9113 is in the same slot as BusNum
			echo "Detected RS9113 or RS9116, the module should not power reset at ADAM3600, ECU1152 ,exit"
			exit 0  
		fi
	fi 	
	
	if [ "$HN" == "ecu1152" ] || [ "$HN" == "adam3600ds" ] ;then
		minipcie1_power_reset
	else
		# BusNum = 1 GPIO0_4
		if [ "$2" == "1" ];then
			minipcie2_power_reset_for_adam3600
		fi	

		# BusNum = 2 GPIO3_15
		if [ "$2" == "2" ];then
			minipcie1_power_reset
		fi	
	fi

elif [ "$HN" == "ecu1050" ];then

	# remove RS9113 and RS9116 driver
	lsusb | grep "1618:911" >> /dev/null
	if [ "$?" == "0" ];then 
		sh /usr/local/RS9113_Driver/remove_all.sh
	fi

	if [ "$1" == "PowerReset" ];then
		# BusNum = 1 GPIO3_15 + GPIO2_23
		if [ "$2" == "1" ];then
			minipcie1_power_reset
			sleep 0.5
			minipcie1_module_reset
			sleep 0.5
		fi	

		# BusNum = 2 GPIO3_16 + GPIO2_24
		if [ "$2" == "2" ];then
			minipcie2_power_reset_for_ecu1050  # gpio3_16  for ecu1050
			sleep 0.5
			minipcie2_module_reset
			sleep 0.5
		fi	
	fi

	if [ "$1" == "ModuleReset" ];then
		# BusNum = 1 GPIO2_23
		if [ "$2" == "1" ];then
			minipcie1_module_reset
			sleep 0.5
		fi	

		# BusNum = 2 GPIO2_24
		if [ "$2" == "2" ];then
			minipcie2_module_reset
			sleep 0.5
		fi	
	fi


elif [ "$HN" == "ecu1251" ] || [ "$HN" == "ecu1051" ] || [ "$HN" == "sys800021" ] || [ "$HN" == "icg1120" ] || [ "$HN" == "ecu1051e" ]; then
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
                break
        fi
        sleep 1                         
done    
