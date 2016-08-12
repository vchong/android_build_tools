#!/bin/bash

manifest_git="/SATA3/aosp-mirror/platform/manifest.git"
manifest_git="/home/yongqin.liu/aosp-mirror/platform/manifest.git"
IRC_NOTIFY_CHANNEL="#linaro-android"
#IRC_NOTIFY_CHANNEL="#liuyq-sync"
IRC_NOTIFY_SERVER="irc.freenode.net"
IRC_NOTIFY_NICK="aosp-tag-check"

BASE_DIR=$(cd $(dirname $0); pwd)
export PATH=${BASE_DIR}:${PATH}
cd ${BASE_DIR}
#rm -fr .repo

#while ! repo init -u https://android.googlesource.com/mirror/manifest --mirror; do
#    sleep 10
#done
#repo init -u https://android.googlesource.com/mirror/manifest --mirror --repo-url=git://android.git.linaro.org/tools/repo
#repo init -u http://android.git.linaro.org/git/platform/manifest.git --repo-url=git://android.git.linaro.org/tools/repo

function sync_aosp_mirror(){
	echo "Started aosp-mirror sync:" `date` >>sync.timestamp
	while ! repo sync; do
	    sleep 10
	done
	echo "Finished aosp-mirror sync:" `date` >>sync.timestamp
	echo "===================================">>sync.timestamp
}


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
    echo "${latest_branch_lcr}"
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

dir_aosp_master="/home/yongqin.liu/aosp-master"
function change_log(){
	export old_tag="$1"
	export new_tag="$2"
	if [ -z "${old_tag}" ] || [ -z "${new_tag}" ]; then
		return
	fi
	local changelog_file="${3}"
	if [ - z "${changelog_file}" ]; then
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
	scp ${changelog_file} people.linaro.org:/home/yongqin.liu/public_html/ChangeLogs
}

function main(){
    sync_aosp_mirror
    if has_new_tags; then
	local old_tag="$(get_latest_tag_for_lcr)"
	local new_tag="$(get_latest_tag_for_aosp)"
	local changelog_file="ChangeLog-${old_tag}-${new_tag}-$(date +%Y-%m-%d-%H-%M-%S).txt"
	change_log ${old_tag} ${new_tag} "${changelog_file}"
        local message="There are new tags released. The latest AOSP tag is: ${new_tag}."
        message="${message} Please check the change log here: http://people.linaro.org/~yongqin.liu/ChangeLogs/${changelog_file}"
        irc_notify "${message}"
    else
        echo "No new tags released in AOSP"
    fi
}

main "$@"
