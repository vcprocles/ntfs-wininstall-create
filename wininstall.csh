#!/bin/csh -f
set image = $1
set device = $2
set image = `realpath $image`
set user = `whoami`
if ($user != "root") then
goto not_root
endif
echo "checking if device has mounted filesystems, to not rewrite something accidentally"
set mountscheck = `mount | grep $device`
if ($%mountscheck == 0) then
goto device_checked
else
goto device_has_mounted_filesystems
endif
device_checked:
echo "device seems to be unused"
echo "creating temporary directory"
set tempdir = "/tmp/winusb"
mkdir $tempdir
echo "copying partitioning script to the temporary directory"
cp ./usbdrive7G.sfdisk $tempdir/usbdrive7G.sfdisk
cd $tempdir
echo "downloading uefi:ntfs image"
wget -q https://github.com/pbatard/rufus/raw/master/res/uefi/uefi-ntfs.img 
mkdir ./isofile
echo "mounting iso file"
mount -o loop $image ./isofile
echo "creating partitions"
sfdisk $device < ./usbdrive7G.sfdisk
echo "creating filesystem"
set ntfspartition = $device"1"
mkfs.ntfs -f $ntfspartition
echo "mounting filesystem"
mkdir ./wininstall
mount -t ntfs-3g $ntfspartition ./wininstall -o rw
echo "copying installation files, all copied stuff will be dumped on screen"
cp -rv ./isofile/* ./wininstall/
echo "copying done. writing UEFI:NTFS loader onto a drive"
set bootpartition = $device"2"
dd if=./uefi-ntfs.img of=$bootpartition status=progress
echo "bootloader installed. unmounting iso file and installation partition"
umount ./isofile
umount ./wininstall
echo "all done, cleaning the mess and exiting"
rm -rf $tempdir
exit
device_has_mounted_filesystems:
echo "Specified device has mounted filesystems, check the parameters, make sure you're specifying the correct device, and unmount all filesystems before retrying"
exit
not_root:
echo "This script needs to run as root, unless it would need to use obscene amounts of sudo"
exit
