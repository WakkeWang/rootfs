#!/bin/bash 

if [ "$#" != "1" ];then
        echo "usage: $0 [1/2]"
        echo "parameters and options:"
        echo "[ 1 -> SMI1 ] "
		echo "[ 2 -> SIM2 ] "
        exit 
fi

HN=`cat /proc/board | tr [A-Z] [a-z] `
echo "board name : $HN"


#ECU1051  	default GPIO2_25=0  
#ADAM3600DS default GPIO0_4 = 1

if [ "$HN" == "ecu1051" ] ||  [ "$HN" == "ecu1051e" ] || [ "$HN" == "ecu1051b" ] || [ "$HN" == "ecu1051bg" ] ||  [ "$HN" == "sys800022" ];then
    if [ "$1" == "1" ];then
		echo "switch to SIM1"
		/usr/bin/set_gpio.sh 2 25 0 > /dev/null
	elif [ "$1" == "2" ];then
		/usr/bin/set_gpio.sh 2 25 1 > /dev/null
	else
		echo "input error"
		exit
	fi
fi

if [ "$HN" == "adam3600ds" ];then
    if [ "$1" == "1" ];then
		echo "switch to SIM1"
		/usr/bin/set_gpio.sh 0 4 1 > /dev/null
	elif [ "$1" == "2" ];then
		/usr/bin/set_gpio.sh 0 4 0 > /dev/null
	else
		echo "input error"
		exit
	fi
fi

/usr/bin/minipcie_reset.sh PowerReset 1

exit 0

