#!/bin/bash

set -e

export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

# overwrite remote MIRROR in sync-common.sh if local mirror exists
if [ -d /home/ubuntu/aosp-mirror/platform/manifest.git ]; then
    export MIRROR="/home/ubuntu/aosp-mirror/platform/manifest.git"
else
    echo "No local mirrors"
fi

# overwrite branch, version and board in sync-common.sh
branch="android-p-preview-1"
version="p"
#board="hikey" #default

# overwrite LOCAL_MANIFEST{_BRANCH} in sync-common.sh
#default
#LOCAL_MANIFEST="https://android-git.linaro.org/git/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro-p-preview"

#main -j ${CPUS} -nl -t hikey -v p -b android-p-preview-1 -h
main "$@"

if true; then
${BASE}/sync-projects.sh  \
                          android-patchsets \
                          android-build-configs \
                          device/linaro/hikey \
                          kernel/linaro/hisilicon/ \
                          frameworks/av \
                          frameworks/base \
                          frameworks/native \
                          system/sepolicy \
                          system/core \
                          system/netd \
                          packages/inputmethods/LatinIME \
                          hardware/interfaces \
                        external/libdrm \
                        frameworks/opt/net/ethernet \
                        system/connectivity/wificond \
                        bootable/recovery \
                        libcore \
                        external/optee_test \
                        external/optee_client \
                        external/optee_examples \
                        optee/optee_os
fi

for i in ${PATCHSETS}; do
	echo "applying patchset: $i"
	func_apply_patch $i
done
echo "applying patchset: swg-mods-p"
#func_apply_patch swg-mods-p

#./build.sh -j ${CPUS}
##./build.sh -j $(getconf _NPROCESSORS_ONLN)
exit
