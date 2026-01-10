# ntfs-wininstall-create
Automated tool to create Windows install disks for moments when install.wim exceeds 4 GB to be placed in FAT32 partition.
Software used: FUSE, ntfs-3g, Rufus's UEFI:NTFS boot image, GNU Coreutils 

Usage: wininstall.sh [source-iso] [device name]

Example: wininstall.csh Windows.iso /dev/sdb


Tested and works on Debian 13

