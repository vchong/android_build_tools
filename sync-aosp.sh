#!/usr/bin/env sh

export BASE=`pwd`
#mirror="http://android.git.linaro.org/git/platform/manifest.git"
mirror="git://android.git.linaro.org/platform/manifest.git"
repo_url="git://android.git.linaro.org/tools/repo"
base_manifest="default.xml"
branch="master"

sync(){
    
    while ! repo init -u ${mirror} -m ${base_manifest} -b ${branch} --no-repo-verify --repo-url=${repo_url}; do
        sleep 30
    done

    #Syncronize and check out
    while ! repo sync -j 16; do
        sleep 30
    done
}

sync
