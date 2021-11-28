#!/bin/bash

#Version : 20210623_x.1
#Limit : only support clone (disk to file) and (file to disk)
#Usage : ./clone_disks.sh SRC DST
#
# 1. Clone disk to file
#    a. Carefuly check the correct disk name 
#       Ex: /dev/sda
#    b. Run command as below
#       ./clone_disks.sh /dev/sda sda.iso 4096 
#            ...
#            Device     Boot   Start      End  Sectors    Size Id Type
#            /dev/sdb1          9000  2105343  2096344 1023,6M  c W95 FAT32 (LBA)
#            /dev/sdb2       2105344 16785407 14680064      7G 83 Linux
#            Please select the end sector : 16785407
#            ......
#            8594124800 bytes (8,6 GB, 8,0 GiB) copied, 246,701 s, 34,8 MB/s
#
# 2. Clone disk to file
#    a. Carefuly check the correct disk name 
#       Ex: /dev/sda
#    b. Run command as below
#          ./clone_disks.sh sda.iso /dev/sda

print_usage()
{
   echo "Please specify the args: $0 src dst [block_size]"
   echo "Example: $0 /dev/sda backup_disk.iso [$DEFAULT_BLOCK_SIZE]"
   echo "Example: $0 backup_disk.iso /dev/sda [$DEFAULT_BLOCK_SIZE]"	
}

check_end_sector()	
{
    fdisk -l $1 && read -p "Please select the end sector : "
    END_SECTOR=$REPLY
}

check_available_size()
{
   df --block-size=$DEFAULT_BLOCK_SIZE $1 | grep -v "Available" | awk '{print $4}'
}

disk_to_file()
{
    mount | grep -i $SRC
    if [ $? -eq 0 ]; then
        echo "PLEASE ENSURE IT NOT HAVE ANY MOUNTED PARTITIONS FROM ( $SRC )."
        exit
    fi
    touch $DST
    check_end_sector $SRC
    SRC_SIZE=$END_SECTOR
    DST_SIZE=`check_available_size $DST`

    if [ $SRC_SIZE -gt $DST_SIZE ]; then
        echo "$DST not enough size"
	exit
    fi
    COUNT=$(($SRC_SIZE/$BLOCK_DIVISOR))
    echo "Cloning $SRC to $DST , block_size=$BLOCK_SIZE, count=$COUNT" 
    dd if=$SRC of=$DST bs=$BLOCK_SIZE count=$COUNT conv=sync,noerror status=progress
}

file_to_disk()
{
    mount | grep -i $DST 
    if [ $? -eq 0 ]; then
        echo "PLEASE ENSURE IT NOT HAVE ANY MOUNTED PARTITIONS FROM ( $DST )."
        exit
    fi
	
    echo "Cloning $SRC to $DST , block_size=$BLOCK_SIZE" 
    dd if=$SRC of=$DST bs=$BLOCK_SIZE conv=sync,noerror status=progress
}

main()
{
    if [ $EUID -ne 0 ]; then
       echo "Please run script with sudo/root."
       exit
    fi
    
    if [[ -z $1 || -z $2 ]]; then
       print_usage
       exit
    fi

    DEFAULT_BLOCK_SIZE=512	
    SRC=$1
    DST=$2
    BLOCK_SIZE=${3:-"$DEFAULT_BLOCK_SIZE"}
    BLOCK_DIVISOR=$(( $BLOCK_SIZE / $DEFAULT_BLOCK_SIZE ))
 
    if [ -b $SRC ]; then
	if [ ! -b $DST ]; then 
            disk_to_file
            exit
	fi
    fi
    if [ -b $DST ]; then
	if [ ! -b $SRC ]; then
            file_to_disk
            exit
	fi
    fi 
    print_usage
}

## Run
main $1 $2 $3

