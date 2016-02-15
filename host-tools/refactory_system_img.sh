#!/bin/bash

parent_dir=$(cd $(dirname $0); pwd)
cur_dir=$(pwd)
f_unpack_pl="${parent_dir}/unpack.pl"
f_simg2img="${parent_dir}/simg2img"
f_make_ext4fs="${parent_dir}/make_ext4fs"

f_boot_img="${1}"
if [ ! -f "${f_boot_img}" ]; then
    echo "The boot image file specified does not exist: ${f_boot_img}"
    exit 1
fi
f_boot_img_basename=$(basename ${f_boot_img})
f_boot_img_dirname=$(cd $(dirname ${f_boot_img}); pwd)
f_boot_img="${f_boot_img_dirname}/${f_boot_img_basename}"

f_system_img_old="${2}"
if [ ! -f "${f_system_img_old}" ]; then
    echo "The system image file specified does not exist: ${f_system_img_old}"
    exit 1
fi
f_system_img_basename=$(basename ${f_system_img_old})
f_system_img_dirname=$(cd $(dirname ${f_system_img_old}); pwd)
f_system_img_old="${f_system_img_dirname}/${f_system_img_basename}"

f_system_img_new="${cur_dir}/system_new.img"
d_system="${cur_dir}/system"
f_raw_img="${cur_dir}/raw.img"
d_raw="${cur_dir}/raw"
system_size="685768704" #Nexus10
system_size="880803840" #Nexus7

function extract_file_contexts(){
    perl "${f_unpack_pl}" "${f_boot_img}"

    f_file_contexts="${cur_dir}/file_contexts"
    rm -f "${f_file_contexts}"
    cp -uvf "${f_boot_img}-ramdisk/file_contexts" "${f_file_contexts}"
    rm -vfr "${f_boot_img}-ramdisk" "${f_boot_img}-ramdisk.cpio.gz" "${f_boot_img}-kernel.gz"
}

function refactory_sys_img(){
    sudo rm -fr "${f_raw_img}" "${d_raw}" "${d_system}"
    "${f_simg2img}" "${f_system_img_old}" "${f_raw_img}"
    mkdir -p "${d_system}" "${d_raw}"
    sudo mount -t ext4 "${f_raw_img}" "${d_raw}"
    sudo cp -ruf ${d_raw}/* ${d_system}/
    #sudo rm -fr ${d_raw}/priv-app/SetupWizard
    sudo umount "${d_raw}"
    rm -fr "${d_raw}" "${f_raw_img}"
    #mv "${f_raw_img}" ${f_system_img_new}
    sed -i /ro.setupwizard.enterprise_mode=1/d "${d_system}/build.prop"
    sed -i 's/ro.setupwizard.network_required=true/ro.setupwizard.network_required=false/' "${d_system}/build.prop"

    sudo ${f_make_ext4fs} -l ${system_size} -s -T -1 -S ${f_file_contexts} -J -a system "${f_system_img_new}" "${d_system}"

    #sudo rm -fr ${d_system}/priv-app/SetupWizard
    #rm -fr "${d_system}" ${f_file_contexts}
}

extract_file_contexts
refactory_sys_img
