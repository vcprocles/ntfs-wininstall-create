# ntfs-wininstall-create
Automated tool to create Windows install disks for moments when install.wim exceeds 4 GB to be placed in FAT32 partition. C Shell (csh) is required to run this script.
Other software used: FUSE, ntfs-3g, Rufus's UEFI:NTFS boot image, GNU Coreutils 

Usage: wininstall.csh [source-iso] [device name]

Example: wininstall.csh Windows.iso /dev/sdb


Tested and works on Ubuntu 22.04
Doesn't work correctly on Ubuntu 20.04 (#1)
