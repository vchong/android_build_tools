#!/bin/bash

disk=""
boot_part=""
rootfs_part=""

print_usage() {
        echo "Usage: $0 sd_card_device"
        echo
        echo "Example:"
        echo "    $0 /dev/mmcblk0"
}

parse_arguments() {
        if [ $# -ne 1 ]; then
                echo "Error: Wrong arguments count ($#)" >&2
                print_usage
                exit 1
        fi

        disk=$1
        boot_part=${disk}p1
        rootfs_part=${disk}p2

        if [ $disk != "/dev/mmcblk0" ]; then
                echo "PROTECTION!!! Use only /dev/mmcblk0 or modify script!" >&2
                exit 1
        fi

        if [ ! -e $disk ]; then
                echo "Error: $disk file not found" >&2
                exit 1
        fi
}
# Assuming, DISK=/dev/mmcblk0, lsblk is very useful for determining the device id.
#   export DISK=/dev/mmcblk0
# Erase partition table/labels on microSD card:
#   sudo dd if=/dev/zero of=${DISK} bs=1M count=10
# Install Bootloader:
#   sudo dd if=./u-boot/MLO of=${DISK} count=2 seek=1 bs=128k
#   sudo dd if=./u-boot/u-boot.img of=${DISK} count=4 seek=1 bs=384k
# Create Partition Layout:
#   With util-linux v2.26, sfdisk was rewritten and is now based on libfdisk.
#     sudo sfdisk --version
#     sfdisk from util-linux 2.27.1
#   sfdisk >= 2.26.x
#     sudo sfdisk ${DISK} <<-__EOF__
#      4M,,L,*
#      __EOF__
#   sfdisk <= 2.25.x
#     sudo sfdisk --unit M ${DISK} <<-__EOF__
#     4,,L,*
#     __EOF__
create_partitions() {
        echo "---> Erase partition table/labels on micro-SD card..."
        sudo dd if=/dev/zero of=${disk} bs=1M count=1

        echo
        echo "---> Create partition layout..."
        sudo sfdisk ${disk} << EOF
                2048,100M,0x0c,*
                ,,L,-
EOF
#https://eewiki.net/display/linuxonarm/BeagleBoard-X15
#sudo sfdisk --unit M ${DISK} <<-__EOF__
#4,,L,*
#__EOF__

        if [ ! -e $boot_part ]; then
                echo "Error: $boot_part file not found" >&2
                exit 1
        fi

        if [ ! -e $rootfs_part ]; then
                echo "Error: $rootfs_part file not found" >&2
                exit 1
        fi

        echo
        echo "---> Format partitions..."
        echo "  --> Format partition 1 (boot)..."
        sudo mkfs.vfat -F 32 -n "boot" $boot_part
        echo "  --> Format partition 2 (rootfs)..."
        sudo mkfs.ext4 -F -L "rootfs" $rootfs_part
}

parse_arguments $*
create_partitions
