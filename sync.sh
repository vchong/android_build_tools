#!/usr/bin/env sh

export BASE=`pwd`
#export MIRROR="https://android.googlesource.com/platform/manifest"
export MIRROR="http://android.git.linaro.org/git/platform/manifest.git"
#export MIRROR="/media/liuyq/ext4/android-mirror/aosp/platform/manifest.git"
repo_url="git://android.git.linaro.org/tools/repo"
export base_manifest="default.xml"
export branch="android-5.0.0_r7"

sync(){
    
    while ! repo init -u $MIRROR -m ${base_manifest} -b ${branch} --no-repo-verify --repo-url=${repo_url}; do
        sleep 30
    done

    #Syncronize and check out
    while ! repo sync -j 16; do
        sleep 30
    done
}

sync_linaro(){
    cd .repo
    if [ -d ./local_manifests ]; then
        cd ./local_manifests;
        git pull
    else
        git clone git://android.git.linaro.org/platform/manifest.git -b linaro_android_5.0.0 local_manifests
    fi
    cd ${BASE}

    if [ -d ./android-patchsets ]; then
        cd ./android-patchsets
        git pull
    else
        git clone https://android.git.linaro.org/git/android-patchsets.git android-patchsets
    fi
    cd ${BASE}
    mali_binary
}

juno_mali_binary(){
    b_name="juno_vendor.tar.bz2"
    if [ -f ./${b_name} ]; then
        return 
    fi
    curl --fail --silent --show-error -b license_accepted_51722ba4ccc270bcd54cb360cb242798=yes http://snapshots.linaro.org/android/binaries/arm/20141112/vendor.tar.bz2 >${b_name}
    tar jxvf ${b_name}
}

sync
sync_linaro
