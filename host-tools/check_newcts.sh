#!/bin/bash

#IRC_NOTIFY_CHANNEL="#linaro-android"
IRC_NOTIFY_CHANNEL="#liuyq-sync"
IRC_NOTIFY_SERVER="irc.freenode.net"
IRC_NOTIFY_NICK="aosp-tag-check"

function get_latest_cts(){
    local url_cts="https://source.android.com/compatibility/cts/downloads.html"
    local available_cts=$(curl -L ${url_cts}|grep 'android-cts-7.*-linux_x86-arm.zip'|cut -d\" -f 2|head -n1)
    # https://dl.google.com/dl/android/cts/android-cts-7.0_r1-linux_x86-arm.zip
    if [ -z "${available_cts}" ]; then
        echo "Failed to wget cts download webpage: ${url_cts}"
        exit 0
    fi
    local cts_version=${available_cts#https://dl.google.com/dl/android/cts/android-cts-}
    cts_version=${cts_version%-linux_x86-arm.zip}

    echo ${cts_version}
}

function get_latest_for_lcr(){
    local url_m_lcr_juno="https://git.linaro.org/qa/test-plans.git/plain/android/lcr-member-juno-m/template-cts-focused1.json"
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
	local local_dir=$(date +%y.%m)
	local package_name="android-cts-${new_cts_version}-linux_x86-arm.zip"
	local remote_url="https://dl.google.com/dl/android/cts/${package_name}"
        local message="There is new cts package released. The latest AOSP tag is: ${new_cts_version}"
        message="${message}, ${remote_url}"
	local testdata_remote_file="/home/testdata.validation.linaro.org/cts/${local_dir}/${package_name}"
	local test_data_remote_file_to_check=$(sudo -u yongqin.liu ssh testdata.validation.linaro.org ls /home/testdata.validation.linaro.org/cts/${local_dir}/${package_name})
	if [ "X${remote_file}" = "X${remote_file_to_check}" ]; then
		message="${message}, also downloaded to http://testdata.validation.linaro.org/cts/${local_dir}/${package_name}"
	else
		mkdir -p ${local_dir}
		wget ${remote_url} -O "${local_dir}/${package_name}"
		if [ $? -ne 0 ]; then
			message="${message}, failed to download it, please check manually"
		else
			sudo -u yongqin.liu scp -r ${local_dir} testdata.validation.linaro.org:/home/testdata.validation.linaro.org/cts/${local_dir}
			if [ $? -eq 0 ]; then
				message="${message}, also downloaded to http://testdata.validation.linaro.org/cts/${local_dir}/${package_name}"
			else
				message="${message}, failed to download it, please check manually"
			fi
		fi
	fi
        irc_notify "${message}"
    else
        echo "No new tags released in AOSP"
    fi
}

main "$@"
