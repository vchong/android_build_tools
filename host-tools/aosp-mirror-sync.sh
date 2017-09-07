#!/bin/bash

manifest_git="/home/ubuntu/aosp-mirror/platform/manifest.git"
IRC_NOTIFY_CHANNEL="#linaro-android"
#IRC_NOTIFY_CHANNEL="#liuyq-sync"
IRC_NOTIFY_SERVER="irc.freenode.net"
IRC_NOTIFY_NICK="aosp-tag-check"

BASE_DIR=$(cd $(dirname $0); pwd)
export PATH=${BASE_DIR}:${PATH}
cd ${BASE_DIR}
#rm -fr .repo

#while ! repo init -u https://android.googlesource.com/a/mirror/manifest --mirror; do
#    sleep 10
#done
#repo init -u https://android.googlesource.com/mirror/manifest --mirror --repo-url=git://android.git.linaro.org/tools/repo
#repo init -u http://android.git.linaro.org/git/platform/manifest.git --repo-url=git://android.git.linaro.org/tools/repo
function echoerror {
    echo "$@" 1>&2;
}

function sync_aosp_mirror(){
    echo "Started aosp-mirror sync:" `date` >>sync.timestamp
    local try_count=1
    while ! repo sync; do
        try_count=$((try_count + 1))
        if [ ${try_count} -gt 10 ]; then
            irc_notify "Failed to run repo sync for 10 times"
            exit 1
        fi
        sleep 3600
    done
    echo "Finished aosp-mirror sync:" `date` >>sync.timestamp
    echo "===================================">>sync.timestamp
}


android_tag_prefix="android-8"
function get_latest_tag_for_aosp(){
    local PWD_BASE=$(cd $PWD; pwd)
    cd ${manifest_git}
    git fetch --all -q
    if [ $? -ne 0 ]; then
        echoerror "Failed to fetch new tags for AOSP"
        echoerror "Please check the status and try again"
        exit 1
    fi

    local latest_branch_aosp=$(git branch -a|grep "${android_tag_prefix}"|sort -V|tail -n1|tr -d ' ')
    if [ -z "${latest_branch_aosp}" ]; then
        echoerror "Failed to get the tags information for AOSP"
        echoerror "Please check the status and try again"
        exit 1
    fi
    cd ${PWD_BASE}

    echo "${latest_branch_aosp}"
}

function get_latest_tag_for_lcr(){
    local url_lcr="https://android-git.linaro.org/android-build-configs.git/plain/lcr-reference-hikey-o"
    local latest_branch_lcr=$(curl ${url_lcr}|grep '^MANIFEST_BRANCH='|cut -d= -f2)
    if [ -z "${latest_branch_lcr}" ]; then
        echoerror "Failed to get the tags information for LCR"
        echoerror "Please check the status and try again"
        exit 1
    fi
    echo "${latest_branch_lcr}"
}

function has_new_tags(){
    local latest_branch_aosp=$(get_latest_tag_for_aosp ${manifest_git})
    local latest_branch_lcr=$(get_latest_tag_for_lcr)

    if [ -n "${latest_branch_aosp}" ] && [ -n "${latest_branch_lcr}" ]; then
        echo "AOSP: ${latest_branch_aosp}"
        echo "LCR: ${latest_branch_lcr}"
        # android-7.1.0_r4 android-7.0.0_r6 android-7.0.0_r14
        if [ "X${latest_branch_aosp}" != "X${latest_branch_lcr}" ]; then
            local newer_ver=$(echo -e "${latest_branch_aosp}\n${latest_branch_lcr}"|sort -V|tail -n1)
            if [ "X${newer_ver}" = "X${latest_branch_aosp}" ]; then
                echoerror "There are new tags released"
                return 0
            fi
        fi
    fi
    return 1
}

function irc_notify(){
    local message="${1}"
    if [ -z "${message}" ]; then
        return
    fi

    local config=$(mktemp -p /tmp/ irc_message_XXX)


    cat <<__EOF__ >${config}
NICK ${IRC_NOTIFY_NICK}
USER ${IRC_NOTIFY_NICK} +i * :$0
JOIN ${IRC_NOTIFY_CHANNEL}
PRIVMSG ${IRC_NOTIFY_CHANNEL} :${message}
PRIVMSG liuyq :${message}
QUIT
__EOF__

    trap "rm -f ${config};exit 0" INT TERM EXIT

    tail -f ${config} | nc ${IRC_NOTIFY_SERVER} 6667|while read MESSAGE; do
        case "${MESSAGE}" in
            PING*)
                echo "PONG${MESSAGE#PING}" >> $config
                ;;
            *QUIT*)
                ;;
            *PART*)
                ;;
            *JOIN*)
                ;;
            *NICK*)
                ;;
            *PRIVMSG*)
                echo "${MESSAGE}" | sed -nr "s/^:([^!]+).*PRIVMSG[^:]+:(.*)/[$(date '+%R')] \1> \2/p"
                ;;
            *\(Client\ Quit\)* )
                echo "Quit:$$"
                kill -9 $$
                ;;
            *)
                echo "${MESSAGE}";;
        esac
    done

    echo "IRC Notify Finished"
}

