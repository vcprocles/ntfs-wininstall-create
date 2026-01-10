#!/bin/bash
set -euo pipefail

#getting args
image=$1
device=$2
image=$(realpath "$image")

#check for root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script needs to run as root, as it writes directly to devices"
    exit
fi

#checking if this is actually a drive
if [ -b "$device" ]; then
    echo "looks like a real device..."
else
    echo "$device is not a drive or does not exist"
    exit
fi

#checking if the iso file exists
if [ ! -f "$image" ]; then
    echo "$image not found"
    exit
fi

#checking if there are mounted filesystems on a drive
set +e
mountcheck=$(mount | grep "$device")
set -e
if [ -z "$mountcheck" ]; then
echo "seems to be unused..."
else
echo "Specified device has mounted filesystems, check the parameters, make sure you're specifying the correct device, and unmount all filesystems before retrying"
exit
fi

#preparing
tempdir="/tmp/winusb"
mkdir $tempdir
echo "copying the partitioning script"
cp "$PWD"/newpart.sfdisk $tempdir/newpart.sfdisk
cd $tempdir
echo "downloading uefi:ntfs image"
wget -q https://github.com/pbatard/rufus/raw/master/res/uefi/uefi-ntfs.img
mkdir -p $tempdir/isofile
echo "mounting iso file"
mount -o loop "$image" $tempdir/isofile
echo "partitioning the drive"
sfdisk "$device" < $tempdir/newpart.sfdisk
echo "creating filesystem"
ntfspartition=$device"2"
mkfs.ntfs -f "$ntfspartition"
echo "mounting filesystem"
mkdir -p $tempdir/wininstall
mount -t ntfs-3g "$ntfspartition" $tempdir/wininstall -o rw,sync
echo "copying installation files..."
cp -rv $tempdir/isofile/* $tempdir/wininstall/
echo "copying done. writing the bootloader with NTFS driver..."
bootpartition=$device"1"
dd if=$tempdir/uefi-ntfs.img of="$bootpartition" status=progress
echo "bootloader installed. unmounting the iso file and the thumbdrive"
umount $tempdir/isofile
umount $tempdir/wininstall
echo "all done, cleaing the mess and exiting"
rm -rf $tempdir
exit