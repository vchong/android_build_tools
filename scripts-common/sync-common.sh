#!/bin/bash

export BASE=`pwd`

source ${BASE}/scripts-common/helpers

export MIRROR="https://android.googlesource.com/platform/manifest"

repo_url="git://android.git.linaro.org/tools/repo"
export base_manifest="default.xml"
sync_linaro=true

version="master"
board="hikey"

sync_init(){
    echo "repo init -u ${MIRROR} -m ${base_manifest} -b ${MANIFEST_BRANCH} --no-repo-verify --repo-url=${repo_url} --depth=1 -g ${REPO_GROUPS} -p linux"
    repo init -u ${MIRROR} -m ${base_manifest} -b ${MANIFEST_BRANCH} --no-repo-verify --repo-url=${repo_url} --depth=1 -g ${REPO_GROUPS} -p linux
}

sync(){
    echo "repo sync -j${CPUS} -c --force-sync"
    repo sync -j${CPUS} -c --force-sync
}

func_sync_linaro(){
    mkdir -p .repo
    cd .repo
    if [ -d ./local_manifests ]; then
        cd ./local_manifests;
	echo "git pull local manifest"
        git pull
    else
	echo "git clone ${LOCAL_MANIFEST} -b ${LOCAL_MANIFEST_BRANCH} local_manifest"
        git clone ${LOCAL_MANIFEST} -b ${LOCAL_MANIFEST_BRANCH} local_manifests
    fi

    cd ${BASE}

    cp -auvf swg.xml .repo/local_manifests/
    if [ ! -d android-patchsets ]; then
        mkdir -p android-patchsets
    fi
    # can have my own local patch file in this repo
    #cp -auvf SWG-PATCHSET android-patchsets/
    #hikey_mali_binary_new
}

hikey_mali_binary(){
    local b_name="hikey-20160113-vendor.tar.bz2"
    if [ -f ./${b_name} ]; then
        return
    fi
    curl --fail --show-error -b license_accepted_eee6ac0e05136eb58db516d8c9c80d6b=yes http://snapshots.linaro.org/android/binaries/hikey/20160113/vendor.tar.bz2 >${b_name}
    tar xavf ${b_name}
}

hikey_mali_binary_new(){
	wget --no-check-certificate https://dl.google.com/dl/android/aosp/linaro-hikey-20170523-4b9ebaff.tgz
	for i in linaro-hikey-*.tgz; do
		tar xf $i
	done
	mkdir junk
	echo 'cat "$@"' >junk/more
	chmod +x junk/more
	export PATH=`pwd`/junk:$PATH
	for i in extract-linaro-hikey.sh; do
		echo -e "\nI ACCEPT" |./$i
	done
	rm -rf junk linaro-hikey-*.tgz extract-linaro-hikey.sh
}

main(){
    # update myself first
    git pull
    get_config
    export_config ${board} ${version}

    if $sync_linaro; then
        func_sync_linaro
    fi
    # if MIRROR is local then repo sync
    if [[ "X${MIRROR}" = X/* ]]; then
        mirror_dir=$(dirname $(dirname ${MIRROR}))
        echo "Skip repo sync local mirror for now!"
        #repo sync -j${CPUS} "${mirror_dir}"
    fi
    # init repos
    sync_init
    # sync repos
    sync
    mkdir -p archive
    repo manifest -r -o archive/pinned-manifest-"$(date +%Y-%m-%d_%H:%M)".xml
}

function func_apply_patch(){
    local patch_name=$1
    if [ -z "${patch_name}" ]; then
        return
    fi

    if [ ! -f "./android-patchsets/${patch_name}" ]; then
	echo "android-patchsets/${patch_name}: no such file!"
        return
    fi

    ./android-patchsets/${patch_name}
    if [ $? -ne 0 ]; then
        echo "Failed to run ${patch_name}"
        exit 1
    fi
}
