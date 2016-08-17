#!/bin/bash

manifest_git="/SATA3/aosp-mirror/platform/manifest.git"
manifest_git="/home/yongqin.liu/aosp-mirror/platform/manifest.git"
IRC_NOTIFY_CHANNEL="#linaro-android"
IRC_NOTIFY_CHANNEL="#liuyq-sync"
IRC_NOTIFY_SERVER="irc.freenode.net"
IRC_NOTIFY_NICK="aosp-tag-check"

function get_latest_tag_for_aosp(){
    local PWD_BASE=$(cd $PWD; pwd)
    cd ${manifest_git}
    git fetch --all -q
    if [ $? -ne 0 ]; then
        echo "Failed to fetch new tags for AOSP"
        echo "Please check the status and try again"
        exit 1
    fi

    local latest_branch_aosp=$(git branch -a|grep 'android-6'|sort -V|tail -n1|tr -d ' ')
    if [ -z "${latest_branch_aosp}" ]; then
        echo "Failed to get the tags information for AOSP"
        echo "Please check the status and try again"
        exit 1
    fi
    cd ${PWD_BASE}

    echo "${latest_branch_aosp}"
}

function get_latest_tag_for_lcr(){
    local url_m_lcr_juno="https://android-git.linaro.org/gitweb/android-build-configs.git/blob_plain/HEAD:/lcr-member-juno-m"
    local latest_branch_lcr=$(curl ${url_m_lcr_juno}|grep '^MANIFEST_BRANCH='|cut -d= -f2)
    if [ -z "${latest_branch_lcr}" ]; then
        echo "Failed to get the tags information for LCR"
        echo "Please check the status and try again"
        exit 1
    fi
#    echo "${latest_branch_lcr}"
    echo "android-6.0.1_r42"
}

function has_new_tags(){
    local latest_branch_aosp=$(get_latest_tag_for_aosp ${manifest_git})
    local latest_branch_lcr=$(get_latest_tag_for_lcr)

    if [ -n "${latest_branch_lcr}" ] && [ -n "${latest_branch_lcr}" ]; then
        echo "AOSP: ${latest_branch_aosp}"
        echo "LCR: ${latest_branch_lcr}"
        if [ "${latest_branch_aosp}" \> "${latest_branch_lcr}" ]; then
            echo "There are new tags released"
            return 0
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

function main(){
    if has_new_tags; then
        local message="There are new tags released. The latest AOSP tag is: $(get_latest_tag_for_aosp)"
        irc_notify "${message}"
    else
        echo "No new tags released in AOSP"
    fi
}

main "$@"
