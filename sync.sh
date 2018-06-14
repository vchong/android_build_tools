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

##########################################################
##########################################################
while [ "$1" != "" ]; do
	case $1 in
		-b)     # overwrite branch in sync-common.sh
			# default is master
			# eg android-8.1.0_r29 or android-p-preview-1
			shift
			echo "branch=$1"
			branch=$1
			;;
		-v)     # overwrite version in sync-common.sh
			# default is master
			# eg o or p
			shift
			echo "version=$1"
			version=$1
			;;
		-t)     # overwrite board in sync-common.sh
			# default is hikey
			# no other eg atm
			shift
			echo "board=$1"
			board=$1
			;;
		-m)     # overwrite LOCAL_MANIFEST in sync-common.sh
			# default is https://android-git.linaro.org/git/platform/manifest.git
			# no other eg atm
			shift
			echo "LOCAL_MANIFEST=$1"
			LOCAL_MANIFEST=$1
			;;
		-n)     # overwrite LOCAL_MANIFEST_BRANCH in sync-common.sh
			# default is linaro-master
			# eg linaro-oreo or linaro-p-preview
			shift
			echo "LOCAL_MANIFEST_BRANCH=$1"
			LOCAL_MANIFEST_BRANCH=$1
			;;
		-u)     # overwrite MIRROR in sync-common.sh
			# default remote is https://android.googlesource.com/platform/manifest
			# default local above overwrites default remote
			# specify your own here using -u
			shift
			echo "export MIRROR=$1"
			export MIRROR=$1
			;;
                *)
                        echo "Unknown option: $1"
                        ;;
	esac
	shift
done

#main -j ${CPUS} -nl -t ${board} -v {version} -b {branch} -h
main "$@"

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

for i in ${PATCHSETS}; do
	echo "applying patchset: $i"
	func_apply_patch $i
done
echo "applying patchset: swg-mods-${version}"
func_apply_patch swg-mods-${version}

#./build.sh -j ${CPUS}
##./build.sh -j $(getconf _NPROCESSORS_ONLN)
exit
