#!/bin/bash 

# Author : Yafei,wang
# 

echo_msg()
{
    NOW=$(date +'%Y-%m-%d %H:%M:%S')
    echo "[$NOW] $1" 2>&1 | tee -a /tmp/update.log
    sync
}

analysis_disk_config()
{
	disk_config=$1 
	if [ -f $disk_config ];then
		echo_msg "find disk_config=$disk_config"
		while read line
		do 
			name=`echo $line|awk -F '=' '{print $1}'`
			value=`echo $line|awk -F '=' '{print $2}'`
	
			case $name in
				"product_name")
					product_name=$value
					;;
				"disk_type")
					disk_type=$value
					echo_msg "$name=$value"
					if [ "$value" != "mmc" ] && [ "$value" != "emmc" ] && [	"$value" != "nand" ];then 
						echo_msg " disk_type=[$value] is not in mmc/emmc/nand type"
						exit -1
					fi
					;;
				"cpu")
					cpu=$value
					;;
				"partition_label")
					if [ "$value" != "gpt" ];then 
						partition_label=mbr
					else
						partition_label=gpt
					fi
					#echo_msg "$name=$value"
					;;
				"partition_num")
					partition_num=$value
					#echo_msg "$name=$value"
					;;
				"partition_boot")
					partition_boot=$value
					#echo_msg "$name=$value"
					;;
				"part_unit")
					part_unit=$value
					#echo_msg "$name=$value"
					;;
				"part_p1")
					#echo_msg "$name=$value"
					part_p1_size=`echo $value | awk '{print $1}'`
					part_p1_format=`echo $value | awk '{print $2}'`
					part_p1_label=`echo $value | awk '{print $3}'`
					;;
				"part_p2")
					#echo_msg "$name=$value"
					part_p2_size=`echo $value | awk '{print $1}'`
					part_p2_format=`echo $value | awk '{print $2}'`
					part_p2_label=`echo $value | awk '{print $3}'`
					;;
				"part_p3")
					#echo_msg "$name=$value"
					part_p3_size=`echo $value | awk '{print $1}'`
					part_p3_format=`echo $value | awk '{print $2}'`
					part_p3_label=`echo $value | awk '{print $3}'`
					;;
				"part_p4")
					#echo_msg "$name=$value"
					part_p4_size=`echo $value | awk '{print $1}'`
					part_p4_format=`echo $value | awk '{print $2}'`
					part_p4_label=`echo $value | awk '{print $3}'`
					;;
				"part_p5")
					#echo_msg "$name=$value"
					part_p5_size=`echo $value | awk '{print $1}'`
					part_p5_format=`echo $value | awk '{print $2}'`
					part_p5_label=`echo $value | awk '{print $3}'`
					;;
				"part_p6")
					#echo_msg "$name=$value"
					part_p6_size=`echo $value | awk '{print $1}'`
					part_p6_format=`echo $value | awk '{print $2}'`
					part_p6_label=`echo $value | awk '{print $3}'`
					;;
				"part_p7")
					#echo_msg "$name=$value"
					part_p7_size=`echo $value | awk '{print $1}'`
					part_p7_format=`echo $value | awk '{print $2}'`
					part_p7_label=`echo $value | awk '{print $3}'`
					;;
				"part_p8")
					#echo_msg "$name=$value"
					part_p8_size=`echo $value | awk '{print $1}'`
					part_p8_format=`echo $value | awk '{print $2}'`
					part_p8_label=`echo $value | awk '{print $3}'`
					;;
				"part_p9")
					#echo_msg "$name=$value"
					part_p9_size=`echo $value | awk '{print $1}'`
					part_p9_format=`echo $value | awk '{print $2}'`
					part_p9_label=`echo $value | awk '{print $3}'`
					;;
				"part_p10")
					#echo_msg "$name=$value"
					part_p10_size=`echo $value | awk '{print $1}'`
					part_p10_format=`echo $value | awk '{print $2}'`
					part_p10_label=`echo $value | awk '{print $3}'`
					;;
				"rootfs_file")
					rootfs_file=$value
					echo_msg "$name=$value"
					;;
				"external_update_dev")
					external_update_dev=$value
					echo_msg "$name=$value"
					;;
				"internal_update_dev")
					internal_update_dev=$value
					echo_msg "$name=$value"
					;;
				"third_update_dev")
					third_update_dev=$value
					echo_msg "$name=$value"
					;;
				"firmware")
					firmware=$value
					echo_msg "$name=$value"
					;;
				"partdevice")
					partdevice=$value
					echo_msg "$name=$value"
					;;
				"bootdev")
					bootdev=$value
					echo_msg "$name=$value"
					;;
				"rootdev")
					rootdev=$value
					echo_msg "$name=$value"
					;;
				"recoverydev")
					recoverydev=$value
					echo_msg "$name=$value"
					;;
				"datadev")
					datadev=$value
					echo_msg "$name=$value"
					;;
				"mtd_rfs_num")
					mtd_rfs_num=$value
					;;		
				"mtd_recovery_num")
					mtd_recovery_num=$value
					;;		
				"mtd_data_num")
					mtd_data_num=$value
					;;	
				"mtd_userdata_num")
					mtd_userdata_num=$value
					;;	
				"ubi_root_num")
					ubi_root_num=$value
					;;	
				"ubi_recovery_num")
					ubi_recovery_num=$value
					;;	
				"ubi_data_num")
					ubi_data_num=$value
					;;		
				"ubi_userdata_num")
					ubi_userdata_num=$value
					;;		
			esac
		done < $disk_config
	fi
}

all_led_heartbeat() {
    LEDDIR=/sys/class/leds/
	for file in `ls ${LEDDIR}`
    do
        if [ -f ${LEDDIR}/${file}/trigger ]; then
		    echo "heartbeat" > "${LEDDIR}/${file}/trigger"
		fi
    done
}

