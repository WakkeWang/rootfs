#!/bin/bash
ROOTDIR=/media/mmcblk0p2
LISTFILE=backup.lst
#BACKUPFILES=$ROOTDIR/home/root/update/$LISTFILE
BACKUPDIR=/bak
CHECKSUM_FILE=checksum.md5
bootdev="mmcblk0p1"
rootdev="mmcblk0p2"
recoverydev="mmcblk0p3"
datadev="mmcblk0p4"
configfile="advupdate.txt"
#TARGET_DIR=/media/${rootdev}/home/root
PROJECT_BAK_FILE=project_bak.tar.gz
HOMEDIR=/media/mmcblk0p4
MOUNT_POINT=/media/rootfs

echo_msg()
{
    NOW=$(date +'%Y-%m-%d %H:%M:%S')
    echo "[$NOW] $1" 2>&1 | tee -a /tmp/update.log
    sync
}

is_nand_device () {
    if [ -e /dev/mtd0 ]; then
        echo "yes"
    else
        echo "no"
    fi
}

# usage: backup /media/mmcblk1p1
backup() {
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

# usage: restore /media/mmcblk1p1
restore() {
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

leds () {
if [ `is_nand_device` = "yes" ]; then
    if [ $1 == "on" ]; then
        echo heartbeat > /sys/class/leds/am335x\:green\:run/trigger
        #echo led on
    else
        echo none > /sys/class/leds/am335x\:green\:run/trigger
        #echo led off
    fi
else
    if [ $1 == "on" ]; then
        echo none > /sys/class/leds/am335x\:green\:run/trigger
        echo 0 > /sys/class/leds/am335x\:green\:run/brightness
        echo none > /sys/class/leds/am335x\:red\:err/trigger
        echo 0 > /sys/class/leds/am335x\:red\:err/brightness
        echo heartbeat > /sys/class/leds/am335x\:green\:program/trigger
        #echo led on
    else
        echo none > /sys/class/leds/am335x\:green\:program/trigger
        #echo led off
    fi
fi
}

# create new partitions
create_parts () {
DEVICENAME=$1
DEVICE=/dev/$DEVICENAME
if [ ! -b $DEVICE ]; then
	echo_msg "ERROR: $DEVICE is not a block device file!"
	exit 1;
fi

echo_msg "$DEVICE was selected"

umount -f ${DEVICE}p* 2>/dev/null

echo_msg "Now making partitions"

dd if=/dev/zero of=$DEVICE bs=1024 count=2048 && sync

if [ "$HN" != "ecu1252" ] && [ "$HN" != "ecu1155" ]; then
cat << END | fdisk $DEVICE
n
p
1

+40M
n
p
2

+360M
n
p
3

+200M
n
p
4


t
1
c
a
1
w
END
else
cat << END | fdisk $DEVICE
n
p
1

+40M
n
p
2

+1500M
n
p
3

+460M
n
p
4


t
1
c
a
1
w
END
fi
sleep 2

echo "Partitioning Boot"
mkfs.vfat -F 32 -n "boot" ${DEVICE}p1

echo "Partitioning Rootfs"
mkfs.ext3 -F -L "rootfs" ${DEVICE}p2

echo "Partitioning Recovery"
mkfs.ext3 -F -L "recovery" ${DEVICE}p3

echo "Partitioning Data"
mkfs.ext3 -F -L "data" ${DEVICE}p4

sync && sync

umount -f ${DEVICE}p* 2>/dev/null

mount -t vfat ${DEVICE}p1 /media/${DEVICENAME}p1/
mount -t ext3 ${DEVICE}p2 /media/${DEVICENAME}p2/
mount -t ext3 ${DEVICE}p3 /media/${DEVICENAME}p3/
mount -t ext3 ${DEVICE}p4 /media/${DEVICENAME}p4/

echo "Syncing..."
sync && sync
}

mtd_name_to_num()
{
    case "$1" in
        MLO)    MTDNUM=0 ;;
        MLO1)   MTDNUM=1 ;;
        MLO2)   MTDNUM=2 ;;
        MLO3)   MTDNUM=3 ;;
        dtb)    MTDNUM=4 ;;
        uboot)  MTDNUM=5 ;;
        uEnv)   MTDNUM=6 ;;
        uEnv1)  MTDNUM=7 ;;
        uImage) MTDNUM=8 ;;
        rfs)    MTDNUM=9 ;;
        recovery) MTDNUM=10 ;;
        data)   MTDNUM=11 ;;
        userdata) MTDNUM=12 ;;
        *)      exit 1 ;;
    esac
}