dir_aosp_master="/home/ubuntu/aosp-master"
function change_log(){
    export old_tag="$1"
    export new_tag="$2"
    if [ -z "${old_tag}" ] || [ -z "${new_tag}" ]; then
        return
    fi
    local changelog_file="${3}"
    if [ -z "${changelog_file}" ]; then
        return
    fi
    cd ${dir_aosp_master}
    repo init -b ${new_tag}
    repo sync -j4
    repo forall -c ' \
            diff_commits=$(git log --oneline --no-merges ${old_tag}..${new_tag} 2>/dev/null|wc -l)
            if [ ${diff_commits} -gt 0 ]; then \
                echo ========${REPO_PROJECT} between ${old_tag}..${new_tag}=========
                git diff --stat ${old_tag} ${new_tag}
                git log --oneline --no-merges ${old_tag}..${new_tag} 2>/dev/null
                echo ""
            fi;
               '|tee ${changelog_file}.tmp

    total_line=$(grep -e 'file changed' -e "files changed" ${changelog_file}.tmp|awk 'BEGIN { file_changed=0; insertions=0; deletions=0} { file_changed=file_changed+$1; insertions=insertions+$4; deletions=deletions+$6} END { printf("%d file changed, %d insertions(+), %d deletions(-)\n", file_changed, insertions, deletions)}')
    echo "***************************************************************"  >${changelog_file}
    echo "***************************************************************"  >>${changelog_file}
    echo "  ${total_line}"  >>${changelog_file}
    echo "***************************************************************"  >>${changelog_file}
    echo "***************************************************************"  >>${changelog_file}
    cat ${changelog_file}.tmp >>${changelog_file}
    sudo -u yongqin.liu scp ${changelog_file} people.linaro.org:/home/yongqin.liu/public_html/ChangeLogs
}

function update_android_build_config(){
    local old_tag=$1
    local new_tag=$2
    local url_change_log=$3
    local OLD_PWD=$(pwd)
    #local f_redirect="/tmp/git.log"
    local f_redirect="/dev/null"

    local git_build_config="http://android-git.linaro.org/git/android-build-configs.git"
    local dir_build_config="/home/ubuntu/android-build-configs"
    local reviewers="r=yongqin.liu@linaro.org,r=bernhard.rosenkranzer@linaro.org,r=vishal.bhoj@linaro.org,r=jakub.pavelek@linaro.org,r=serban.constantinescu@linaro.org,r=julien.duraj@linaro.org"
    #local reviewers="r=yongqin.liu@linaro.org"

    if [ ! -d "${dir_build_config}" ]; then
        git clone -b master ${git_build_config} ${dir_build_config} &>${f_redirect}
        if [ $? -ne 0 ]; then
            echoerror "Failed to clone reposiotry ${git_build_config} to ${dir_build_config}" |tee -a ${f_redirect}
            return
        fi
    fi

    cd ${dir_build_config}
    gitdir=$(git rev-parse --git-dir) && \
    sudo -u yongqin.liu scp -p -P 29418 yongqin.liu@android-review.linaro.org:hooks/commit-msg /tmp &>${f_redirect} && \
    cp /tmp/commit-msg ${gitdir}/hooks/

    git pull &>${f_redirect}
    if [ $? -ne 0 ]; then
        echo "Failed to pull under ${dir_build_config}" |tee -a ${f_redirect}
        return
    fi

    if git log -n1 --pretty=oneline|grep -q "${new_tag}"; then
        return
    fi
    find ./ -type f -exec sed -i "s/${old_tag}/${new_tag}/" \{\} \;
    git add . &>${f_redirect}
    if [ $? -ne 0 ]; then
        echoerror "Failed to add under ${dir_build_config}" |tee -a ${f_redirect}
        return
    fi
    git commit -s -m "update to tag ${new_tag}" -m "The change log could be checked here: ${url_change_log}" &>${f_redirect}
    if [ $? -ne 0 ]; then
        echoerror "Failed to commit under ${dir_build_config}" |tee -a  ${f_redirect}
        return
    fi
    local url_gerrit=$(sudo -u yongqin.liu git push ssh://yongqin.liu@android-review.linaro.org:29418/android-build-configs HEAD:refs/for/master%${reviewers}  2>&1|grep 'http://android-review.linaro.org/'|awk '{print $2}')
    if [ -z "${url_gerrit}" ]; then
        echoerror "Failed to get the gerrit url" |tee -a ${f_redirect}
        return
    fi
    cd ${OLD_PWD}
    echo "${url_gerrit}"
}


function main(){
    sync_aosp_mirror
    if has_new_tags; then
        local old_tag="$(get_latest_tag_for_lcr)"
        local new_tag="$(get_latest_tag_for_aosp)"
        local changelog_file="ChangeLog-${old_tag}-${new_tag}-$(date +%Y-%m-%d-%H-%M-%S).txt"
        change_log ${old_tag} ${new_tag} "${changelog_file}"
        local url_gerrit=$(update_android_build_config "${old_tag}" "${new_tag}" "http://people.linaro.org/~yongqin.liu/ChangeLogs/${changelog_file}")
        local message="There are new tags released. The latest AOSP tag is: ${new_tag}."
        message="${message} Please check the change log here: http://people.linaro.org/~yongqin.liu/ChangeLogs/${changelog_file}"
        if [ -n "${url_gerrit}" ]; then
            message="${message}, review url: ${url_gerrit}"
        fi
        irc_notify "${message}"
    else
        echo "No new tags released in AOSP"
    fi
}

main "$@"