########### EMMC/MMC Operations #############
format()
{
	FORMAT_DEV=$1
	FORMAT_TYPE=$2
	FORMAT_LABEL=$3

	# MMC/EMMC
	if [ "$disk_type" == "mmc" ] || [ "$disk_type" == "emmc" ];then 

		umount $FORMAT_DEV 1> /dev/null 2> /dev/null

		if [ "$FORMAT_TYPE" == "fat32" ];then 
			mkfs.vfat -F 32 -n $FORMAT_LABEL $FORMAT_DEV
		fi
		if [ "$FORMAT_TYPE" == "ext3" ];then 
			mkfs.ext3 -F -L $FORMAT_LABEL $FORMAT_DEV
		fi
		if [ "$FORMAT_TYPE" == "ext4" ];then 
			mkfs.ext4 -F -L $FORMAT_LABEL $FORMAT_DEV
		fi
		
	# NAND device
	elif [ "$disk_type" == "nand" ];then 
		echo_msg "disk_type=$disk_type"

	else
		echo_msg "disk_type=$disk_type is not found."
		exit -1
	fi

}

fdisk_partition()
{
	device=$1
	dd if=/dev/zero of=$device bs=1M count=5

	if [ "$partition_label" == "gpt" ];then
		p_label="g"
        toggle_boot=""
        partition_boot=""
		change_fat=""
		chage_type=""
	else 
		p_label="o"
        toggle_boot="a"
		change_fat="t"
		chage_type="c"
	fi

	if [ "$cpu" == "px30" ] ;then
		skip_sector=16384
	else 
		skip_sector=2048
	fi

	part_p1_size=+${part_p1_size}
	part_p2_size=+${part_p2_size}
	part_p3_size=+${part_p3_size}

	if [ "$part_p4_size" == "remaining" ];then 
		part_p4_size=""
        p4_num=""
	else 
		part_p4_size=+${part_p4_size}
	fi

	if [ "$part_p5_size" != "" ];then 
		create_p5=n
		p5_num=5 
		if [ "$part_p5_size" == "remaining" ];then 
			part_p5_size=""
		else 
			part_p5_size=+${part_p5_size}
		fi
	fi

	if [ "$part_p6_size" != "" ];then 
		create_p6=n
		p6_num=6
		if [ "$part_p6_size" == "remaining" ];then 
			part_p6_size=""
		else 
			part_p6_size=+${part_p6_size}
		fi
	fi

	if [ "$part_p7_size" != "" ];then 
		create_p7=n
		p7_num=7 
		if [ "$part_p7_size" == "remaining" ];then 
			part_p7_size=""
		else 
			part_p7_size=+${part_p7_size}
		fi
	fi

cat << END | fdisk $device
${p_label}

n
p
1
${skip_sector}
${part_p1_size}

n
p
2

${part_p2_size}

n
p
3

+${part_p3_size}

n
p
${p4_num}

${part_p4_size}


${create_p5}

${p5_num}

${part_p5_size}

${create_p6}

${p6_num}

${part_p6_size}

${create_p7}

${p7_num}

${part_p7_size}

${change_fat}
${partition_boot}
${chage_type}
${toggle_boot}
${partition_boot}
p
w
END
	sync

	#for i in $(seq 1 $partition_num)
	#do
	#	part_size=part_p${i}_size 
	#	part_format=part_p${i}_format
	#	part_label=part_p${i}_label
	#	DEV_PART=${DRIVE}p$i
		#format $DEV_PART ${!part_format} ${!part_label}
	#done

	if [ "$cpu" == "px30" ] ;then
        partprobe 2> /dev/null
		parted $device name 1 uboot 2> /dev/null
		parted $device name 2 trust 2> /dev/null
		parted $device name 3 misc 2> /dev/null
		parted $device name 4 boot 2> /dev/null
		parted $device name 5 rootfs 2> /dev/null
		parted $device name 6 recovery 2> /dev/null
		parted $device name 7 data 2> /dev/null
		sync
	fi
}

partition_disks()
{
	# MMC/EMMC
	if [ "$disk_type" == "mmc" ] || [ "$disk_type" == "emmc" ];then 

		if [ -b /dev/$partdevice ];then 
			DRIVE=/dev/$partdevice
			umount $DRIVE* 1> /dev/null 2> /dev/null
		else
			echo_msg "/dev/$partdevice is not found."
			exit -1
		fi

		echo_msg "/dev/$partdevice was selected"

		fdisk_partition /dev/$partdevice

		sleep 2

	# NAND device
	elif [ "$disk_type" == "nand" ];then 
		echo_msg "disk_type=$disk_type"
	else
		echo_msg "disk_type=$disk_type is not found."
		exit -1
	fi
}

check_md5()
{
	CHECKSUM_FILE=checksum.md5

	md5_file=$1/$CHECKSUM_FILE

	if [ -f $md5_check ]; then
		cd $1
		echo_msg "MD5 check $CHECKSUM_FILE..."
		encdec -d $md5_file /tmp/$CHECKSUM_FILE               
		md5sum -c -s /tmp/$CHECKSUM_FILE                      
		if [ $? -eq 0 ]; then
			advchecksum=y
			echo_msg "MD5 check OK!"
			return 0
		else                                                           
			advchecksum=n       
			echo_msg "MD5 checksum error, remove ${configfile}"
			rm /media/${dev}/${configfile}
			echo_msg "update log file!!"
			cp -f /tmp/update.log $UPDATE_LOGFILE
			sync;sync;sleep 1
			return 1
		fi              
		cd - > /dev/null
	else
		if [ "$advnomd5check" != "y" ]; then
			advchecksum=n
			echo_msg "Not checksum file, remove ${configfile}"
			rm ${configfile}
			echo_msg "update log file!!"
			cp -f /tmp/update.log $UPDATE_LOGFILE
			sync;sync;sleep 1
			return 1
		else
			echo_msg "Not checksum file, but the user have set advnomd5check,it will skip md5_check"
			return 0
		fi
	fi
}

