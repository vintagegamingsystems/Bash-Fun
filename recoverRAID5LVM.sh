#!/bin/bash

#Author: Joshua Cagle
#Organization: University of Oregon

# Script restores RAID5 logical volume named raid5lvm.

function pause(){
   read -p "Press [Enter] key to continue..."
}
function synchro() {
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

vgscan
pause

echo "Failing over to hot spare."
lvconvert --repair raid/raid5lv

lvs -a -o name,copy_percent,devices raid
pause

echo "Checking Sychronization of RAID5 Logical Volume"
synchro
pause

echo "Partitioning /dev/sde drive"
hardDrive="/dev/sde"
echo "d
n
p
1


w
"|fdisk $hardDrive
pause

vgchange -an raid
pause

echo "Umounting /logical directory"
umount /logical
pause

echo "Activating raid volume group."
vgchange -ay raid
pause

# Finds uuid of failed drive.
# Exports standard output and standard error of the pvscan command to the variable uuid.
uuid=$(pvscan 2>&1)
uuid=$(echo $uuid | awk '{print $6}' | sed 's/.$//')

# Finds current restoration file.
w=0
lines=$(ls -l /etc/lvm/archive/ | awk '{print $9}' | grep ^raid_ | sort)
for line in ${lines[@]}
do
   lines[$w]=$line
        ((w++))
done
((w--))

echo "Repairing logical volume."
lvconvert --repair /dev/raid/raid5lv -vvvv
pause

# Calls synchro function.
synchro
pause

# Inserts
echo "Creating new physical volume from restore file."
pvcreate --uuid "$uuid" --restorefile /etc/lvm/archive/${lines[w]} /dev/sde1
pause

echo "Repairing volume group meta data."
lvm vgcfgrestore raid
pause

echo "Reactivating volume group."
vgchange -ay raid
pause

echo "Resizing physical volume."
pvresize /dev/sde1
pause

echo "Repairing logical volume."
lvconvert --repair /dev/raid/raid5lv -vvvv
pause

echo "Resyncing logical volume."
lvchange --resync /dev/raid/raid5lv
pause

echo "Removing missing Physical Volumes from the volume group named raid"
vgreduce --removemissing raid
pause

echo "Adding physical volume /dev/sde1 back into the volume group named raid"
vgextend raid /dev/sde1
pause

vgdisplay raid
pause

echo "Checking for errors and repairing them."
e2fsck -y /dev/raid/raid5lv
pause

echo "Mounting logical volume"
mount /dev/raid/raid5lv /logical
