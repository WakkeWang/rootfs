#!/bin/bash
### BEGIN INIT INFO
# Provides:          Advantech
# Required-Start:    None
# Required-Stop:     None
# Default-Start:     0
# Default-Stop:      0 
# Short-Description: start XXX
# Description:       start XXX
### END INIT INFO

mount -o remount,rw /
/sbin/depmod -a