check_image_files()
{
	IMG_DIR=$1
	cd $IMG_DIR
	if [ "$cpu" == "am335x" ];then 
		if [ -f MLO ] && [ -f u-boot.img ] && [ -f uImage ] && [ -f am335x-$HN.dtb ] ;then 
			return 0
		fi 
	elif [ "$cpu" == "am437x" ];then 
		if [ -f MLO ] && [ -f u-boot.img ] && [ -f uImage ] && [ -f am437x-$HN.dtb ] ;then 
			return 0
		fi 
	elif [ "$cpu" == "px30" ];then 
		if [ -f idbloader.img ] && [ -f uboot.img ] && [ -f resource.img ] && [ -f trust.img ] && [ -f Image ] && [ -f px30-$HN.dtb ];then 
			return 0
		fi 		
	elif [ "$cpu" == "imx6" ];then 
	    if [ -f u-boot.imx ] || [ -f imx6dl-$HN.dtb ] || [ -f uImage ]; then
		    return 0
		fi	
	elif [ "$cpu" == "imx8" ];then 
	    if [ -f u-boot.imx ] || [ -f *-$HN.dtb ] || [ -f uImage ]; then
		    return 0
		fi	
	fi
	return 1
	cd - > /dev/null
}


########### Nand Operations #############
mtd_name_to_num()
{
	if [ "$cpu" == "am335x" ] || [ "$cpu" == "am437x" ];then 
		case "$1" in
			MLO)      MTDNUM=0 ;;
			MLO1)     MTDNUM=1 ;;
			MLO2)     MTDNUM=2 ;;
			MLO3)     MTDNUM=3 ;;
			dtb)      MTDNUM=4 ;;
			uboot)    MTDNUM=5 ;;
			uEnv)     MTDNUM=6 ;;
			uEnv1)    MTDNUM=7 ;;
			uImage)   MTDNUM=8 ;;
			rfs)      MTDNUM=$mtd_rfs_num;;
			recovery) MTDNUM=$mtd_recovery_num;; 
			data)     MTDNUM=$mtd_data_num ;;
			userdata) MTDNUM=$mtd_userdata_num ;;
			*)      exit 1 ;;
		esac
	elif [ "$cpu" == "px30" ];then 
		echo "px30 mtd_name_to_num."
	elif [ "$cpu" == "imx6" ];then 
		echo "imx6 mtd_name_to_num."
	elif [ "$cpu" == "imx8" ];then 
		echo "imx8 mtd_name_to_num."
	fi
}

nand_burn()
{
	FILE_TO_BURN=$2
    MTDNUM=$1

	echo "MTD sector name is $MTDNUM"
	mtd_name_to_num "$MTDNUM"

    MTDDEV=/dev/mtd$MTDNUM
    if [[ ! -c $MTDDEV ]]; then
        echo "$MTDDEV doesn't exist or can't be opened as character device.  Exiting."
        exit 2;
    fi;

    if [ "$MTDNUM" -eq "$MTDRFSNUM" ] 2>/dev/null; then
        echo "this MTD:$MTDDEV is rootfs partition."
        ubiformat /dev/mtd$MTDRFSNUM -f "$2" -O 1024
        ubiattach -p /dev/mtd$MTDRFSNUM -d ${ubi_root_num} -O 1024
        mount -t ubifs ubi0_0 /media/$roodev
        chown -R root:root /media/$roodev
        chown -R 1000:1001 /media/$roodev/home/sysuser
        sync
        umount /media/$roodev
        ubidetach -p /dev/mtd$MTDRFSNUM  2> /dev/null
    else
		flash_erase $MTDDEV 0 0
   		nandwrite -p $MTDDEV $FILE_TO_BURN
    fi
}


