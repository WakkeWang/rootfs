#!/bin/bash
# Authors:
#    LT Thomas <ltjr@ti.com>
#    Chase Maupin
# create-sdcard.sh v0.3

# This distribution contains contributions or derivatives under copyright
# as follows:
#
# Copyright (c) 2010, Texas Instruments Incorporated
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# - Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# - Neither the name of Texas Instruments nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Determine the absolute path to the executable
# EXE will have the PWD removed so we can concatenate with the PWD safely

# usage: 
#    sudo ./create-sdcard.sh
# 

PWD=`pwd`
EXE=`echo $0 | sed s=$PWD==`
EXEPATH="$PWD"/"$EXE"
#FILEPATH=$1
if [ "$FILEPATH" = "" ] ; then
	FILEPATH=$PWD
fi
echo $FILEPATH

clear
cat << EOM

################################################################################

This script will create a bootable SD card from custom or pre-built binaries.

The script must be run with root permissions and from the bin directory of
the SDK

Example:
 $ sudo ./create-sdcard.sh
 or
 $ sudo ./create-sdcard.sh /home/root

Formatting can be skipped if the SD card is already formatted and
partitioned properly.

################################################################################

EOM

AMIROOT=`whoami | awk {'print $1'}`
if [ "$AMIROOT" != "root" ] ; then

	echo "	**** Error *** must run script with sudo"
	echo ""
	exit
fi

THEPWD=$EXEPATH
PARSEPATH=`echo $THEPWD | grep -o '.*ti-sdk.*.[0-9]/'`

if [ "$PARSEPATH" != "" ] ; then
PATHVALID=1
else
PATHVALID=0
fi

#Precentage function
untar_progress ()
{
    TARBALL=$1;
    DIRECTPATH=$2;
    BLOCKING_FACTOR=$(($(gzip --list ${TARBALL} | sed -n -e "s/.*[[:space:]]\+[0-9]\+[[:space:]]\+\([0-9]\+\)[[:space:]].*$/\1/p") / 51200 + 1));
    tar --blocking-factor=${BLOCKING_FACTOR} --checkpoint=1 --checkpoint-action='ttyout=Written %u%  \r' -zxf ${TARBALL} -C ${DIRECTPATH}
	if [ -d $DIRECTPATH/.project ];then
		mv $DIRECTPATH/.project $DIRECTPATH/project
	fi
}

#copy/paste programs
cp_progress ()
{
	CURRENTSIZE=0
	while [ $CURRENTSIZE -lt $TOTALSIZE ]
	do
		TOTALSIZE=$1;
		TOHERE=$2;
		CURRENTSIZE=`sudo du -c $TOHERE | grep total | awk {'print $1'}`
		echo -e -n "$CURRENTSIZE /  $TOTALSIZE copied \r"
		sleep 1
	done
}

check_for_sdcards()
{
        # find the avaible SD cards
        ROOTDRIVE=`mount | grep 'on / ' | awk {'print $1'} |  cut -c6-8`
        PARTITION_TEST=`cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>' | grep -n ''`
        if [ "$PARTITION_TEST" = "" ]; then
	        echo -e "Please insert a SD card to continue\n"
	        while [ "$PARTITION_TEST" = "" ]; do
		        read -p "Type 'y' to re-detect the SD card or 'n' to exit the script: " REPLY
		        if [ "$REPLY" = 'n' ]; then
		            exit 1
		        fi
		        ROOTDRIVE=`mount | grep 'on / ' | awk {'print $1'} |  cut -c6-8`
		        PARTITION_TEST=`cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>' | grep -n ''`
	        done
        fi
}

