#!/bin/sh


if [ "$#" == "2" ];then

	if [ "$1" == "pre_exec" ];then
		EXEC_FILE=".pre_exec.sh"
	elif [ "$1" == "post_exec" ];then
		EXEC_FILE=".post_exec.sh"
	else 
		echo "usage:$0 pre_exec/post_exec"
		exit 0
	fi

	if [ "$2" == "background" ];then
		FLAG="&"
	fi
else
	echo "usage:$0 pre_exec/post_exec"
	exit 0
fi


HN=`cat /proc/board | tr A-Z a-z`

if [ "$HN" == "ecu1051" ] || [ "$HN" == "ecu1051bg" ] || [ "$HN" == "ecu1051b" ] || [ "$HN" == "ecu1051e" ]  || [ "$HN" == "adam5630" ]  || [ "$HN" == "ecu4553l" ] || [ "$HN" == "ecu1253" ] || [ "$HN" == "ecu1251d" ];then
	if [ -e /dev/mmcblk0p1 ];then
		SD_DEV="mmcblk0p1"
	else
		SD_DEV="mmcblk0"
	fi

else
	if [ -e /dev/mmcblk1p1 ];then
		SD_DEV="mmcblk1p1"
	else
		SD_DEV="mmcblk1"
	fi
fi


if [ -e /dev/$SD_DEV ];then
	NUM=`cat /proc/mounts | grep "dev/$SD_DEV" | wc -l`
	#echo "/dev/$SD_DEV has been mounted $NUM partitions."
	MOUNT_DIR=`cat /proc/mounts | grep "dev/$SD_DEV" | awk '{ print $2}' | head -1`
	
	if [ "$NUM" != "0" ];then 
		if [ -x $MOUNT_DIR/$EXEC_FILE ];then
			sh $MOUNT_DIR/$EXEC_FILE $FLAG
		fi
	fi
fi