update_boot_files()
{
	UPDATE_DIR=$1 		# ADAM3600:  /media/mmcblk1p1 or /media/mmcblk0p3
	if [ "$disk_type" == "mmc" ] || [ "$disk_type" == "emmc" ];then 
		echo_msg "format boot partition..." 
		umount /dev/$bootdev 2> /dev/null
		mkfs.vfat -F 32 -n "boot" /dev/$bootdev > /dev/null
		mount /dev/$bootdev /media/$bootdev
		sleep 1

		echo_msg "update u-boot, kernel from $UPDATE_DIR to /media/${bootdev}..." 
		if [ "$cpu" == "am335x" ] || [ "$cpu" == "am437x" ];then 
			cp $UPDATE_DIR/MLO /media/${bootdev}/
			cp $UPDATE_DIR/u-boot.img /media/${bootdev}/
			cp $UPDATE_DIR/uImage /media/${bootdev}/
		elif [ "$cpu" == "px30" ];then 
			dd if=$UPDATE_DIR/idbloader.img of=/dev/${partdevice} seek=64
			dd if=$UPDATE_DIR/uboot.img of=/dev/${partdevice} seek=16384
			dd if=$UPDATE_DIR/trust.img of=/dev/${partdevice} seek=24576
			dd if=$UPDATE_DIR/resource.img of=/dev/${partdevice} seek=32768
			cp $UPDATE_DIR/Image /media/${bootdev}/
		elif [ "$cpu" == "imx6" ];then 
			dd if=$UPDATE_DIR/u-boot.imx of=/dev/${partdevice} bs=1k seek=1 conv=fsync
			cp $UPDATE_DIR/uImage /media/${bootdev}/
		elif [ "$cpu" == "imx8" ];then 
			dd if=$UPDATE_DIR/u-boot.imx of=/dev/${partdevice} bs=1k seek=1 conv=fsync
			cp $UPDATE_DIR/uImage /media/${bootdev}/
		fi
		cp $UPDATE_DIR/*.dtb /media/${bootdev}/
		cp $UPDATE_DIR/ramdisk.gz /media/${bootdev}
		sync
	else 
		# Nand Flash
		echo_msg "update u-boot, kernel from $UPDATE_DIR..." 
		if [ "$cpu" == "am335x" ] || [ "$cpu" == "am437x" ];then 
			echo_msg "nand images update"
			echo_msg "update u-boot and kernel from $UPDATE_DIR"
			nand_burn  MLO    $UPDATE_DIR/MLO
			nand_burn  MLO1   $UPDATE_DIR/MLO
			nand_burn  MLO2   $UPDATE_DIR/MLO
			nand_burn  MLO3   $UPDATE_DIR/MLO
			nand_burn  uboot  $UPDATE_DIR/u-boot.img
			nand_burn  dtb    $UPDATE_DIR/*-$HN.dtb
			nand_burn  uImage $UPDATE_DIR/uImage
		elif [ "$cpu" == "px30" ];then 
			echo "px30 image update."
		elif [ "$cpu" == "imx6" ];then 
			echo "imx6 image update."
		elif [ "$cpu" == "imx8" ];then 
			echo "imx8 image update."
		fi
	fi
}

backup_image_files()
{
	SOURCE_DIR=$1 		# ADAM3600:  /media/mmcblk1p1
	DEST_DIR=$2       # /media/mmcblk0p3 or /media/recovery 
	
	if [ "$recoverydev" != "" ] && [ "/media/$recoverydev" != "$UPDATE_DIR" ] ;then 
		echo_msg "backup image to recovery partition..." 
		echo_msg "format recovery partition..." 
		if [ "$disk_type" == "mmc" ] || [ "$disk_type" == "emmc" ];then 
			umount /dev/$recoverydev 2> /dev/null
			${MKFS_CMD} -F -L "recovery" /dev/$recoverydev > /dev/null
			if [ "$FORMAT_TYPE" == "ext4" ];then 
				mount -t ext4 /dev/$recoverydev /media/$recoverydev
			else 
				mount -t ext3 /dev/$recoverydev /media/$recoverydev
			fi
		else
			set -x
			umount -l /media/${recoverydev} 2> /dev/null
			ubidetach -p /dev/mtd${mtd_recovery_num} 2> /dev/null
			ubiformat /dev/mtd${mtd_recovery_num} -y -O 1024
			ubiattach -p /dev/mtd${mtd_recovery_num} -d ${ubi_recovery_num} -O 1024
			ubimkvol /dev/ubi${ubi_recovery_num} -N recovery -m
			mount -t ubifs ubi${ubi_recovery_num}_0 /media/${recoverydev}
			set +x
		fi
		sleep 1

		if [ "$cpu" == "am335x" ] || [ "$cpu" == "am437x" ];then 
			cp -p $UPDATE_DIR/MLO $DEST_DIR
			cp -p $UPDATE_DIR/u-boot.img $DEST_DIR
			cp -p $UPDATE_DIR/uImage $DEST_DIR
		elif [ "$cpu" == "px30" ];then 
			cp -p $UPDATE_DIR/idbloader.img $DEST_DIR
			cp -p $UPDATE_DIR/uboot.img $DEST_DIR
			cp -p $UPDATE_DIR/trust.img $DEST_DIR
			cp -p $UPDATE_DIR/resource.img $DEST_DIR
			cp -p $UPDATE_DIR/Image $DEST_DIR
		elif [ "$cpu" == "imx6" ];then 
			cp -p $UPDATE_DIR/u-boot.imx $DEST_DIR
			cp -p $UPDATE_DIR/uImage $DEST_DIR
		elif [ "$cpu" == "imx8" ];then 
			cp -p $UPDATE_DIR/u-boot.imx $DEST_DIR
			cp -p $UPDATE_DIR/uImage $DEST_DIR
		fi
		cp -p $UPDATE_DIR/*.dtb $DEST_DIR
		cp -p $SOURCE_DIR/$rootfs_file $DEST_DIR
		cp -p $SOURCE_DIR/ramdisk.gz $DEST_DIR
		sync
	fi
}

# descritions: backup files according to 
#   [ sysuser/update/backup.lst ] or [ /media/mmcblk1p1/backup.lst ] or  [ /media/mmcblk0p3/backup.lst ]
# usage: backup /media/mmcblk1p1
backup_files() 
{
    while read line
    do
        if [ -f "$ROOTDIR$line" ]; then
            echo_msg "backup file is $line"
            bdir=${line%/*}
            bakdir=$1$BACKUPDIR$bdir
            if [ ! -d "bakdir" ]; then
                mkdir -p $bakdir
            fi
            cp $ROOTDIR$line $bakdir
        fi
    done < $BACKUPFILES 
    cp $BACKUPFILES $1$BACKUPDIR
    sync
}

# descritions: restore files according to 
#   [ sysuser/update/backup.lst ] or [ /media/mmcblk1p1/backup.lst ] or  [ /media/mmcblk0p3/backup.lst ]
# usage: restore /media/mmcblk1p1
restore_files() 
{
    while read line
    do
        if [ -n "$line" ]; then
            echo_msg "restore file is $line"
            bakfile=$1$BACKUPDIR$line
            if [ -f "$bakfile" ]; then
                cp $bakfile $ROOTDIR$line
            fi
        fi
    done < $1$BACKUPDIR/$LISTFILE
    rm -fr $1$BACKUPDIR
    sync
}

backup_files_and_project()
{
	UPDATE_DIR=$1 		# ADAM3600:  /media/mmcblk1p1 or /media/mmcblk0p3

	####### Get Old TagLink_DIR for backup  ######################## 
	if [ -f $ROOTDIR/etc/profile ];then 
		OLD_TAGLINK_DIR=`cat ${ROOTDIR}/etc/profile | grep TAGLINK_PATH | head -1 | awk -F = '{print $2}'`
	fi 
	if [ "${OLD_TAGLINK_DIR}" == "" ]; then
		if [ "${advpath}" == "" ]; then
			OLD_TAGLINK_DIR=/home/root
		else
			OLD_TAGLINK_DIR=${advpath}
		fi
	fi
	echo_msg "Old TagLink path is $TAGLINK_DIR"

	
	OLD_USER_NAME=`echo $OLD_TAGLINK_DIR | awk -F / '{print $3}'`
	echo_msg "user name is $OLD_USER_NAME"

	TARGET_DIR=${HOMEDIR}/${OLD_USER_NAME}
	echo_msg "Target path is $TARGET_DIR"

	OLDPRJDIR=${HOMEDIR}/root
	BACKUPFILES=${HOMEDIR}/${OLD_USER_NAME}/update/update/$LISTFILE
	
	####### backup project dir  ######################## 
    if [ "$advfactory" != "y" ] && [ "$advpartition" != "y" ]; then   
        if [ -d $OLDPRJDIR/project ] && [ -d $OLDPRJDIR/bin ] && [ -d $OLDPRJDIR/lib ] && [ "$OLD_USER_NAME" == "root" ]; then
            echo_msg "backup $OLDPRJDIR project files"
            cd ${OLDPRJDIR}
            tar -czpf $UPDATE_DIR/$PROJECT_BAK_FILE project/
            cd -  > /dev/null
            sync;sync;sleep 1   
        fi
        if [ -d "${TARGET_DIR}/project" ]; then
            echo_msg "backup project files" 
            cd ${TARGET_DIR}
            tar -czpf $UPDATE_DIR/$PROJECT_BAK_FILE project/
            cd - > /dev/null
        fi
        if [ -f "$BACKUPFILES" ]; then
			echo_msg "find $BACKUPFILES"
            backup_files $UPDATE_DIR
        elif [ -f "$UPDATE_DIR/$LISTFILE" ]; then
			echo_msg "find $BACKUPFILES"
            BACKUPFILES="$UPDATE_DIR/$LISTFILE"
            backup_files $UPDATE_DIR
        else
			echo_msg "can not find $BACKUPFILES and $UPDATE_DIR/$LISTFILE"
            [ -f "/media/${rootdev}/etc/passwd" ] && cp -p /media/${rootdev}/etc/passwd $UPDATE_DIR/
            [ -f "/media/${rootdev}/etc/shadow" ] && cp -p /media/${rootdev}/etc/shadow $UPDATE_DIR/
            [ -f "/media/${rootdev}/etc/group" ] && cp -p /media/${rootdev}/etc/group $UPDATE_DIR/
            [ -f "/media/${rootdev}/etc/gshadow" ] && cp -p /media/${rootdev}/etc/gshadow $UPDATE_DIR/
        fi
        sync;sleep 2
    fi
}

restore_files_and_project()
{
	UPDATE_DIR=$1 		# ADAM3600:  /media/mmcblk1p1 or /media/mmcblk0p3

    [ ! -d ${HOMEDIR}/ftp ] && mkdir -p ${HOMEDIR}/ftp
    [ ! -d ${HOMEDIR}/sysuser ] && mkdir -p ${HOMEDIR}/sysuser
    [ ! -d ${HOMEDIR}/root ] && mkdir -p ${HOMEDIR}/root
    [ ! -f ${HOMEDIR}/root/.bashrc ] && cp -f /media/${rootdev}/etc/skel/.bashrc $HOMEDIR/root
    [ ! -f ${HOMEDIR}/root/.profile ] && cp -f /media/${rootdev}/etc/skel/.profile $HOMEDIR/root
    [ ! -f ${HOMEDIR}/root/.bash_history ] && cp -f /media/${rootdev}/etc/skel/.bash_history $HOMEDIR/root
    [ ! -f ${HOMEDIR}/sysuser/.bashrc ] && cp -f /media/${rootdev}/etc/skel/.bashrc $HOMEDIR/sysuser
    [ ! -f ${HOMEDIR}/sysuser/.profile ] && cp -f /media/${rootdev}/etc/skel/.profile $HOMEDIR/sysuser
    [ ! -f ${HOMEDIR}/sysuser/.bash_history ] && cp -f /media/${rootdev}/etc/skel/.bash_history $HOMEDIR/sysuser
    [ ! -f "${TARGET_DIR}/.version" ] && cp -f /media/${rootdev}/etc/version $TARGET_DIR/.version

		####### restore project backup  ######################## 
    if [ "$advfactory" != "y" ]; then
        if [ -f "$UPDATE_DIR/$PROJECT_BAK_FILE" ]; then
            echo_msg "restore project files"
            tar -xpf $UPDATE_DIR/$PROJECT_BAK_FILE -C $TARGET_DIR
            rm $UPDATE_DIR/$PROJECT_BAK_FILE
        fi
        if [ -f "$UPDATE_DIR/$BACKUPDIR/$LISTFILE" ]; then
            restore_files $UPDATE_DIR
        else
            [ -f "$UPDATE_DIR/passwd" ] && cp -p $UPDATE_DIR/passwd /media/${rootdev}/etc/ && rm $UPDATE_DIR/passwd
            [ -f "$UPDATE_DIR/shadow" ] && cp -p $UPDATE_DIR/shadow /media/${rootdev}/etc/ && rm $UPDATE_DIR/shadow
            [ -f "$UPDATE_DIR/group" ] && cp -p $UPDATE_DIR/group /media/${rootdev}/etc/ && rm $UPDATE_DIR/group
            [ -f "$UPDATE_DIR/gshadow" ] && cp -p $UPDATE_DIR/gshadow /media/${rootdev}/etc/ && rm $UPDATE_DIR/gshadow
        fi
        sync;sync;sleep 2
    fi

    if [ -f "/tmp/${LICENSE_FILE}" ]; then
        echo_msg "restore license file to ${HOMEDIR}/sysuser"
        cp -f -p /tmp/${LICENSE_FILE} ${HOMEDIR}/sysuser
    fi
    
    echo_msg "change the owner and group of $TARGET_DIR"
    if [ "$USER_NAME" == "root" ]; then
        echo_msg "user is root"
        chown -R root:root $TARGET_DIR
        chown -R 1000:1001 $HOMEDIR/sysuser
    else    
        echo_msg "user is $USER_NAME"
        chown -R $USER_NAME:$USER_NAME $TARGET_DIR
        chown -R root:root $HOMEDIR/root
    fi
    if [ -d /media/${rootdev}/home/ubuntu ]; then
	    echo $HN > /media/${rootdev}/etc/hostname
	    sed "/127.0.0.1/a 127.0.0.1       $HN" -i /media/${rootdev}/etc/hosts
	    sed "/^ubuntu/s/1000/1002/g" -i /media/${rootdev}/etc/passwd
	    sed "/^ubuntu/s/1000/1002/g" -i /media/${rootdev}/etc/group
	    chown -R 1002:1002 /media/${rootdev}/home/ubuntu
	fi
    sync;sync;sleep 2

}

update_rootfs()
{
	UPDATE_DIR=$1 		# ADAM3600:  /media/mmcblk1p1 or /media/mmcblk0p3
	fsfile=$UPDATE_DIR/rootfs.tar.gz
	ubifsfile=$UPDATE_DIR/rootfs.ubi

	if [ ! -f $IMG_DIR/$rootfs_file ] && [ ! -f "$ubifsfile" ];then
		echo_msg "not found rootfs.tar.gz or ubifsfile, will not update rootfs."
		return 1
	fi

	####### format rootfs  partition  ######################## 
	echo_msg "format rootfs partition..." 
	if [ "$disk_type" == "mmc" ] || [ "$disk_type" == "emmc" ];then 
		umount -l /media/${rootdev} 2> /dev/null
        ${MKFS_CMD} /dev/${rootdev} -L "rootfs" -F > /dev/null
        ${FSCK_CMD} -y /dev/${rootdev}
		sleep 1
		if [ "$FORMAT_TYPE" == "ext4" ];then 
        	mount -t ext4 /dev/${rootdev} /media/${rootdev}
		else
        	mount -t ext3 /dev/${rootdev} /media/${rootdev}
		fi 
	else 
		# Nand Flash
        umount -l /media/${rootdev}  2> /dev/null
        ubidetach -p /dev/mtd${mtd_rfs_num}  2> /dev/null
        ubiformat /dev/mtd${mtd_rfs_num} -y -O 1024
        ubiattach -p /dev/mtd${mtd_rfs_num} -d ${ubi_root_num} -O 1024
        ubimkvol /dev/ubi${ubi_root_num} -N rootfs -m
		sleep 1
        mount -t ubifs ubi${ubi_root_num}_0 /media/${rootdev}
	fi

	####### update rootfs  ######################## 
	if [ -f "$ubifsfile" ]; then
        echo_msg "flash ${ubifsfile} to ${rootdev}"
        umount -l /media/${rootdev}  2> /dev/null
        ubidetach -p /dev/mtd${mtd_rfs_num}  2> /dev/null
        ubiformat /dev/mtd${mtd_rfs_num} -f $ubifsfile -y -O 1024
        ubiattach -p /dev/mtd${mtd_rfs_num} -d ${ubi_root_num} -O 1024
        ubimkvol /dev/ubi${ubi_root_num} -N rootfs -m
		sleep 1
        mount -t ubifs ubi${ubi_root_num}_0 /media/${rootdev}	
	else
        echo_msg "unzip ${fsfile} to ${rootdev}"
        cd /media/${rootdev}
		sleep 2
        tar -xpf ${fsfile}
        cd - > /dev/null
	fi
	sync;sync
}

update_applications()
{
	UPDATE_DIR=$1 		# ADAM3600:  /media/mmcblk1p1 or /media/mmcblk0p3
	appsfile=$UPDATE_DIR/apps.tar.gz
	customfile=$UPDATE_DIR/custom.tar.gz

	####### format data partition  ######################## 
	echo_msg "format data partition..." 
	if [ "$disk_type" == "mmc" ] || [ "$disk_type" == "emmc" ];then 
        umount -l /media/${datadev} 2> /dev/null
        ${MKFS_CMD} /dev/${datadev} -L "data" -F > /dev/null
        ${FSCK_CMD} -y /dev/${datadev}
		sleep 1
		if [ "$FORMAT_TYPE" == "ext4" ];then 
        	mount -t ext4 /dev/${datadev} /media/${datadev}
		else
        	mount -t ext3 /dev/${datadev} /media/${datadev}
		fi
	else 
        umount -l /media/${datadev}  2> /dev/null
        ubidetach -p /dev/mtd${mtd_data_num}  2> /dev/null
        ubiformat /dev/mtd${mtd_data_num} -y -O 1024
        ubiattach -p /dev/mtd${mtd_data_num} -d ${ubi_data_num} -O 1024
        ubimkvol /dev/ubi${ubi_data_num} -N data -m
		sleep 1
        mount -t ubifs ubi${ubi_data_num}_0 /media/${datadev}   
	fi
	sleep 2
	####### Get New TagLink_DIR for backup  ######################## 
	TAGLINK_DIR=`cat /media/${rootdev}/etc/profile | grep TAGLINK_PATH | head -1 | awk -F = '{print $2}'`
	if [ "${TAGLINK_DIR}" == "" ]; then
		if [ "${advpath}" == "" ]; then
			TAGLINK_DIR=/home/root
		else
			TAGLINK_DIR=${advpath}
		fi
	fi
    echo_msg "New TagLink path is $TAGLINK_DIR"

    USER_NAME=`echo $TAGLINK_DIR | awk -F / '{print $3}'`
    echo_msg "New user name is $USER_NAME"

    TARGET_DIR=${HOMEDIR}/${USER_NAME}
    echo_msg "New Target path is $TARGET_DIR"


	####### install edgelink appsfile  ######################## 
    if [ -f "$appsfile" ]; then
        echo_msg "update applications : $appsfile ..."
        if [ -d "${TARGET_DIR}" ]; then
            echo_msg "${TARGET_DIR} exists" 
        else
            echo_msg "create directory ${TARGET_DIR}" 
            mkdir -p ${TARGET_DIR}
        fi
        [ -d $TARGET_DIR/bin ] && rm -rf $TARGET_DIR/bin
        [ -d $TARGET_DIR/driver ] && rm -rf $TARGET_DIR/driver
        [ -d $TARGET_DIR/lib ] && rm -rf $TARGET_DIR/lib
        [ -d $TARGET_DIR/project ] && rm -rf $TARGET_DIR/project
        [ -d $TARGET_DIR/update ] && rm -rf $TARGET_DIR/update
        [ -d $TARGET_DIR/user ] && rm -rf $TARGET_DIR/user
        [ -d $TARGET_DIR/util ] && rm -rf $TARGET_DIR/util
        [ -d $TARGET_DIR/www ] && rm -rf $TARGET_DIR/www
        [ -d $TARGET_DIR/doc ] && rm -rf $TARGET_DIR/doc
        [ -d $TARGET_DIR/inc ] && rm -rf $TARGET_DIR/inc
        [ -d $TARGET_DIR/include ] && rm -rf $TARGET_DIR/include
        tar -xpf $appsfile -C $TARGET_DIR
        [ -d $TARGET_DIR/.project ] && mv -f $TARGET_DIR/.project $TARGET_DIR/project
        sync;sync;sleep 2
    fi

	####### install external customfile  ######################## 
    if [ -f "$customfile" ]; then
        echo_msg "update custom package : $customfile..."
        ln -s ${HOMEDIR}/root /media/${rootdev}/home/root
        ln -s ${HOMEDIR}/sysuser /media/${rootdev}/home/sysuser
        ln -s ${HOMEDIR}/ftp /media/${rootdev}/home/ftp
        tar -xpf $customfile -C /media/${rootdev}
        sync;sync;sleep 1
        rm /media/${rootdev}/home/root
        rm /media/${rootdev}/home/sysuser
        rm /media/${rootdev}/home/ftp
        sync;sync;sleep 1
    fi
}

update_img()
{
	UPDATE_DIR=$1 		# ADAM3600:  /media/mmcblk1p1 or /media/mmcblk0p3
	dev=`basename $1` 	# ADAM3600: mmcblk1p1 or mmcblk0p3

	UPDATE_LOGFILE=$UPDATE_DIR/update.log
	configfile=$UPDATE_DIR/advupdate.txt

	############# analysis advupdate.txt ####################
	if [ -f ${configfile} ]; then
		while read line
		do 
			name=`echo $line|awk -F '=' '{print $1}'`
			value=`echo $line|awk -F '=' '{print $2}'` 
			case $name in 
				"advimage")
					advimage=$value
					echo_msg advimage=$advimage
					;;
				"advrootfs")
					advrootfs=$value
					echo_msg advrootfs=$advrootfs
					;;
				"advrecover")
					advrecover=$value
					echo_msg advrecover=$advrecover
					;;
				"advfactory")
					advfactory=$value
					echo_msg advfactory=$advfactory
					;;  
				"advcycle")
					advcycle=$value
					echo_msg advcycle=$advcycle
					;;  
				"advapp")
					advapp=$value
					echo_msg advapp=$advapp
					;;  
				"advpath")
					advpath=$value
					echo_msg advpath=$advpath
					;;  
				"advpartition")
					advpartition=$value
					echo_msg advpartition=$advpartition
					;;  
				"advinitrun")
					advinitrun=$value
					echo_msg advinitrun=$advinitrun
					;;  
				"advrfsname")
					advrfsname=$value
					echo_msg advrfsname=$advrfsname
					;;  
				"advnomd5check")
					advnomd5check=$value
					#echo_msg advnomd5check=$advnomd5check
					;;  
				*)
					;;
			esac 
		done < ${configfile}
	else
		echo_msg "no ${configfile} config file!"
		return 1
	fi

	############# modify env from config file  ####################

	if [ "${advrfsname}" != "" ]; then
		fsfile=$UPDATE_DIR/${advrfsname}
	fi

	if [ "${advinitrun}" != "" ]; then
		echo "run advinitrun command"
		chmod a+x ${advinitrun}
		/bin/sh ${advinitrun}
		exit 0
	fi

	############# run external update script  ####################
	RFS_UPGRADEFILE=$UPDATE_DIR/rfs_upgrade.sh
	if [ -f "$RFS_UPGRADEFILE" ]; then
		echo_msg "run external update script"
		cp $RFS_UPGRADEFILE /root/
		chmod a+x /root/rfs_upgrade.sh
		sync
		/bin/sh /root/rfs_upgrade.sh
		exit 0
	fi

	############# check md5  #####################################
	if ! check_md5 /media/$dev;then 
		echo_msg "md5 check failed, please check file! System will reboot!"
		sync;
		reboot 
		return 1
	fi

	############# check image files  #####################################
	if check_image_files ${UPDATE_DIR}; then
		echo_msg "find all boot image files ..."
	else
		echo_msg "The boot image files is incomplete, please check all update file!"
		reboot
		return 1
	fi

	############# backup important files of old rootfs  ###################
	if [ "$disk_type" == "mmc" ] || [ "$disk_type" == "emmc" ];then 
		ROOTDIR=/media/$rootdev
		HOMEDIR=/media/$datadev
	elif [ "$disk_type" == "nand" ];then
		ROOTDIR=/media/rootfs
		HOMEDIR=/media/data
	fi
	if [ "$cpu" != "am335x" ] && [ "$cpu" != "am437x" ];then 
		MKFS_CMD=mkfs.ext4
		FSCK_CMD=fsck.ext4
		FORMAT_TYPE=ext4
	else
		MKFS_CMD=mkfs.ext3
		FSCK_CMD=fsck.ext3		
		FORMAT_TYPE=ext3
	fi
	backup_files_and_project $UPDATE_DIR
	
	############# partition disks  #####################################
	if [ "$advpartition" = "y" ] && [ "$disk_type" != "nand" ];then 
		if [ ${dev:0:7} = ${partdevice} ]; then # online update
			echo_msg "can't create partition own for ${dev}!"
			advpartition=n
		else 
			echo_msg "create /dev/${partdevice} partitions..."
			partition_disks
		fi
	fi

	############# update boot files  #####################################
	if [ "$advimage" = "y" ]; then                                
		update_boot_files $UPDATE_DIR
		echo_msg "update boot files done."		
	fi                                                                                       

	############# backup image files to recovery partition ################
	if [ "$advrecover" = "y" ]; then 
		# is not online update
		if [ "/media/$recoverydev" != "$UPDATE_DIR" ];then 
			# recoverydev exists
			if [ "$recoverydev" != "" ];then 
				if [ -e /dev/${recoverydev} ];then
					echo_msg "find recovery partition : /dev/${recoverydev}, start backup image files"
					backup_image_files $UPDATE_DIR /media/${recoverydev}
				elif [ -e /dev/mtd${mtd_recovery_num} ];then 
					echo_msg "find recovery partition : /dev/mtd${mtd_recovery_num} , start backup image files"
					backup_image_files $UPDATE_DIR /media/${recoverydev}
				else 
					echo_msg "not find recovery partition, will not backup image files..."
				fi
			else 
				echo_msg "not find recovery partition, will not backup image files..."
			fi
		fi
	fi

	############# update rootfs  ##########################################
	if [ "$advrootfs" = "y" ];then
		if  update_rootfs $UPDATE_DIR ;then 
			echo_msg "update rootfs done." 
		fi
	fi

	############# update applications  ##########################################
	update_applications $UPDATE_DIR

	############# restore backup files  ##########################################
	restore_files_and_project $UPDATE_DIR

	####### Firmware update  ######################## 
    if [ "$firmware" == "y" ]; then
        echo_msg "update $HN firmware"
        lsmod | awk '{ print $1}' | grep biokernbase || insmod $TARGET_DIR/driver/biokernbase.ko
        lsmod | awk '{ print $1}' | grep boardio || insmod $TARGET_DIR/driver/boardio.ko
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TARGET_DIR/lib
        $TARGET_DIR/util/AdvFirmupdate -d $UPDATE_DIR
    fi

	####### Cycle update  ######################## 
    if [ "$advcycle" = "y" ]; then
        echo_msg "cycle update..."
    else
        echo_msg "remove ${configfile}"
        rm ${configfile}
        sync;sync
    fi
	
	####### umoun partitions  ######################## 
    echo_msg "umount  partitions..."
    cd /
	if [ "$disk_type" == "mmc" ] || [ "$disk_type" == "emmc" ];then 
		umount -l /media/${rootdev} 2> /dev/null
		umount -l /media/${recoverydev} 2> /dev/null
		umount -l /media/${datadev} 2> /dev/null
		${FSCK_CMD} -y /dev/${rootdev}
		${FSCK_CMD} -y /dev/${datadev}
	else
		# Nand Flash
		umount -l /media/${rootdev}  2> /dev/null
		ubidetach -p /dev/mtd$mtd_rfs_num  2> /dev/null
		if [ "$recoverydev" != "" ];then 
			umount -l /media/${recoverydev}
			ubidetach -p /dev/mtd$mtd_recovery_num  2> /dev/null
		fi
		umount -l /media/${datadev}  2> /dev/null
		ubidetach -p /dev/mtd$mtd_data_num  2> /dev/null
	fi
	sync;sync   

	echo_msg "update log file!"
	echo_msg "update finish!"
	cp -f /tmp/update.log $UPDATE_LOGFILE
	sync;sync;sleep 3

	if [ "$advcycle" = "y" ]; then
		poweroff
	else
		reboot
		exit 0
	fi
	sleep 10
}

####################################################################
# update image

LISTFILE=backup.lst
BACKUPDIR=/bak
PROJECT_BAK_FILE=project_bak.tar.gz
MOUNT_POINT=/media/rootfs
LICENSE_FILE=.elic
disk_config=/root/config

dos2unix $disk_config

if [ ! -f $disk_config ];then 
	echo_msg "not found disk configration: $disk_config"
	reboot
	exit -1
fi


busybox hwclock --hctosys -f /dev/rtc1

echo_msg "begin ramdisk upgrade"

NUMBER=2
index=0
while [ $index -le $NUMBER ]
do
    RET=`cat /proc/mounts | grep "/dev/sda1 "`
    if [ "$RET" == "" ]; then
        echo "/dev/sda1 not ready!"
        sleep 1
        index=`expr $index + 1`
    else
        echo "/dev/sda1 ready!"
        sleep 1
		analysis_disk_config $disk_config
		check_image_files /media/sda1
		update_img /media/sda1
        break
    fi
done

HN=`cat /proc/board | tr A-Z a-z`
echo_msg "host name is $HN"

analysis_disk_config $disk_config

external_config=/media/${external_update_dev}/advupdate.txt
internal_config=/media/${internal_update_dev}/advupdate.txt
third_config=/media/${third_update_dev}/advupdate.txt

all_led_heartbeat

if [ -f $external_config ] ;then
	UPDATE_DIR=/media/${external_update_dev}
	echo_msg "update from external memory card."
	dos2unix $external_config
elif [ -f $internal_config ];then 
	UPDATE_DIR=/media/${internal_update_dev}
	echo_msg "update from internal memory, online update."
	dos2unix $internal_config
elif [ -f $third_config ];then 
	UPDATE_DIR=/media/${third_update_dev}
	echo_msg "update from $third_update_dev."
	dos2unix $third_config
else 
	echo_msg "not found configfile : advupdate.txt, will not update and reboot now."
	sync
	reboot 
	exit -1
fi

echo_msg "find $UPDATE_DIR/advupdate.txt."

update_img $UPDATE_DIR

sync

exit 0
