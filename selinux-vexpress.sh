#!/bin/bash

clean=$1 && shift

support_selinux=true

ssh -L 8224:localhost:8224 -L 18224:localhost:18224 -N yongqin.liu@flexlm.linaro.org &
sleep 5
parent_dir=$(cd $(dirname $0); pwd)
bz2_dir="${parent_dir}/out/target/product/fvp/"
RTSM_AEMv8_HOME="/opt/arm/FVP_Base_AEMv8A-AEMv8A/"
port="5555"

if [ "X${clean}" = "X-f" ];then
    rm -fr "${bz2_dir}/mmc.bin"
    rm -fr "$bz2_dir/boot"
fi

image_tool_dir="/backup/srv/linaro-image-tools"
#cd ${image_tool_dir}
#git pull
#if [ $? -ne 0 ]; then
#    echo "Please fix te conflicts for linaro-imae-tools in ${image_tool_dir}"
#    exit 1
#fi
if [ ! -f "${bz2_dir}/mmc.bin" ]; then
    ${image_tool_dir}/linaro-android-media-create \
	--image_file ${bz2_dir}/mmc.bin \
	--dev vexpress \
	--system ${bz2_dir}/system.tar.bz2 \
	--userdata ${bz2_dir}/userdata.tar.bz2 \
	--boot ${bz2_dir}/boot.tar.bz2 
    if [ $? -ne 0 ]; then
        echo "Failed to create the image file"
        exit 1
    fi
fi

if [ ! -d "$bz2_dir/boot" ]; then
	tar -jxvf ${bz2_dir}/boot.tar.bz2 -C $bz2_dir
    ln -s $bz2_dir/boot/fvp-base-gicv2-psci.dtb $bz2_dir/boot/fdt.dtb
fi
dir_boot="${bz2_dir}/boot"
export MODEL_PATH=${RTSM_AEMv8_HOME}
export PATH=$PATH:${RTSM_AEMv8_HOME}/bin/
export ARMLMD_LICENSE_FILE="8224@127.0.0.1"

cd ${dir_boot}

if false; then
${RTSM_AEMv8_HOME}/models/Linux64_GCC-4.1/FVP_Base_AEMv8A-AEMv8A \
    -C pctl.startup=0.0.0.0 \
    -C bp.secure_memory=0 \
    -C cluster0.NUM_CORES=4 \
    -C cluster1.NUM_CORES=4 \
    -C bp.dram_size=0x8 \
    -C cache_state_modelled=0 \
    -C bp.pl011_uart0.untimed_fifos=1 \
    -C bp.secureflashloader.fname=bl1.bin \
    -C bp.flashloader0.fname=fvp_fip.bin \
    -C bp.virtioblockdevice.image_path=${bz2_dir}/mmc.bin \
    -C bp.hostbridge.userNetworking=true \
    -C bp.hostbridge.userNetPorts="${port}=${port}" \
    -C bp.smsc_91c111.enabled=1
    #-C bp.flashloader0.fname=uefi_fvp-base.bin \
else
${RTSM_AEMv8_HOME}/models/Linux64_GCC-4.1/FVP_Base_AEMv8A-AEMv8A \
    -C pctl.startup=0.0.0.0 \
    -C bp.secure_memory=0 \
    -C cluster0.NUM_CORES=4 \
    -C cluster1.NUM_CORES=4 \
    -C cache_state_modelled=0 \
    -C bp.pl011_uart0.untimed_fifos=1 \
    -C bp.secureflashloader.fname=bl1.bin \
    -C bp.flashloader0.fname=fvp_fip.bin \
    -C bp.virtioblockdevice.image_path=${bz2_dir}/mmc.bin \
    -C bp.hostbridge.interfaceName=ARM$USER \
    -C bp.smsc_91c111.enabled=true \
    -C bp.smsc_91c111.mac_address="8e:14:b0:c8:96:d1"
    #-C bp.smsc_91c111.mac_address=auto
fi
exit 0
