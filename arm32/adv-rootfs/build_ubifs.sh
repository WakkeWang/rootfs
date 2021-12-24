#!/bin/bash

# ubinize configuration file
config_file=ubinize.cfg
image_file=ubifs.img

check_result() {
if [ $? -ne 0 ]
then
    echo "FAILED"
else
    echo "SUCCESSFUL"
fi
}

check_program() {
for cmd in "$@"
do
    which ${cmd} > /dev/null 2>&1
    if [ $? -ne 0 ]
    then
        echo
        echo "Cannot find command /"${cmd}/""
        echo
        exit 1
    fi
done
}

if [ -z "$1" ] || [ -z "$2" ] ; then
    echo "Usage: ./build_fs.sh DEVICE_NAME PATH_TO_ROOTFS" 
    echo "example:"
    echo "  $0 ECU1051 ./target"
    echo "    build ubifs root file system"
    exit 1
fi

if [ "$1" = "WISE2834" ] || [ "$1" = "ADAM67C1" ]  || [ "$1" = "ADAM6717" ] || [ "$1" = "ADAM6750" ] || [ "$1" = "ECU1051" ] || [ "$1" = "ECU1051B" ] || [ "$1" = "SYS800022" ] || [ "$1" = "ECU1050" ] || [ "$1" = "ECU1051E" ] || [ "$1" = "ECU1251D" ] || [ "$1" = "SYS800023" ] || [ "$1" = "SYS800024" ]; then
    echo "build 512M nand root file system."
    page_size_in_bytes=4096
	pages_per_block=64
	partition_size_in_bytes=209715200
	blocks_per_device=2048
	vid_hdr_offset=512
elif [ "$1" = "ADAM5630" ] || [ "$1" = "ECU1051BG" ]; then
    echo "build 1024M nand root file system."
    page_size_in_bytes=4096
	pages_per_block=64
	partition_size_in_bytes=209715200
	blocks_per_device=4096
	vid_hdr_offset=1024
fi

path_to_rootfs=$2
if [ -d $path_to_rootfs ]; then
    chown -R root:root $path_to_rootfs
else
    echo "The path $path_to_rootfs is not exist, please check it!"
    exit 1
fi

# wear_level_reserved_blocks is 1% of total blcoks per device
wear_level_reserved_blocks=`expr $blocks_per_device / 100`
echo "Reserved blocks for wear level                            [$wear_level_reserved_blocks]"

#logical_erase_block_size is physical erase block size minus 2 pages for UBI
logical_pages_per_block=`expr $pages_per_block - 1`
logical_erase_block_size=`expr $page_size_in_bytes \* $logical_pages_per_block`
echo "Logical erase block size                                  [$logical_erase_block_size]bytes."

#Block size = page_size * pages_per_block
block_size=`expr $page_size_in_bytes \* $pages_per_block`
echo "Block size                                                [$block_size]bytes."

#physical blocks on a partition = partition size / block size
partition_physical_blocks=`expr $partition_size_in_bytes / $block_size`
echo "Physical blocks in a partition                            [$partition_physical_blocks]"

#Logical blocks on a partition = physical blocks on a partitiion - reserved for wear level
patition_logical_blocks=`expr $partition_physical_blocks - $wear_level_reserved_blocks`
echo "Logical blocks in a partition                             [$patition_logical_blocks]"

#File-system volume = Logical blocks in a partition * Logical erase block size
fs_vol_size=`expr $patition_logical_blocks \* $logical_erase_block_size`
echo "File-system volume                                        [$fs_vol_size]bytes."

echo
echo "Generating configuration file..."
echo "[ubifs]"  > $config_file
echo "mode=ubi" >> $config_file
echo "image=$image_file" >> $config_file
echo "vol_id=0" >> $config_file
echo "vol_size=$fs_vol_size" >> $config_file
echo "vol_type=dynamic" >> $config_file
echo "vol_name=rootfs" >> $config_file
echo "vol_flags=autoresize" >> $config_file
echo

# Generate ubifs image
echo "Generating ubifs..."
mkfs.ubifs -F -x lzo -m $page_size_in_bytes -e $logical_erase_block_size -c $patition_logical_blocks -o $image_file -d $path_to_rootfs
check_result
echo "Generating ubi image out of the ubifs..."
ubinize -o rootfs.ubi -m $page_size_in_bytes -p $block_size -s $page_size_in_bytes $config_file -O $vid_hdr_offset -v
check_result

rm -f $image_file
rm -f $config_file

