#!/bin/bash

#Author: Joshua Cagle
#Organization: University of Oregon

# Script to make a Raid5 Logical Volume from the following partitions:
# /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdf1

# This script assumes that the partitions have already been created and
# are all the same size (5GB). We are also assuming that partitions
# sda1 and sda2 house the operating system.

function pause(){
   read -p "Press [Enter] key to continue..."
}

# This function does not allow script to continue until the lvm is completely synced.
function synchro(){
while [[ ! $var = 100.00 ]]
do
   clear
var=$(lvs /dev/raid/raid5lv | awk '{print $5}' | grep ^[0-9])
        echo "Script will continue when 100.00% LVM RAID syncronization has been completed."
        echo ""
        echo "Syncronization $var% complete"
        sleep 5
done
}

echo "Creating physical volumes"
pvcreate /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdf1

echo "Creating new volume group named raid"
vgcreate raid /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdf1
pause

echo "Creating RAID5 logical volume with 4 stripes."
lvcreate --name raid5lv --type raid5 -i 3 --verbose --size 14.9GiB raid
pause

synchro
pause

echo "Formatting logical volume with the ext3 filesystem."
mkfs.ext3 /dev/raid/raid5lv
pause

echo "Mounting /dev/raid/raid5lv logical volume to /logical directory."
mount /dev/raid/raid5lv /logical
pause

df -h
