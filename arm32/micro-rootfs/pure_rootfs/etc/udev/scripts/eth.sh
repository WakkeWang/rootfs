#!/bin/sh

if [ ! -f /etc/network/interfaces.d/$1 ];then
	touch /etc/network/interfaces.d/$1
	echo "auto $1" >> /etc/network/interfaces.d/$1
	echo "iface $1 inet dhcp" >> /etc/network/interfaces.d/$1
	echo "allow-hotplug $1" >> /etc/network/interfaces.d/$1 
fi

grep "$1" /etc/network/interfaces > /dev/null
if [ "$?" != "0" ];then
	echo "source /etc/network/interfaces.d/$1" >> /etc/network/interfaces
fi
