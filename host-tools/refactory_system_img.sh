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
system_size="685768704"

perl "${f_unpack_pl}" "${f_boot_img}"

f_file_contexts="${cur_dir}/file_contexts"
rm -f "${f_file_contexts}"
cp -uvf "${f_boot_img}-ramdisk/file_contexts" "${f_file_contexts}"
rm -vfr "${f_boot_img}-ramdisk" "${f_boot_img}-ramdisk.cpio.gz" "${f_boot_img}-kernel.gz"

rm -fr "${f_raw_img}" "${d_raw}" 
"${f_simg2img}" "${f_system_img_old}" "${f_raw_img}"
mkdir "${d_system}" "${d_raw}"
sudo mount -t ext4 "${f_raw_img}" "${d_raw}"
cp -ruvf ${d_raw}/* ${d_system}/
sudo umount "${d_raw}"
rmdir "${d_raw}"
rm "${f_raw_img}"

sed -i /ro.setupwizard.enterprise_mode=1/d "${d_system}/build.prop"
sed -i /ro.setupwizard.network_required=true/d "${d_system}/build.prop"

${f_make_ext4fs} -s -T -1 -S ${f_file_contexts} -l "${system_size}" -J -a system "${f_system_img_new}" "${d_system}"
rm -fr "${d_system}"
