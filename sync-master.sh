#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

if [ -d /SATA3/aosp-mirror/platform/manifest.git ]; then
    export MIRROR="/SATA3/aosp-mirror/platform/manifest.git"
elif [ -d /home/yongqin.liu/aosp-mirror/platform/manifest.git ]; then
    export MIRROR="/home/yongqin.liu/aosp-mirror/platform/manifest.git"
else
    echo "Please specify value for MIRROR"
fi
branch="master"

LOCAL_MANIFEST=http://android.git.linaro.org/git/platform/manifest.git
LOCAL_MANIFEST_BRANCH=linaro-master

#cp -uvf android-tools/kernel.xml .repo/local_manifests/kernel.xml
main "$@"

func_apply_patch hikey-optee
#func_apply_patch hikey-optee-kernel-4.4
#apply_patch nexus9-workarounds
func_apply_patch get-hikey-blobs

#./build.sh