mtd_update()
{
    flash_erase $1 0 0
    nandwrite -p $1 $2
}

nand_burn()
{
    MTDNUM=$2

    if [ "$MTDNUM" -eq "$MTDNUM" ] 2>/dev/null; then
        echo "MTD sector number is $MTDNUM"
    else
        echo "MTD sector name is $MTDNUM"
        mtd_name_to_num "$MTDNUM"
    fi

    MTDDEV=/dev/mtd$MTDNUM
    if [[ ! -c $MTDDEV ]]; then
        echo "$MTDDEV doesn't exist or can't be opened as character device.  Exiting."
        exit 2;
    fi;

    if [ "$MTDNUM" -eq "$MTDRFSNUM" ] 2>/dev/null; then
        echo "MTD root file system partition."
        ubiformat /dev/mtd$MTDRFSNUM -f "$1" -O 1024
        ubiattach -p /dev/mtd$MTDRFSNUM -O 1024
        mount -t ubifs ubi0_0 $MOUNT_POINT
        chown -R root:root $MOUNT_POINT
        chown -R 1000:1001 $MOUNT_POINT/home/sysuser
        sync
        umount $MOUNT_POINT
        ubidetach -p /dev/mtd$MTDRFSNUM > /dev/null
    else
        mtd_update $MTDDEV "$1"
    fi
}

recoveryfs () {
dev=$1
fsfile=/media/${dev}/rootfs.tar.gz
ubifsfile=/media/${dev}/rootfs.ubi
appsfile=/media/${dev}/apps.tar.gz
customfile=/media/${dev}/custom.tar.gz
UPDATE_LOGFILE=/media/${dev}/update.log

if [ -f "/media/${dev}/${configfile}" ]; then
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
    "advfrim")
        advfrim=$value
        echo_msg advfrim=$advfrim
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
    *)
        ;;
    esac 
    done < /media/${dev}/${configfile}

    if [ ${dev:0:7} = mmcblk0 ]; then
        echo_msg "can't create partition own for ${dev}!"
        advpartition=n
    fi
else
    echo_msg "No /media/${dev}/${configfile} config file!"
    return 1
fi

if [ `is_nand_device` = "yes" ]; then
    HOMEDIR="/media/data"
    rootdev="rootfs"
    recoverydev="recovery"
    datadev="data"
    MTDRFSNUM=9
    if [ "$HN" == "wise2834" ] || [ "$HN" == "adam6750" ] || [ "$HN" == "adam67c1" ]; then
        MTDDATANUM=10
        UBIDATANUM=1
    else
        MTDRECOVERYNUM=10
        MTDDATANUM=11
        UBIDATANUM=2
    fi
    ROOTDIR=/media/rootfs
else
    HOMEDIR="/media/mmcblk0p4"
    rootdev="mmcblk0p2"
    recoverydev="mmcblk0p3"
    datadev="mmcblk0p4"
fi

TAGLINK_DIR=`cat ${ROOTDIR}/etc/profile | grep TAGLINK_PATH | head -1 | awk -F = '{print $2}'`
if [ "${TAGLINK_DIR}" == "" ]; then
    if [ "${advpath}" == "" ]; then
        TAGLINK_DIR=/home/root
    else
        TAGLINK_DIR=${advpath}
    fi
fi
echo_msg "TagLink path is $TAGLINK_DIR"

USER_NAME=`echo $TAGLINK_DIR | awk -F / '{print $3}'`
echo_msg "user name is $USER_NAME"

TARGET_DIR=${HOMEDIR}/${USER_NAME}
echo_msg "Target path is $TARGET_DIR"
OLDPRJDIR=${HOMEDIR}/root
BACKUPFILES=${HOMEDIR}/${USER_NAME}/update/$LISTFILE

RFS_UPGRADEFILE=/media/${dev}/rfs_upgrade.sh
if [ -f "$RFS_UPGRADEFILE" ]; then
    echo_msg "run update device upgrade"
    cp $RFS_UPGRADEFILE /root/
    chmod a+x /root/rfs_upgrade.sh
    sync
    /bin/sh /root/rfs_upgrade.sh
    exit 0
fi