populate_4_partitions() {
    ENTERCORRECTLY="0"
	while [ $ENTERCORRECTLY -ne 1 ]
	do
		read -e -p 'Enter path where SD card tarballs were downloaded : '  TARBALLPATH

		echo ""
		ENTERCORRECTLY=1
		if [ -d $TARBALLPATH ]
		then
			echo "Directory exists"
			echo ""
			echo "This directory contains:"
			ls $TARBALLPATH
			echo ""
			read -p 'Is this correct? [y/n] : ' ISRIGHTPATH
				case $ISRIGHTPATH in
				"y" | "Y") ;;
				"n" | "N" ) ENTERCORRECTLY=0;continue;;
				*)  echo "Please enter y or n";ENTERCORRECTLY=0;continue;;
				esac
		else
			echo "Invalid path make sure to include complete path"
			ENTERCORRECTLY=0
            continue
		fi
        # Check that tarballs were found
        if [ ! -e "$TARBALLPATH""/boot_partition.tar.gz" ]
        then
            echo "Could not find boot_partition.tar.gz as expected.  Please"
            echo "point to the directory containing the boot_partition.tar.gz"
            ENTERCORRECTLY=0
            continue
        fi

        if [ ! -e "$TARBALLPATH""/rootfs_partition.tar.gz" ]
        then
            echo "Could not find rootfs_partition.tar.gz as expected.  Please"
            echo "point to the directory containing the rootfs_partition.tar.gz"
            ENTERCORRECTLY=0
            continue
        fi

        if [ ! -e "$TARBALLPATH""/start_here_partition.tar.gz" ]
        then
            echo "Could not find start_here_partition.tar.gz as expected.  Please"
            echo "point to the directory containing the start_here_partition.tar.gz"
            ENTERCORRECTLY=0
            continue
        fi
	done

        # Make temporary directories and untar mount the partitions
        mkdir $PWD/boot
        mkdir $PWD/rootfs
        mkdir $PWD/start_here
        # mkdir $PWD/tmp

        mount -t vfat "/dev/""$DEVICEDRIVENAME""1" boot
        mount -t ext3 "/dev/""$DEVICEDRIVENAME""2" rootfs
        mount -t ext3 "/dev/""$DEVICEDRIVENAME""3" start_here

        # Remove any existing content in case the partitions were not
        # recreated
        sudo rm -rf boot/*
        sudo rm -rf rootfs/*
        sudo rm -rf start_here/*

        # Extract the tarball contents.
cat << EOM

################################################################################
        Extracting boot partition tarball

################################################################################
EOM
        untar_progress $TARBALLPATH/boot_partition.tar.gz tmp/
        if [ -e "./tmp/MLO" ]
        then
            cp ./tmp/MLO boot/
        fi
        cp -rf ./tmp/* boot/

cat << EOM

################################################################################
        Extracting rootfs partition tarball

################################################################################
EOM
        untar_progress $TARBALLPATH/rootfs_partition.tar.gz rootfs/

cat << EOM

################################################################################
        Extracting start_here partition to temp directory

################################################################################
EOM
        rm -rf tmp/*
        untar_progress $TARBALLPATH/start_here_partition.tar.gz tmp/

cat << EOM

################################################################################
        Extracting CCS tarball

################################################################################
EOM
        mv tmp/CCS-5*.tar.gz .
        untar_progress CCS-5*.tar.gz tmp/
        rm CCS-5*.tar.gz

cat << EOM

################################################################################
        Copying Contents to START_HERE

################################################################################
EOM

        TOTALSIZE=`sudo du -c tmp/* | grep total | awk {'print $1'}`
        cp -rf tmp/* start_here/ &
        cp_progress $TOTALSIZE start_here/
        sync;sync
        # Fix up the START_HERE partitoin permissions
        chown nobody -R start_here
        chgrp nogroup -R start_here
        chmod -R g+r+x,o+r+x start_here/CCS

        umount boot rootfs start_here
        sync;sync

        # Clean up the temp directories
        rm -rf boot rootfs start_here tmp
}

# find the avaible SD cards
ROOTDRIVE=`mount | grep 'on / ' | awk {'print $1'} |  cut -c6-9`
if [ "$ROOTDRIVE" = "root" ]; then
    ROOTDRIVE=`readlink /dev/root | cut -c1-3`
else
    ROOTDRIVE=`echo $ROOTDRIVE | cut -c1-3`
fi

PARTITION_TEST=`cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>' | grep -n ''`

# Check for available mounts
check_for_sdcards

echo -e "\nAvailible Drives to write images to: \n"
echo "#  major   minor    size   name "
cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>' | grep -n ''
echo " "

DEVICEDRIVENUMBER=
while true;
do
	read -p 'Enter Device Number or 'n' to exit: ' DEVICEDRIVENUMBER
	echo " "
        if [ "$DEVICEDRIVENUMBER" = 'n' ]; then
                exit 1
        fi

        if [ "$DEVICEDRIVENUMBER" = "" ]; then
                # Check to see if there are any changes
                check_for_sdcards
                echo -e "These are the Drives available to write images to:"
                echo "#  major   minor    size   name "
                cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>' | grep -n ''
                echo " "
               continue
        fi

	DEVICEDRIVENAME=`cat /proc/partitions | grep -v 'sda' | grep '\<sd.\>' | grep -n '' | grep "${DEVICEDRIVENUMBER}:" | awk '{print $5}'`
	if [ -n "$DEVICEDRIVENAME" ]
	then
	        DRIVE=/dev/$DEVICEDRIVENAME
	        DEVICESIZE=`cat /proc/partitions | grep -v 'sda' | grep '\<sd.\>' | grep -n '' | grep "${DEVICEDRIVENUMBER}:" | awk '{print $4}'`
                break
	else
		echo -e "Invalid selection!"
                # Check to see if there are any changes
                check_for_sdcards
                echo -e "These are the only Drives available to write images to: \n"
                echo "#  major   minor    size   name "
                cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>' | grep -n ''
                echo " "
	fi
done

echo "$DEVICEDRIVENAME was selected"
#Check the size of disk to make sure its under 16GB
if [ $DEVICESIZE -gt 17000000 ] ; then
cat << EOM

################################################################################

		**********WARNING**********

	Selected Device is greater then 16GB
	Continuing past this point will erase data from device
	Double check that this is the correct SD Card

################################################################################

EOM
	ENTERCORRECTLY=0
	while [ $ENTERCORRECTLY -ne 1 ]
	do
		read -p 'Would you like to continue [y/n] : ' SIZECHECK
		echo ""
		echo " "
		ENTERCORRECTLY=1
		case $SIZECHECK in
		"y")  ;;
		"n")  exit;;
		*)  echo "Please enter y or n";ENTERCORRECTLY=0;;
		esac
		echo ""
	done

fi
echo ""

DRIVE=/dev/$DEVICEDRIVENAME
NUM_OF_DRIVES=`df | grep -c $DEVICEDRIVENAME`
if [ "$NUM_OF_DRIVES" != "0" ]; then
        echo "Unmounting the $DEVICEDRIVENAME drives"
        for ((c=1; c<="$NUM_OF_DRIVES"; c++ ))
        do
                unmounted=`df | grep '\<'$DEVICEDRIVENAME$c'\>' | awk '{print $1}'`
                if [ -n "$unmounted" ]
                then
	                echo " unmounted ${DRIVE}$c"
	                sudo umount -f ${DRIVE}$c
                fi

        done
fi

# Refresh this variable as the device may not be mounted at script instantiation time
# This will always return one more then needed
NUM_OF_PARTS=`cat /proc/partitions | grep -v 'sda' | grep -c $DEVICEDRIVENAME`
for ((c=1; c<"$NUM_OF_PARTS"; c++ ))
do
        SIZE=`cat /proc/partitions | grep -v 'sda' | grep '\<'$DEVICEDRIVENAME$c'\>'  | awk '{print $3}'`
        echo "Current size of $DEVICEDRIVENAME$c $SIZE bytes"
done

# check to see if the device is already partitioned
SIZE1=`cat /proc/partitions | grep -v 'sda' | grep '\<'$DEVICEDRIVENAME'1\>'  | awk '{print $3}'`
SIZE2=`cat /proc/partitions | grep -v 'sda' | grep '\<'$DEVICEDRIVENAME'2\>'  | awk '{print $3}'`
SIZE3=`cat /proc/partitions | grep -v 'sda' | grep '\<'$DEVICEDRIVENAME'3\>'  | awk '{print $3}'`
SIZE4=`cat /proc/partitions | grep -v 'sda' | grep '\<'$DEVICEDRIVENAME'4\>'  | awk '{print $3}'`

PARTITION="0"
if [ -n "$SIZE1" -a -n "$SIZE2" ] ; then
	if  [ "$SIZE1" -gt "72000" -a "$SIZE2" -gt "700000" ]
	then
		PARTITION=1

		if [ -z "$SIZE3" -a -z "$SIZE4" ]
		then
			#Detected 2 partitions
			PARTS=2

		elif [ "$SIZE3" -gt "1000" -a -z "$SIZE4" ]
		then
			#Detected 3 partitions
			PARTS=3

		else
			echo "SD Card is not correctly partitioned"
			PARTITION=0
		fi
	fi
else
	echo "SD Card is not correctly partitioned"
	PARTITION=0
	PARTS=0
fi


#Partition is found
if [ "$PARTITION" -eq "1" ]
then
cat << EOM

################################################################################

   Detected device has $PARTS partitions already

   Re-partitioning will allow the choice of 2 or 3 partitions

################################################################################

EOM

	ENTERCORRECTLY=0
	while [ $ENTERCORRECTLY -ne 1 ]
	do
		read -p 'Would you like to re-partition the drive anyways [y/n] : ' CASEPARTITION
		echo ""
		echo " "
		ENTERCORRECTLY=1
		case $CASEPARTITION in
		"y")  echo "Now partitioning $DEVICEDRIVENAME ...";PARTITION=0;;
		"n")  echo "Skipping partitioning";;
		*)  echo "Please enter y or n";ENTERCORRECTLY=0;;
		esac
		echo ""
	done

fi

PARTITION=4

#Section for partitioning the drive

#create 4 partitions
if [ "$PARTITION" -eq "4" ]
then

# set the PARTS value as well
PARTS=4

cat << EOM

################################################################################

		Now making 4 partitions

################################################################################

EOM

dd if=/dev/zero of=$DRIVE bs=1024 count=1024

SIZE=`fdisk -l $DRIVE | grep Disk | awk '{print $5}'`

echo DISK SIZE - $SIZE bytes

CYLINDERS=`echo $SIZE/255/63/512 | bc`

parted -s $DRIVE mklabel msdos
parted -s $DRIVE unit cyl mkpart primary fat32 -- 0 5
parted -s $DRIVE set 1 boot on
parted -s $DRIVE unit cyl mkpart primary ext3 -- 5 50
parted -s $DRIVE unit cyl mkpart primary ext3 -- 50 76
parted -s $DRIVE unit cyl mkpart primary ext3 -- 76 -0 

cat << EOM

################################################################################

		Partitioning Boot

################################################################################
EOM
    sleep 2
	mkfs.vfat -F 32 -n "boot" ${DRIVE}1
cat << EOM

################################################################################

		Partitioning Rootfs

################################################################################
EOM
	mkfs.ext3 -L "rootfs" ${DRIVE}2
cat << EOM

################################################################################

		Partitioning recovery 

################################################################################
EOM
	mkfs.ext3 -L "recovery" ${DRIVE}3
cat << EOM
################################################################################

		Partitioning Data 

################################################################################
EOM
	mkfs.ext3 -L "data" ${DRIVE}4
	sync
	sync
# set the PARTS value as well
PARTS=4
fi



#Break between partitioning and installing file system
cat << EOM


################################################################################

   Partitioning is now done
   Continue to install filesystem or select 'n' to safe exit

   **Warning** Continuing will erase files any files in the partitions

################################################################################


EOM
ENTERCORRECTLY=0
while [ $ENTERCORRECTLY -ne 1 ]
do
	read -p 'Would you like to continue? [y/n] : ' EXITQ
	echo ""
	echo " "
	ENTERCORRECTLY=1
	case $EXITQ in
	"y") ;;
	"n") exit;;
	*)  echo "Please enter y or n";ENTERCORRECTLY=0;;
	esac
done

# If this is a three partition card then we will jump to a function to
# populate the three partitions and then exit the script.  If not we
# go on to prompt the user for input on the two partitions
if [ "$PARTS" -eq "3" ]
then
    populate_4_partitions
    exit 0
fi

#Add directories for images
export START_DIR=$PWD
# mkdir $START_DIR/tmp
export PATH_TO_SDBOOT=boot
export PATH_TO_SDROOTFS=rootfs
export PATH_TO_RECOVERY=recovery
export PATH_TO_DATA=data
# export PATH_TO_TMP_DIR=$START_DIR/tmp


echo " "
echo "Mount the partitions "
mkdir $PATH_TO_SDBOOT
mkdir $PATH_TO_SDROOTFS
mkdir $PATH_TO_RECOVERY
mkdir $PATH_TO_DATA

sudo mount -t vfat ${DRIVE}1 boot/
sudo mount -t ext3 ${DRIVE}2 rootfs/
sudo mount -t ext3 ${DRIVE}3 recovery/
sudo mount -t ext3 ${DRIVE}4 data/



echo " "
echo "Emptying partitions "
echo " "
sudo rm -rf  $PATH_TO_SDBOOT/*
sudo rm -rf  $PATH_TO_SDROOTFS/*
sudo rm -rf  $PATH_TO_RECOVERY/*
sudo rm -rf  $PATH_TO_DATA/*

echo ""
echo "Syncing...."
echo ""
sync
sync
sync

FILEPATHOPTION=2
# SDK DEFAULTS
if [ $FILEPATHOPTION -eq 2  ] ; then
	ENTERCORRECTLY=0
	BOOTUSERFILEPATH=$FILEPATH
	while [ $ENTERCORRECTLY -ne 1 ]
	do
		if [ "$ISRIGHTPATH" = "n" ]; then
			read -p 'please input the right path: ' BOOTUSERFILEPATH
		fi
		echo ""
		ENTERCORRECTLY=1
		if [ -f $BOOTUSERFILEPATH ]
		then
			echo "File exists"
			echo ""
		elif [ -d $BOOTUSERFILEPATH ]
		then
			echo "Directory exists"
			echo "PATH:"$BOOTUSERFILEPATH
			echo "This directory contains:"
			ls $BOOTUSERFILEPATH
			echo ""
			read -p 'Is this correct? [y/n] : ' ISRIGHTPATH
				case $ISRIGHTPATH in
				"y") ;;
				"n") ENTERCORRECTLY=0;;
				*)  echo "Please enter y or n";ENTERCORRECTLY=0;;
				esac
		else
			echo "Invalid path make sure to include complete path"

			ENTERCORRECTLY=0
		fi
	done
ROOTFSUSERFILEPAT=$BOOTUSERFILEPAT

	# Check if user entered a tar or not for Boot
	ISBOOTTAR=`ls $BOOTUSERFILEPATH | grep boot | grep .tar.gz | awk {'print $1'}`
	if [ -n "$ISBOOTTAR" ]
	then
		BOOTPATHOPTION=2
	else
		BOOTPATHOPTION=1
		BOOTFILEPATH=$BOOTUSERFILEPATH
		MLO=`ls $BOOTFILEPATH | grep MLO | awk {'print $1'}`
		UIMAGE=`ls $BOOTFILEPATH | grep uImage | awk {'print $1'}`
		BOOTIMG=`ls $BOOTFILEPATH | grep u-boot | grep .img | awk {'print $1'}`
		BOOTBIN=`ls $BOOTFILEPATH | grep u-boot | grep .bin | awk {'print $1'}`
		BOOTUENV=`ls $BOOTFILEPATH | grep uEnv.txt | awk {'print $1'}`
		RAMDISK=`ls $BOOTFILEPATH | grep ramdisk | grep .gz | awk {'print $1'}`
		DTB=`ls $BOOTFILEPATH | grep am335x | grep .dtb | awk {'print $1'}`
		ROOTFSTAR=`ls $BOOTFILEPATH | grep rootfs | grep .tar.gz | awk {'print $1'}`
		APPSTAR=`ls $BOOTFILEPATH | grep apps | grep .tar.gz | awk {'print $1'}`
		CUSTOMTAR=`ls $BOOTFILEPATH | grep custom | grep .tar.gz | awk {'print $1'}`
	fi

fi

cat << EOM
################################################################################

	Copying files now... will take minutes

################################################################################

Copying boot partition
EOM


if [ $BOOTPATHOPTION -eq 1 ] ; then

	echo ""
	#copy boot files out of board support
	if [ "$MLO" != "" ] ; then
		cp $BOOTFILEPATH/$MLO $PATH_TO_SDBOOT/MLO
		cp $BOOTFILEPATH/$MLO $PATH_TO_RECOVERY/MLO
		echo "MLO copied"
	else
		echo "MLO file not found"
	fi

	echo ""

	if [ "$BOOTIMG" != "" ] ; then
		cp $BOOTFILEPATH/$BOOTIMG $PATH_TO_SDBOOT/u-boot.img
		cp $BOOTFILEPATH/$BOOTIMG $PATH_TO_RECOVERY/u-boot.img
		echo "u-boot.img copied"
	elif [ "$BOOTBIN" != "" ] ; then
		cp $BOOTFILEPATH/$BOOTBIN $PATH_TO_SDBOOT/u-boot.bin
		echo "u-boot.bin copied"
	else
		echo "No U-Boot file found"
	fi

	echo ""

	if [ "$UIMAGE" != "" ] ; then
		cp $BOOTFILEPATH/$UIMAGE $PATH_TO_SDBOOT/uImage
		cp $BOOTFILEPATH/$UIMAGE $PATH_TO_RECOVERY/uImage
		echo "uImage copied"
	else
		echo "No uImage not found"
	fi

	echo ""

	if [ "$RAMDISK" != "" ] ; then
		cp $BOOTFILEPATH/$RAMDISK $PATH_TO_SDBOOT/ramdisk.gz
		cp $BOOTFILEPATH/$RAMDISK $PATH_TO_RECOVERY/ramdisk.gz
		echo "ramdisk.gz copied"
	else
		echo "No ramdisk.gz file not found"
	fi

	echo ""

	if [ "$DTB" != "" ] ; then
		cp $BOOTFILEPATH/$DTB $PATH_TO_SDBOOT
		cp $BOOTFILEPATH/$DTB $PATH_TO_RECOVERY
		echo "dtb copied"
	else
		echo "No dtb file found"
	fi

	echo ""

	if [ "$ROOTFSTAR" != "" ] ; then
		untar_progress $BOOTFILEPATH/$ROOTFSTAR $PATH_TO_SDROOTFS
		cp $BOOTFILEPATH/$ROOTFSTAR $PATH_TO_RECOVERY/rootfs.tar.gz
		echo "rootfs unziped"
		
        if [ -z "$1" ]; then
            TAGLINK_PATH=`cat $PATH_TO_SDROOTFS/etc/profile | grep TAGLINK_PATH | head -1 | awk -F = '{print $2}'`
		else
		    if [ "$1" != "/home/root" ] && [ "$1" != "/home/sysuser" ]; then
                TAGLINK_PATH=/home/root
			else
			    TAGLINK_PATH=$1
			fi			
		fi
		
        if [ "${TAGLINK_PATH}" == "" ]; then
            TAGLINK_PATH=/home/root
        fi
        echo "TagLink path is $TAGLINK_PATH"
        TAGLINK_PATH=`echo ${TAGLINK_PATH} | awk -F / '{print $3}'`
        TAGLINK_PATH=/${TAGLINK_PATH}		
	else
		echo "No rootfs.tar.gz file found"
	fi

	echo ""

	if [ -d $PATH_TO_DATA$TAGLINK_PATH ] ; then
		rm -rf $PATH_TO_DATA$TAGLINK_PATH
	fi
	mkdir -p $PATH_TO_DATA$TAGLINK_PATH

	mkdir -p $PATH_TO_DATA/root
	mkdir -p $PATH_TO_DATA/sysuser
	mkdir -p $PATH_TO_DATA/ftp
	cp $PATH_TO_SDROOTFS/etc/skel/.bashrc $PATH_TO_DATA/root
	cp $PATH_TO_SDROOTFS/etc/skel/.profile $PATH_TO_DATA/root
	cp $PATH_TO_SDROOTFS/etc/skel/.bash_history $PATH_TO_DATA/root
	cp $PATH_TO_SDROOTFS/etc/skel/.bashrc $PATH_TO_DATA/sysuser
	cp $PATH_TO_SDROOTFS/etc/skel/.profile $PATH_TO_DATA/sysuser
	cp $PATH_TO_SDROOTFS/etc/skel/.bash_history $PATH_TO_DATA/sysuser
	cp $PATH_TO_SDROOTFS/etc/version $PATH_TO_DATA$TAGLINK_PATH/.version
	ln -sf /home$TAGLINK_PATH/.version $PATH_TO_SDROOTFS/etc/issue
	echo "home user file copied"

    DEVICE_NAME=`cat $PATH_TO_SDROOTFS/etc/devicename | awk '{print $1}'`
	if [ "$DEVICE_NAME" = "WISE4610" ]; then
	    mkdir -p $PATH_TO_DATA/root/mbs-fuji
	    mkdir -p $PATH_TO_DATA/root/java
	    mkdir -p $PATH_TO_DATA/root/sno
	    sync
	    untar_progress $BOOTFILEPATH/ejre-7u75-fcs-b13-linux-arm-vfp-hflt-server_headless-18_dec_2014.tar.gz $PATH_TO_DATA/root/java
	    echo "wise4610 jre package unziped"
	    sync
	    ln -sf /home/root/mbs-fuji $PATH_TO_SDROOTFS/opt/mbs-fuji
	    ln -sf /home/root/java $PATH_TO_SDROOTFS/opt/java
	    ln -sf /home/root/sno $PATH_TO_SDROOTFS/opt/sno
	fi
	if [ "$DEVICE_NAME" = "ADAM5630" ] || [ "$DEVICE_NAME" = "ECU1051" ] || [ "$DEVICE_NAME" = "SYS800022" ] || [ "$DEVICE_NAME" = "ECU1050" ] || [ "$DEVICE_NAME" = "ECU1051E" ]; then
        sed "/\/dev\/ubi1_0/d" -i $PATH_TO_SDROOTFS/etc/fstab
        sed "/\/dev\/ubi2_0/d" -i $PATH_TO_SDROOTFS/etc/fstab
        echo "/dev/mmcblk0p4      /home                  auto       defaults             0  2" >> $PATH_TO_SDROOTFS/etc/fstab
	fi
    
	if [ "$APPSTAR" != "" ] ; then
		untar_progress $BOOTFILEPATH/$APPSTAR $PATH_TO_DATA$TAGLINK_PATH
		cp $BOOTFILEPATH/$APPSTAR $PATH_TO_RECOVERY/apps.tar.gz
		echo "applications unziped"
	else
		echo "No apps.tar.gz file found"
	fi

	if [ "$CUSTOMTAR" != "" ] ; then
		ln -s $PATH_TO_DATA/root $PATH_TO_SDROOTFS/home/root
		ln -s $PATH_TO_DATA/sysuser $PATH_TO_SDROOTFS/home/sysuser
		ln -s $PATH_TO_DATA/ftp $PATH_TO_SDROOTFS/home/ftp
		untar_progress $BOOTFILEPATH/$CUSTOMTAR $PATH_TO_SDROOTFS
		cp $BOOTFILEPATH/$CUSTOMTAR $PATH_TO_RECOVERY/custom.tar.gz
		rm $PATH_TO_SDROOTFS/home/root
		rm $PATH_TO_SDROOTFS/home/sysuser
		rm $PATH_TO_SDROOTFS/home/ftp
		echo "custom applications unziped"
	else
		echo "No custom.tar.gz file found"
	fi

	echo ""

	if [ "$BOOTUENV" != "" ] ; then
		cp $BOOTFILEPATH/$BOOTUENV $PATH_TO_SDBOOT/uEnv.txt
		echo "uEnv.txt copied"
	fi

	echo ""

	if [ "$TAGLINK_PATH" != "/root" ] ; then
        chown -R 1000:1001 $PATH_TO_DATA$TAGLINK_PATH
        chown -R root:root $PATH_TO_DATA/root
	else
        chown -R root:root $PATH_TO_DATA$TAGLINK_PATH
        chown -R 1000:1001 $PATH_TO_DATA/sysuser
    fi
fi

echo ""
echo "Syncing..."
sync
sync
sync
sync
sync
sync
sync
sync


echo " "
echo "Un-mount the partitions "
sudo umount -f $PATH_TO_SDBOOT
sudo umount -f $PATH_TO_SDROOTFS
sudo umount -f $PATH_TO_RECOVERY
sudo umount -f $PATH_TO_DATA


echo " "
#echo "Remove created temp directories "
#sudo rm -rf $PATH_TO_TMP_DIR
sudo rm -rf $PATH_TO_SDROOTFS
sudo rm -rf $PATH_TO_SDBOOT
sudo rm -rf $PATH_TO_RECOVERY
sudo rm -rf $PATH_TO_DATA


echo " "
echo "Operation Finished"
echo " "
