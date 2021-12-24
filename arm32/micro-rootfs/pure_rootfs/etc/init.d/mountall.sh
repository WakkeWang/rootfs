#!/bin/sh
### BEGIN INIT INFO
# Provides:          mountall
# Required-Start:    mountvirtfs
# Required-Stop: 
# Default-Start:     S
# Default-Stop:
# Short-Description: Mount all filesystems.
# Description:
### END INIT INFO

. /etc/default/rcS

HN=`cat /proc/board | tr A-Z a-z`
if [ -e /dev/mtd9 ] && [ -b /dev/mtdblock9 ]; then
	if [ "$HN" == "wise2834" ] || [ "$HN" == "adam67c1" ]; then
		# attach data partition
		if [ ! -c /dev/ubi1 ]; then
			ubiattach -p /dev/mtd10 -O 1024
		fi
		if [ ! -c /dev/ubi1_0 ]; then
			ubimkvol /dev/ubi1 -N data -m
		fi
	else
		# attach recovery partition
		if [ ! -c /dev/ubi1 ]; then
			ubiattach -p /dev/mtd10 -O 1024
		fi
		if [ ! -c /dev/ubi1_0 ]; then
			ubimkvol /dev/ubi1 -N recovery -m
		fi
		# attach data partition
		if [ ! -c /dev/ubi2 ]; then
			ubiattach -p /dev/mtd11 -O 1024
		fi
		if [ ! -c /dev/ubi2_0 ]; then
			ubimkvol /dev/ubi2 -N data -m
		fi
	fi
fi

#
# Mount local filesystems in /etc/fstab. For some reason, people
# might want to mount "proc" several times, and mount -v complains
# about this. So we mount "proc" filesystems without -v.
#
test "$VERBOSE" != no && echo "Mounting local filesystems..."
mount -at nonfs,nosmbfs,noncpfs 2>/dev/null

#
# We might have mounted something over /dev, see if /dev/initctl is there.
#
if test ! -p /dev/initctl
then
	rm -f /dev/initctl
	mknod -m 600 /dev/initctl p
fi
kill -USR1 1

#
# Execute swapon command again, in case we want to swap to
# a file on a now mounted filesystem.
#
swapon -a 2> /dev/null


: exit 0