if [ -f "/media/${dev}/$CHECKSUM_FILE" ]; then
    echo_msg "MD5 check /media/${dev}/$CHECKSUM_FILE..."
    cd /media/${dev}/
    #md5sum -c -s /media/${dev}/$CHECKSUM_FILE                      
    encdec -d /media/${dev}/$CHECKSUM_FILE /tmp/$CHECKSUM_FILE                    
    md5sum -c -s /tmp/$CHECKSUM_FILE                      
    if [ $? -eq 0 ]; then
        advchecksum=y
        echo_msg "MD5 check OK!"
    else                                                           
        advchecksum=n       
        echo_msg "MD5 checksum error, please check file! System will reboot!"
        for i in $(seq 1 30); do 
            leds on
            sleep 1
            leds off
            sleep 1
        done
        echo_msg "MD5 checksum error, remove ${configfile}"
        rm /media/${dev}/${configfile}
        echo_msg "update log file!!"
        cp -f /tmp/update.log $UPDATE_LOGFILE
        sync;sync;sleep 1
        reboot
        exit 1
    fi              
    cd -
else
    advchecksum=n
    echo_msg "Not checksum file, please check file! System will reboot!"
    for i in $(seq 1 10); do 
       leds on
       sleep 1
       leds off
       sleep 1
    done
    echo_msg "Not checksum file, remove ${configfile}"
    rm /media/${dev}/${configfile}
    echo_msg "update log file!!"
    cp -f /tmp/update.log $UPDATE_LOGFILE
    sync;sync;sleep 1
    reboot                                                 
    exit 1
fi

if [ "$advpartition" = "y" ]; then                                
    if [ `is_nand_device` = "no" ]; then
        echo_msg "create partitions..."
        create_parts mmcblk0
    fi
fi

