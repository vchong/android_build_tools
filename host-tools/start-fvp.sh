#!/bin/bash

# Need to update according to your environment
flexlm_account="yongqin.liu"
RTSM_AEMv8_HOME="/opt/arm/FVP_Base_AEMv8A-AEMv8A/"
LINARO_IMAGE_TOOLS_DIR="/backup/srv/linaro-image-tools"
USE_BRIDGE=false
BRIDGE_IF="ARM${USER}"

#Please do not update followings
parent_dir=$(cd $(dirname $0); pwd)
export MODEL_PATH=${RTSM_AEMv8_HOME}
export PATH=$PATH:${RTSM_AEMv8_HOME}/bin/
export ARMLMD_LICENSE_FILE="8224@127.0.0.1"
USE_IMG=false
clean=false
port="5555"
bz2_dir=""

function printUsage(){
    echo "$(basename $0) [-f|--force] [-i|--img] bz2_dir"
    echo "$(basename $0) [-h|--help]"
    return
}

function checkFileExist(){
    local f_path="$1"
    if [ -z "$f_path" ]; then
        echo "Pleae specify the file path to check"
        exit 1
    fi
    if ! [ -f "${f_path}" ]; then
        echo "File ${f_path} does not exist"
        printUsage
        exit 1
    fi
}

function parseArgs(){
    while [ -n "$1" ]; do
        case "X$1" in
            X-f|X--force)
                clean=true
                shift
                ;;
            X-i|X--img)
                USE_IMG=true
                shift
                ;;
            X-h|X--help)
                printUsage
                exit 1
                ;;
            X-*)
                echo "Unknown option: $1"
                exit 1
                ;;
            X*)
                if [ -n "${bz2_dir}" ];then
                    echo "$(basename $0) [-f] img_dir"
                    exit 1
                else
                    bz2_dir=$1
                    shift
                fi
                ;;
        esac
    done

    if [ -z "${bz2_dir}" ]; then
        bz2_dir=$(pwd)
    else
        bz2_dir=$(cd $(dirname $bz2_dir); pwd)
    fi

    checkFileExist "${bz2_dir}/boot.tar.bz2"
    if ${USE_IMG}; then
        checkFileExist "${bz2_dir}/system.img"
        checkFileExist "${bz2_dir}/userdata.img"
    else
        checkFileExist "${bz2_dir}/system.tar.bz2"
        checkFileExist "${bz2_dir}/userdata.tar.bz2"
    fi
}

function installImage(){
    if ${clean}; then
        rm -fr "${bz2_dir}/mmc.bin"
        rm -fr "${bz2_dir}/boot"
    fi

    #cd ${image_tool_dir}
    #git pull
    #if [ $? -ne 0 ]; then
    #    echo "Please fix te conflicts for linaro-imae-tools in ${image_tool_dir}"
    #    exit 1
    #fi
    if [ -n "${LINARO_IMAGE_TOOLS_DIR}" ]; then
        PATH=${LINARO_IMAGE_TOOLS_DIR}:$PATH
        export PATH
    fi
    if [ ! -f "${bz2_dir}/mmc.bin" ]; then
        lamc_cmd="linaro-android-media-create \
            --image_file ${bz2_dir}/mmc.bin \
            --dev vexpress \
            --boot ${bz2_dir}/boot.tar.bz2"
        if ${USE_IMG}; then
            lamc_cmd="${lamc_cmd} \
                --systemimage ${bz2_dir}/system.img \
                --userdataimage ${bz2_dir}/userdata.img"
        else
            lamc_cmd="${lamc_cmd} \
                --system ${bz2_dir}/system.tar.bz2 \
                --userdata ${bz2_dir}/userdata.tar.bz2"
        fi
        ${lamc_cmd}
        if [ $? -ne 0 ]; then
            echo "Failed to create the image file"
            exit 1
        fi
    fi

    if [ ! -d "$bz2_dir/boot" ]; then
        tar -jxvf ${bz2_dir}/boot.tar.bz2 -C $bz2_dir
        ln -s $bz2_dir/boot/fvp-base-gicv2-psci.dtb $bz2_dir/boot/fdt.dtb
    fi
}

function startFvp(){
    ssh -L 8224:localhost:8224 -L 18224:localhost:18224 -N ${flexlm_account}@flexlm.linaro.org &
    sleep 5
    dir_boot="${bz2_dir}/boot"
    cd ${dir_boot}

    if ! ${USE_BRIDGE}; then
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
        -C bp.hostbridge.interfaceName=${BRIDGE_IF} \
        -C bp.smsc_91c111.enabled=true \
        -C bp.smsc_91c111.mac_address="8e:14:b0:c8:96:d1"
        #-C bp.smsc_91c111.mac_address=auto
    fi
}
function main(){
    parseArgs "$@"
    installImage
    startFvp
}

main "$@"
exit 0
