#!/bin/sh 

HN=`cat /proc/board | tr A-Z a-z`
FSCK_CMD="fsck.ext3"
BOOT_PART="/dev/mmcblk0p1"
RECOVERY_PART="/dev/mmcblk0p3"
DATA_PART="/dev/mmcblk0p4"
EMMC_BOOT1_PART="/dev/mmcblk1boot1"
SD_CARD_PART="/dev/mmcblk1p1"

SD_CARD_FSCK()
{
	DEVNAME=$1  # may be /dev/mmcblk0p1
	NAME=`basename $1`   # mmcblk0p1
	
	if [ -e $DEVNAME ];then
		mkdir -p /media/$NAME
		if  /usr/sbin/mount -t auto $DEVNAME /media/$NAME ;then
			fstype=`cat /proc/mounts | grep $DEVNAME | awk '{print $3}'`
			/bin/umount /media/$NAME
			if [ "$fstype" = "vfat" ]; then				
				if ! fsck.vfat $DEVNAME -a
				then
					fsck.vfat $DEVNAME -y >> /dev/null
				fi
			fi
				
			if [ "$fstype" = "exfat" ]; then				
				if ! fsck.exfat $DEVNAME -a
				then
					fsck.exfat $DEVNAME -y >> /dev/null
				fi		
			fi
			
			if [ "$fstype" = "ext4" ]; then				
				if ! fsck.ext4 $DEVNAME -a
				then
					fsck.ext4 $DEVNAME -y >> /dev/null
				fi		
			fi
			
			if [ "$fstype" = "ext3" ]; then				
				if ! fsck.ext3 $DEVNAME -a
				then
					fsck.ext3 $DEVNAME -y >> /dev/null
				fi		
			fi
			
		else 
			rm -rf /media/$NAME
		fi
	fi
}


DISK_FSCK()
{
	if [ -e ${BOOT_PART} ];then
		fsck.vfat ${BOOT_PART} -a
		if [ "$?" != "0" ];then
			echo "There are bad blocks on ${BOOT_PART},onreparing... "
			fsck.vfat ${BOOT_PART} -y >> /dev/null
		fi
	fi
	
	if [ -e ${RECOVERY_PART} ];then
		${FSCK_CMD} ${RECOVERY_PART} -p
		if [ "$?" != "0" ];then
			echo "There are bad blocks on ${RECOVERY_PART},onreparing... "
			${FSCK_CMD} ${RECOVERY_PART} -y >> /dev/null
		fi
	fi
	
	if [ -e ${DATA_PART} ];then
		${FSCK_CMD} ${DATA_PART} -p
		if [ "$?" != "0" ];then
			echo "There are bad blocks on ${DATA_PART},onreparing... "
			${FSCK_CMD} ${DATA_PART} -y >> /dev/null
		fi
	fi
	
	SD_CARD_FSCK ${SD_CARD_PART}
}


if [ "$HN" == "ecu4553l" ]; then
    PARTDEVICE="mmcblk1"
	BOOT_PART="/dev/${PARTDEVICE}p1"
	RECOVERY_PART="/dev/${PARTDEVICE}p3"
	DATA_PART="/dev/${PARTDEVICE}p4"
	EMMC_BOOT1_PART="/dev/${PARTDEVICE}boot1"
	SD_CARD_PART="/dev/mmcblk0p1"
elif [ "$HN" == "ecu1252" ]; then
    PARTDEVICE="mmcblk0"
	BOOT_PART="/dev/${PARTDEVICE}p1"
	RECOVERY_PART="/dev/${PARTDEVICE}p3"
	DATA_PART="/dev/${PARTDEVICE}p4"
	EMMC_BOOT1_PART="/dev/${PARTDEVICE}boot1"
	SD_CARD_PART="/dev/mmcblk1p1"
elif [ "$HN" == "ecu1253" ]; then
    FSCK_CMD="fsck.ext4"
    PARTDEVICE="mmcblk1"
	BOOT_PART="/dev/${PARTDEVICE}p4"
	RECOVERY_PART="/dev/${PARTDEVICE}p6"
	DATA_PART="/dev/${PARTDEVICE}p7"
	EMMC_BOOT1_PART="/dev/${PARTDEVICE}boot1"
	SD_CARD_PART="/dev/mmcblk0p1"
elif [ "$HN" == "ecu1155" ]; then
    FSCK_CMD="fsck.ext4"
    PARTDEVICE="mmcblk3"
	BOOT_PART="/dev/${PARTDEVICE}p1"
	RECOVERY_PART="/dev/${PARTDEVICE}p3"
	DATA_PART="/dev/${PARTDEVICE}p4"
	EMMC_BOOT1_PART="/dev/${PARTDEVICE}boot1"
	SD_CARD_PART="/dev/mmcblk0p1"
fi

if [ -e /dev/mtd9 ] && [ -b /dev/mtdblock9 ]; then  #Nand
	SD_CARD_FSCK /dev/mmcblk0p1
else 
	DISK_FSCK
fi
