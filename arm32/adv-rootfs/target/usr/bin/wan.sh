#!/bin/sh

if [ -z "$1" ]; then
echo "Usage: wan.sh unicom|cmnet|telecom [devicename]"
exit 1
fi

ppp-off ppp0 > /dev/null
#killall -9 pppd > /dev/null

rm -f /var/lock/LCK..ttyUSB* > /dev/null
LINKED=
if [ -z "$2" ] ; then
pppd call $1 &       
else                 
pppd call $1 $2 &
fi               
for i in $(seq 300); do
RET=`ifconfig | grep ppp0`
if [ "$RET" != "" ]; then
    route add default dev ppp0
    exit 0
else
    sleep 1
    LINKED=0
fi
done
if [ $LINKED ]; then  
    echo "NOT LINKED" > /dev/null 
	ppp-off ppp0 > /dev/null
    #killall -9 pppd > /dev/null
fi   

exit 0

