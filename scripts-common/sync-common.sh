#!/usr/bin/env sh
export BASE=`pwd`
export MIRROR="https://android.googlesource.com/platform/manifest"
repo_url="git://android.git.linaro.org/tools/repo"
export base_manifest="default.xml"
sync_linaro=true
branch="master"

LOCAL_MANIFEST="git://android.git.linaro.org/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro-master"
#export branch="studio-1.1-dev"

print_usage(){
    echo "$(basename $0) [-nl|--nolinaro] [-b|--branch branch] [-m|--mirror mirror_url]"
    echo "\t -nl|--nolinaro: do not sync linaro source"
    echo "\t -b|--branch branch: sync the specified branch, default master"
    echo "\t -u|--mirror mirror_url: specify the url where you want to sync from"
    echo "\t\t default: $repo_url"
    echo "$(basename $0) [-h|--help]"
    echo "\t -h|--help: print this usage"
}

function parseArgs(){
    while [ -n "$1" ]; do
        case "X$1" in
            X-nl|X--nolinaro)
                sync_linaro=false
                shift
                ;;
            X-b|X--branch)
                if [ -z "$2" ]; then
                    echo "Please specify the branch name for the -b|--branch option"
                    exit 1
                fi
                branch="$2"
                shift
                ;;
            X-h|X--help)
                print_usage
                exit 1
                ;;
            X-*)
                echo "Unknown option: $1"
                print_usage
                exit 1
                ;;
            X*)
                echo "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
}

sync_init(){
    #while ! repo init -u $MIRROR -m ${base_manifest} -b ${branch} --no-repo-verify --repo-url=${repo_url} -g "default,-device,-non-default,hikey,flounder,-darwin,-mips,-x86" --depth=1 -p linux; do
    while ! repo init -u $MIRROR -m ${base_manifest} -b ${branch} --no-repo-verify --repo-url=${repo_url} --depth=1 -g "default,device,-notdefault,-darwin,-mips,-x86" -p linux; do
        sleep 30
    done
}

sync(){
    #Syncronize and check out
    CPUS=$(grep processor /proc/cpuinfo |wc -l)
    while ! repo sync -j ${CPUS} -c --force-sync; do
        sleep 30
    done
}

sync_linaro(){
    cd .repo
    if [ -d ./local_manifests ]; then
        cd ./local_manifests;
        git pull
    else
        git clone ${LOCAL_MANIFEST} -b ${LOCAL_MANIFEST_BRANCH} local_manifests
    fi

    cd ${BASE}

    cp -uvf liuyq-patches/liuyq.xml .repo/local_manifests/liuyq.xml
    if [ -d android-patchsets ]; then
        cp -uvf liuyq-patches/LIUYQ-PATCHSET android-patchsets
    fi
    juno_mali_binary
    hikey_mali_binary
}

juno_mali_binary(){
    local b_name="juno-20151111-vendor.tar.bz2"
    if [ -f ./${b_name} ]; then
        return
    fi
    curl --fail --show-error -b license_accepted_51722ba4ccc270bcd54cb360cb242798=yes http://snapshots.linaro.org/android/binaries/arm/20151111-members-only/vendor.tar.bz2 >${b_name}
    tar jxvf ${b_name}
}

hikey_mali_binary(){
    local b_name="hikey-20150623-vendor.tar.bz2"
    if [ -f ./${b_name} ]; then
        return
    fi
    curl --fail --show-error -b license_accepted_eee6ac0e05136eb58db516d8c9c80d6b=yes http://snapshots.linaro.org/android/binaries/hikey/20150623-members-only/vendor.tar.bz2 >${b_name}
    tar jxvf ${b_name}
}

main(){
    # update myself first
    git pull
    parseArgs "$@"
    sync_init
    if $sync_linaro; then
        sync_linaro
    fi
    sync
}
