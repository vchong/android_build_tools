#!/bin/bash

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
		-nl|--nolinaro)
			echo "Skip local manifests sync"
			sync_linaro=false
			;;
		-j)	# set build parallellism
			shift
			echo "Num threads: $1"
			CPUS=$1
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
		-u)     # overwrite MIRROR in sync-common.sh
			# default remote is https://android.googlesource.com/platform/manifest
			# default local above overwrites default remote
			# specify your own here using -u
			shift
			echo "export MIRROR=$1"
			export MIRROR=$1
			;;
		-d)
			echo "Print debug"
			dbg=true
			;;
		*)
			echo "Unknown option: $1"
			;;
	esac
	shift
done

main

${BASE}/sync-projects.sh -j ${CPUS} -d \
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
	echo ""
	echo ""
	echo "applying patchset: $i"
	func_apply_patch $i
done

if [ "$version" = "o" ] || [ "$version" = "n" ]; then
	echo ""
	echo ""
	echo "applying patchset: swg-mods-${version}"
	func_apply_patch swg-mods-${version}
else
	echo "no swg-mods patchsets applied"
fi

#./build.sh -j ${CPUS}
##./build.sh -j $(getconf _NPROCESSORS_ONLN)
exit
