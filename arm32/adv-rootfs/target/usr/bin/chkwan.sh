#!/bin/sh

if ifconfig ppp0 | grep -q "inet addr:" ; then
	echo "ppp0 is up."
else
	echo "ppp0 is down."
	/usr/bin/wan.sh $1
fi

exit 0

