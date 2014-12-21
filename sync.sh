#!/usr/bin/env sh

export BASE=`pwd`
export MIRROR="https://android.googlesource.com/platform/manifest"
#export MIRROR="http://android.git.linaro.org/git/platform/manifest.git"
#export MIRROR="/media/liuyq/ext4/android-mirror/aosp/platform/manifest.git"
repo_url="git://android.git.linaro.org/tools/repo"
export base_manifest="default.xml"

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

sync_linaro=true
branch="master"
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
    juno_mali_binary
}

juno_mali_binary(){
    b_name="juno_vendor.tar.bz2"
    if [ -f ./${b_name} ]; then
        return 
    fi
    curl --fail --silent --show-error -b license_accepted_51722ba4ccc270bcd54cb360cb242798=yes http://snapshots.linaro.org/android/binaries/arm/20141112/vendor.tar.bz2 >${b_name}
    tar jxvf ${b_name}
}

main(){
    sync
    if $sync_linaro; then
        sync_linaro
    fi
}
main "$@"
