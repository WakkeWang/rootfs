#!/bin/sh
#
# Called from udev
#
# Attempt to mount any added block devices and umount any removed devices

MOUNT="/bin/mount"
PMOUNT="/usr/bin/pmount"
UMOUNT="/bin/umount"
for line in `grep -v ^# /etc/udev/mount.blacklist`
do
	if [ ` expr match "$DEVNAME" "$line" ` -gt 0 ];
	then
		logger "udev/mount.sh" "[$DEVNAME] is blacklisted, ignoring"
		exit 0
	fi
done

check_udisk() {                                                                                          
    case "$1" in                                                                                     
    /dev/sd[a-z][1-9])                                                                               
	OPTIONS=",flush"
    return 0                                                                                         
    ;;                                                                                               
    *)                                                                                               
    return 1                                                                                         
    ;;                                                                                               
    esac                                                                                             
}  

automount() {	
	name="`basename "$DEVNAME"`"

	! test -d "/media/$name" && mkdir -p "/media/$name"
	# Silent util-linux's version of mounting auto
	if [ "x`readlink $MOUNT`" = "x/bin/mount.util-linux" ] ;
	then
		MOUNT="$MOUNT -o silent"
	fi

    MMCDEVNAME="/dev/mmcblk1p1"
    if [ -e /dev/mtd0 ] || [ -e /dev/mmcblk1boot1 ]; then
        MMCDEVNAME="/dev/mmcblk0p1"
    else                                                    
        MMCDEVNAME="/dev/mmcblk1p1"
    fi

	if [ "$DEVNAME" = "$MMCDEVNAME" ] || check_udisk $DEVNAME; then
		if ! /usr/sbin/mount -t auto $DEVNAME "/media/$name"; then
            rm_dir "/media/$name"
        else
			fstype=`cat /proc/mounts | grep $DEVNAME | awk '{print $3}'`
			if [ "$fstype" = "vfat" ]; then
				logger "remount [/media/$name]"
				$UMOUNT "/media/$name"
				if ! fsck.vfat $DEVNAME -a
				then
					fsck.vfat $DEVNAME -y >> /dev/null
				fi
				if ! /usr/sbin/mount -t auto -o rw,uid=sysuser,gid=sysuser,utf8=1,errors=continue$OPTIONS $DEVNAME "/media/$name"
				then
            		rm_dir "/media/$name"
            	else
            		logger "mount.sh/automount" "Auto-mount of [/media/$name] successful"
					touch "/tmp/.automount-$name"
				fi				
			elif [ "$fstype" = "exfat" ]; then
				logger "remount [/media/$name]"
				$UMOUNT "/media/$name"
				if ! fsck.exfat $DEVNAME -a
				then
					fsck.exfat $DEVNAME -y >> /dev/null
				fi							
				if ! /usr/sbin/mount -t auto -o rw,uid=sysuser,gid=sysuser,errors=continue $DEVNAME "/media/$name"
				then
					rm_dir "/media/$name"
				else
					logger "mount.sh/automount" "Auto-mount of [/media/$name] successful"
					touch "/tmp/.automount-$name"
				fi							
			else
				chown -R sysuser:sysuser /media/$name && sync
				logger "mount.sh/automount" "Auto-mount of [/media/$name] successful"
				touch "/tmp/.automount-$name"
			fi
        fi
	else	
		if ! $MOUNT -t auto $DEVNAME "/media/$name"
		then
			#logger "mount.sh/automount" "$MOUNT -t auto $DEVNAME \"/media/$name\" failed!"
			rm_dir "/media/$name"
		else
			logger "mount.sh/automount" "Auto-mount of [/media/$name] successful"
			touch "/tmp/.automount-$name"
		fi
	fi
}
	
rm_dir() {
	# We do not want to rm -r populated directories
	if test "`find "$1" | wc -l | tr -d " "`" -lt 2 -a -d "$1"
	then
		! test -z "$1" && rm -r "$1"
	else
		logger "mount.sh/automount" "Not removing non-empty directory [$1]"
	fi
}

if [ "$ACTION" = "add" ] && [ -n "$DEVNAME" ]; then
	if [ -x "$PMOUNT" ]; then
		$PMOUNT $DEVNAME 2> /dev/null
	elif [ -x $MOUNT ]; then
    	$MOUNT $DEVNAME 2> /dev/null
	fi
	
	# If the device isn't mounted at this point, it isn't configured in fstab
	grep -q "^$DEVNAME " /proc/mounts || automount
	case "$DEVNAME" in
	/dev/sd[a-z][1-9])
        TAGLINK_PATH=`cat ${ROOTDIR}/etc/profile | grep TAGLINK_PATH | head -1 | awk -F = '{print $2}'`
        if [ "${TAGLINK_PATH}" = "" ]; then
            TAGLINK_PATH=/home/root
        fi
        if [ -f $TAGLINK_PATH/util/udisk_run.sh ]; then
            echo $DEVNAME >> /var/tmp/udisk_mnt.log
            export TAGLINK_PATH
            $TAGLINK_PATH/util/udisk_run.sh
        fi
        ;;
	esac
fi


if [ "$ACTION" = "remove" ] && [ -x "$UMOUNT" ] && [ -n "$DEVNAME" ]; then
	for mnt in `cat /proc/mounts | grep "$DEVNAME" | cut -f 2 -d " " `
	do
		$UMOUNT $mnt
	done
	
	# Remove empty directories from auto-mounter
	name="`basename "$DEVNAME"`"
	test -e "/tmp/.automount-$name" && rm_dir "/media/$name"
fi