if [ "$advimage" = "y" ]; then                                
    leds on
    if [ `is_nand_device` = "yes" ]; then
        echo_msg "update u-boot and kernel from /media/${dev}"
        nand_burn /media/${dev}/MLO MLO
        nand_burn /media/${dev}/MLO MLO1
        nand_burn /media/${dev}/MLO MLO2
        nand_burn /media/${dev}/MLO MLO3
        nand_burn /media/${dev}/u-boot.img uboot
        nand_burn /media/${dev}/am335x-$HN.dtb dtb
        nand_burn /media/${dev}/uImage uImage
    else                     
        echo_msg "update u-boot and kernel from /media/${dev} to /media/${bootdev}"
        cp -p /media/${dev}/MLO /media/${bootdev}/            
        cp -p /media/${dev}/u-boot.img /media/${bootdev}/     
        ls /media/${dev}/*.dtb > /dev/null
        if [ "$?" == "0" ]; then			
            rm -f /media/${bootdev}/*.dtb
            cp -p /media/${dev}/*.dtb /media/${bootdev}/                              
        fi
        cp -p /media/${dev}/uImage /media/${bootdev}/                                    
        cp -p /media/${dev}/ramdisk.gz /media/${bootdev}/                                
    fi
    sync                                                                             
    leds off
fi                                                                                       

if [ "$advrecover" = "y" ]; then
    if [ "$HN" != "wise2834" ] && [ "$HN" != "adam6750" ] && [ "$HN" != "adam67c1" ]; then                                
    if [ /media/$recoverydev != /media/${dev} ]; then                        
        leds on
        echo_msg "update recovery file system from /media/${dev} to /media/${recoverydev}!"                             
        if [ `is_nand_device` = "no" ]; then
            echo_msg "starting formating disk ${recoverydev}"
            umount -l /media/${recoverydev}
            mkfs.ext3 /dev/${recoverydev} -L recovery -F
            fsck.ext3 -y /dev/${recoverydev}
            mount /dev/${recoverydev} /media/${recoverydev}
        fi
        cp -p /media/${dev}/MLO /media/${recoverydev}/                   
        cp -p /media/${dev}/u-boot.img /media/${recoverydev}/            
        rm -f /media/${recoverydev}/*.dtb
        cp -p /media/${dev}/*.dtb /media/${recoverydev}/          
        cp -p /media/${dev}/uImage /media/${recoverydev}/    
        cp -p /media/${dev}/ramdisk.gz /media/${recoverydev}/                     
        cp -p /media/${dev}/rootfs.tar.gz /media/${recoverydev}/
        sync
        leds off
    else                                                                             
        echo_msg "recovery part is same!"                                            
    fi
    fi
fi

if [[ -f "$fsfile" || -f "$ubifsfile" ]] && [ -f "/media/${dev}/${configfile}" ] && [ "$advrootfs" = "y" ]; then
    echo_msg "update root file system!"
    leds on
	if [ -f "$fsfile" ]; then
        echo_msg "${fsfile} found" 
	elif [ -f "$ubifsfile" ]; then
        echo_msg "${ubifsfile} found" 
	fi
    if [ "$advfactory" != "y" ]; then   
        if [ -d $OLDPRJDIR/project ] && [ -d $OLDPRJDIR/bin ] && [ -d $OLDPRJDIR/lib ] && [ "$USER_NAME" != "root" ]; then
            echo_msg "backup $OLDPRJDIR project files"
            cd ${OLDPRJDIR}
            tar -czpvf /media/${dev}/$PROJECT_BAK_FILE project/
            cd -
            sync;sync;sleep 1   
        fi
        if [ -d "${TARGET_DIR}/project" ]; then
            echo_msg "backup project files" 
            cd ${TARGET_DIR}
            tar -czpvf /media/${dev}/$PROJECT_BAK_FILE project/
            cd -
        fi
        if [ -f "$BACKUPFILES" ]; then
            backup /media/${dev}
        elif [ -f "/media/${dev}/$LISTFILE" ]; then
            BACKUPFILES="/media/${dev}/$LISTFILE"
            backup /media/${dev}
        else
            [ -f "/media/${rootdev}/etc/passwd" ] && cp -p /media/${rootdev}/etc/passwd /media/${dev}/
            [ -f "/media/${rootdev}/etc/shadow" ] && cp -p /media/${rootdev}/etc/shadow /media/${dev}/
            [ -f "/media/${rootdev}/etc/group" ] && cp -p /media/${rootdev}/etc/group /media/${dev}/
            [ -f "/media/${rootdev}/etc/gshadow" ] && cp -p /media/${rootdev}/etc/gshadow /media/${dev}/
        fi
        sync;sleep 2
    fi
    echo_msg "starting formating disk ${datadev}"
    if [ `is_nand_device` = "yes" ]; then
        umount -l /media/${datadev}
        ubidetach -p /dev/mtd${MTDDATANUM}
        ubiformat /dev/mtd${MTDDATANUM} -y -O 1024
        ubiattach -p /dev/mtd${MTDDATANUM} -O 1024
        ubimkvol /dev/ubi${UBIDATANUM} -N data -m
        mount -t ubifs ubi${UBIDATANUM}_0 /media/${datadev}     
    else
        umount -l /media/${datadev}
        mkfs.ext3 /dev/${datadev} -L data -F
        fsck.ext3 -y /dev/${datadev}
        mount /dev/${datadev} /media/${datadev}
    fi
    echo_msg "starting formating disk ${rootdev}"
    if [ `is_nand_device` = "yes" ]; then
        umount -l /media/${rootdev}
        ubidetach -p /dev/mtd${MTDRFSNUM}
        ubiformat /dev/mtd${MTDRFSNUM} -y -O 1024
        ubiattach -p /dev/mtd${MTDRFSNUM} -O 1024
        ubimkvol /dev/ubi0 -N rootfs -m
        mount -t ubifs ubi0_0 /media/${rootdev}
    else
        umount -l /media/${rootdev}
        mkfs.ext3 /dev/${rootdev} -L rootfs -F
        fsck.ext3 -y /dev/${rootdev}
        mount /dev/${rootdev} /media/${rootdev}
    fi
	if [ -f "$ubifsfile" ]; then
        echo_msg "flash ${ubifsfile} to ${rootdev}"
        umount -l /media/${rootdev}
        ubidetach -p /dev/mtd${MTDRFSNUM}
        ubiformat /dev/mtd${MTDRFSNUM} -f $ubifsfile -y -O 1024
        ubiattach -p /dev/mtd${MTDRFSNUM} -O 1024
        ubimkvol /dev/ubi0 -N rootfs -m
        mount -t ubifs ubi0_0 /media/${rootdev}	
	else
        echo_msg "unzip ${fsfile} to ${rootdev}"
        cd /media/${rootdev}
        tar -xzpf ${fsfile}
        cd -
        sync;sync
	fi
    
    # get new image TAGLINK path
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
    ln -sf $TARGET_DIR/.version /media/${rootdev}/etc/issue
    if [ -f "$appsfile" ]; then
        echo_msg "update applications"
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
        tar -xzpf $appsfile -C $TARGET_DIR
        [ -d $TARGET_DIR/.project ] && mv -f $TARGET_DIR/.project $TARGET_DIR/project
        sync;sync;sleep 2
    fi
    if [ -f "$customfile" ]; then
        echo_msg "update custom package"
        ln -s ${HOMEDIR}/root /media/${rootdev}/home/root
        ln -s ${HOMEDIR}/sysuser /media/${rootdev}/home/sysuser
        ln -s ${HOMEDIR}/ftp /media/${rootdev}/home/ftp
        tar -xzpf $customfile -C /media/${rootdev}
        sync;sync;sleep 1
        rm /media/${rootdev}/home/root
        rm /media/${rootdev}/home/sysuser
        rm /media/${rootdev}/home/ftp
        sync;sync;sleep 1
    fi
    
    if [ "$advfactory" != "y" ]; then
        if [ -f "/media/${dev}/$PROJECT_BAK_FILE" ]; then
            echo_msg "restore project files"
            tar -xzpvf /media/${dev}/$PROJECT_BAK_FILE -C $TARGET_DIR
            rm /media/${dev}/$PROJECT_BAK_FILE
        fi
        if [ -f "/media/${dev}$BACKUPDIR/$LISTFILE" ]; then
            restore /media/${dev}
        else
            [ -f "/media/${dev}/passwd" ] && cp -p /media/${dev}/passwd /media/${rootdev}/etc/ && rm /media/${dev}/passwd
            [ -f "/media/${dev}/shadow" ] && cp -p /media/${dev}/shadow /media/${rootdev}/etc/ && rm /media/${dev}/shadow
            [ -f "/media/${dev}/group" ] && cp -p /media/${dev}/group /media/${rootdev}/etc/ && rm /media/${dev}/group
            [ -f "/media/${dev}/gshadow" ] && cp -p /media/${dev}/gshadow /media/${rootdev}/etc/ && rm /media/${dev}/gshadow
        fi
        sync;sync;sleep 2
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
    sync;sync;sleep 2
    if [ "$HN" == "adam3600" ] || [ "$HN" == "adam3600ds" ] || [ "$HN" == "sys800" ] || [ "$HN" == "amcmq200n" ] || [ "$HN" == "tms10" ]; then
        echo_msg "update $HN firmware"
        insmod $TARGET_DIR/driver/biokernbase.ko
        insmod $TARGET_DIR/driver/boardio.ko
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TARGET_DIR/lib
        $TARGET_DIR/util/AdvFirmupdate -d /media/${dev}
    fi
    if [ "$advcycle" = "y" ]; then
        echo_msg "cycle update..."
    else
        echo_msg "remove ${configfile}"
        rm /media/${dev}/${configfile}
        sync;sync
    fi
    echo_msg "umount the partition"
    cd /
    if [ `is_nand_device` = "yes" ]; then
        # umount
        umount -l /media/${rootdev}
        if [ "$HN" != "wise2834" ] && [ "$HN" != "adam6750" ] && [ "$HN" != "adam67c1" ]; then
            umount -l /media/${recoverydev}
        fi
        umount -l /media/${datadev}
        # detach
        ubidetach -p /dev/mtd$MTDRFSNUM > /dev/null
        if [ "$HN" != "wise2834" ] && [ "$HN" != "adam6750" ] && [ "$HN" != "adam67c1" ]; then
            ubidetach -p /dev/mtd$MTDRECOVERYNUM > /dev/null
        fi
        ubidetach -p /dev/mtd$MTDDATANUM > /dev/null
    else
        umount -l /media/${rootdev}
        umount -l /media/${recoverydev}
        umount -l /media/${datadev}
        echo_msg "check the ext3 partition"
        fsck.ext3 -y /dev/${rootdev}
    fi
    sync;sync   
    leds off
else
    echo_msg "${fsfile} not update!!!"
    if [ "$advcycle" = "y" ]; then
        echo_msg "cycle update..."
    else
        echo_msg "remove ${configfile}"
        rm -f /media/${dev}/${configfile}
        sync;sync
    fi
fi

echo_msg "update log file!"
echo_msg "update finish!"
cp -f /tmp/update.log $UPDATE_LOGFILE
sync;sync;sleep 3
if [ "$advcycle" = "y" ]; then
    poweroff
else
    reboot
fi
sleep 10
} # end recoveryfs()

################################################################################
# update image
busybox hwclock --hctosys -f /dev/rtc1

echo_msg "run ramdisk upgrade"

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
        recoveryfs sda1
        break
    fi
done

#recoveryfs sda1

HN=`cat /proc/board | tr A-Z a-z`
echo_msg "Host Name is $HN"

if [ `is_nand_device` = "yes" ]; then
    if [ "$HN" == "wise2834" ] || [ "$HN" == "adam6750" ] || [ "$HN" == "adam67c1" ]; then
        recoveryfs mmcblk0p1
    else
        recoveryfs mmcblk0p1
        recoveryfs recovery
    fi
else
    recoveryfs mmcblk1p1
    recoveryfs mmcblk0p3
fi

echo_msg "not file found for recovery!!!"
echo_msg "not update!"
sync;sync;sleep 1
reboot

