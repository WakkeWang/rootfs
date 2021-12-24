#!/bin/sh

first_time=0                                          
if [ ! -f /etc/modules.dep ]; then             
    first_time=1                                                       
fi                                                                              
                                                                                          
if [ $first_time -eq 1 ] && [ ! -e /bin/systemctl ]; then
    mount -o remount,rw /
    depmod -a && sync
    echo 1 > /etc/modules.dep                                                                                           
    sync;sync;
    mount -o remount,rw /
fi                  

exit 0
