#!/bin/sh

if [ -z "$1" ]; then
echo "Usage: wlan.sh up/down"
exit 1
fi

Dail_up()
{
	ps aux | grep -v grep | grep wpa_supplicant > /dev/null 
	if [ "$?" == "0" ]; then
		killall wpa_supplicant
	fi

	ifconfig wlan0 up
	lsusb | grep "148f:5370" >/dev/null # for RT5390
	if [ "$?" == "0" ];then
		wpa_supplicant -B -Dwext -i wlan0 -c /etc/wpa_supplicant.conf -ddddt
	else
		wpa_supplicant -B -Dnl80211,wext -i wlan0 -c /etc/wpa_supplicant.conf -ddddt
	fi
	ifup wlan0 
}

LINKED=
if [ "$1" = "up" ]; then
	wpa_cli terminate 2> /dev/null
	ps aux | grep -E "wpa_supplicant" | grep -v "grep" | awk '{print $1}' | xargs kill -9 2>/dev/null
	if [ -f /var/run/udhcpc.wlan0.pid ]; then
		kill -9 `cat /var/run/udhcpc.wlan0.pid` 2> /dev/null
	fi
	sleep 1
	if [ -f /etc/wpa_supplicant.conf ]; then
	if ifconfig wlan0 | grep -q "inet addr:" ; then
		ifdown wlan0
		ip addr flush dev wlan0
	fi
	Dail_up
	#iwlist wlan0 scan > /dev/null
	for i in $(seq 90); do
		wpa_cli -i wlan0 select_network 0
		sleep 1
		if ! ifconfig wlan0 | grep -q "inet addr:" ; then
			#udhcpc -t 5 -R -n -p /var/run/udhcpc.wlan0.pid -i wlan0
			Dail_up
		elif  ifconfig wlan0 | grep -q "inet addr:" ; then
			iw wlan0 set power_save off
			if [ -x ${TAGLINK_PATH}/util/fixroute ]; then
                	        ${TAGLINK_PATH}/util/fixroute
                	fi
			exit 0
		else
			sleep 1
			LINKED=0
		fi
	done
	if [ $LINKED ]; then
		echo "NOT LINKED" > /dev/null
		ps aux | grep -E "wpa_supplicant" | grep -v "grep" | awk '{print $1}' | xargs kill -9 2>/dev/null
	fi
	fi
fi

if [ "$1" = "down" ]; then
	wpa_cli terminate 2> /dev/null
	ps aux | grep -E "wpa_supplicant" | grep -v "grep" | awk '{print $1}' | xargs kill -9 2>/dev/null
	if [ -f /var/run/udhcpc.wlan0.pid ]; then
		kill -9 `cat /var/run/udhcpc.wlan0.pid` 2> /dev/null
	fi
	ifdown wlan0
fi

exit 0

