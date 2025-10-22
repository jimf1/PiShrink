#!/usr/bin/bash
# Adjust images made by pishrink to account for the change to PARTUUID made by parted

img=$1
############### Adjust PARTUUID ******************
echo "fixUUID.sh: Adjusting Partition UUID"
loopDEV=$(losetup -Pf --show $img)              #Get device
echo "fixUUID.sh: Loop device is: $loopDEV"
loopPART1="${loopDEV}p1"                       #Get partitions
loopPART2="${loopDEV}p2"
echo "fixUUID.sh: Loop partition1 name is $loopPART1"
echo "fixUUID.sh: Loop partition2 name is $loopPART2"
mkdir /mnt/img1 /mnt/img2                       #Make dirs in mount
mount $loopPART1 /mnt/img1                      #Mount boot part
mount $loopPART2 /mnt/img2                      #Mount root fs part
UUIDPART1=$(lsblk -no PARTUUID ${loopPART1})    #Get PARTUUID for boot
UUIDPART2=$(lsblk -no PARTUUID ${loopPART2})    #GET PARTUUID for root fs
UUIDBASE=$(echo $UUIDPART1 | cut -d '-' -f 1) 
echo "fixUUID.sh: PARTUUID for partition 1 is $UUIDPART1"
echo "fixUUID.sh: PARTUUID for partition 2 is $UUIDPART2"
echo "fixUUID.sh: UUIDBASE is $UUIDBASE"
sed  -i "s|\(PARTUUID=\)[^-]*|\1$UUIDBASE|" /mnt/img1/cmdline.txt   #Change partuuid in boot
sed  -i "s|\(PARTUUID=\)[^-]*|\1$UUIDBASE|" /mnt/img2/etc/fstab     #Change partuuid in root fs

#Cleanup adjusting PARTUUID

umount /mnt/img1
umount /mnt/img2
losetup -D
rmdir /mnt/img1
rmdir /mnt/img2
echo "fixUUID.sh: Done"

################### Done adjusting PARTUUIDs
#############################################################################
