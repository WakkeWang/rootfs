#!/bin/sh

RET=`ifconfig -a | grep "usb"`
if [ "$?" == "0" ]; then
    ifconfig usb0 100.0.0.1 up
fi

exit 0
