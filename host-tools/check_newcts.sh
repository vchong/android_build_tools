#!/bin/bash

manifest_git="/SATA3/aosp-mirror/platform/manifest.git"
manifest_git="/home/yongqin.liu/aosp-mirror/platform/manifest.git"
IRC_NOTIFY_CHANNEL="#linaro-android"
IRC_NOTIFY_CHANNEL="#liuyq-sync"
IRC_NOTIFY_SERVER="irc.freenode.net"
IRC_NOTIFY_NICK="aosp-tag-check"

function get_latest_cts(){
    local url_cts="https://source.android.com/compatibility/cts/downloads.html"
    local available_cts=$(curl ${url_cts}|grep 'android-cts-6.0.*-linux_x86-arm.zip'|cut -d\" -f 2)
    # https://dl.google.com/dl/android/cts/android-cts-6.0_r8-linux_x86-arm.zip
    if [ -z "${available_cts}" ]; then
        echo "Failed to wget cts download webpage: ${url_cts}"
        exit 0
    fi
    local cts_version=${available_cts#https://dl.google.com/dl/android/cts/android-cts-}
    cts_version=${cts_version%-linux_x86-arm.zip}

    echo ${cts_version}
}

function get_latest_for_lcr(){
    local url_m_lcr_juno="https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-cts-focused1.json"
    local latest_lcr=$(curl ${url_m_lcr_juno}|grep CTS_URL|cut -d\" -f 4)
    if [ -z "${latest_lcr}" ]; then
        echo "Failed to get the tags information for LCR"
        echo "Please check the status and try again"
        exit 1
    fi
    latest_lcr=${latest_lcr#http://testdata.validation.linaro.org/cts/android-cts-}
    latest_lcr=${latest_lcr%.zip}
    echo "${latest_lcr}"
}

function has_new(){
    local latest_aosp=$(get_latest_cts)
    local latest_lcr=$(get_latest_for_lcr)

    if [ -n "${latest_aosp}" ] && [ -n "${latest_lcr}" ]; then
        echo "AOSP: ${latest_aosp}"
        echo "LCR: ${latest_lcr}"
        if [ "${latest_aosp}" \> "${latest_lcr}" ]; then
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
    if has_new; then
        local new_cts_version=$(get_latest_cts)
        local message="There are new cts package released. The latest AOSP tag is: ${new_cts_version}"
        message="${message},  https://dl.google.com/dl/android/cts/android-cts-${new_cts_version}-linux_x86-arm.zip"
        irc_notify "${message}"
    else
        echo "No new tags released in AOSP"
    fi
}

main "$@"