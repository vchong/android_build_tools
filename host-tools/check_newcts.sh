#!/bin/bash

#IRC_NOTIFY_CHANNEL="#linaro-android"
IRC_NOTIFY_CHANNEL="#liuyq-sync"
IRC_NOTIFY_SERVER="irc.freenode.net"
IRC_NOTIFY_NICK="aosp-tag-check"
URL_JUNO_CTS_TEMPLATE="https://git.linaro.org/qa/test-plans.git/plain/android/lcr-member-juno-m/template-cts-focused1.json"

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
    local latest_lcr=$(getLCRURL)
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

function getLCRURL(){
    local url_lcr=$(curl -L ${URL_JUNO_CTS_TEMPLATE}|grep CTS_URL|cut -d\" -f 4)
    if [ -z "${url_lcr}" ]; then
        echo "Failed to get the url information for LCR via url ${URL_JUNO_CTS_TEMPLATE}"
        echo "Please check the status and try again"
        exit 1
    fi
    echo "${url_lcr}"
}

function prepareCtsDir(){
    local work_dir=$1
    local cts_url=$2

    cd ${work_dir}
    wget ${cts_url} -O "${work_dir}/cts.zip"
    local f_modules_list="${work_dir}/modules.log"
    local f_modules_sort="${work_dir}/modules.sort"
    unzip cts.zip
    ./android-cts/tools/cts-tradefed list modules |tee ${f_modules_list}
    local pos_end=$(grep -n 'Saved log to' ${f_modules_list}  |cut -d: -f1)
    local pos_start=$(grep -n 'Using commandline arguments' ${f_modules_list}  |cut -d: -f1)
    local total_lines=$(wc -l ${f_modules_list})
    local tail_num=$(echo "${total_lines},${pos_start}"|awk -F, '{printf "%d",$1 - $2;}')
    local head_num=$(echo "${pos_start},${pos_end}"|awk -F, '{printf "%d",$2 - $1 - 1;}')
    tail -n ${tail_num} ${f_modules_list} | head -n ${head_num} |sort > ${f_modules_sort}
}

function generateLinaroCtsPackage(){
    local new_cts_version=$(get_latest_cts)
    local local_dir=$(date +%y.%m)
    local package_name_linaro="android-cts-${new_cts_version}-linux_x86-arm-linaro.zip"
    local testdata_remote_file_to_check=$(sudo -u yongqin.liu ssh testdata.validation.linaro.org readlink /home/testdata.validation.linaro.org/cts/${local_dir}/${package_name_linaro})
    if [[ "X${testdata_remote_file_to_check}" =~ "${local_dir}/${package_name_linaro}" ]]; then
        return
    fi
    if which java >/dev/null; then
        local url_lcr=$(getLCRURL)
        local package_name="android-cts-${new_cts_version}-linux_x86-arm.zip"
        local url_google="http://testdata.validation.linaro.org/cts/${local_dir}/${package_name}"
        local working_dir=$(mktemp -d -p /tmp/ -d CTS-XXX)
        sudo rm -fr /tmp/build-tools.tar.gz
        sudo -u yongqin.liu scp testdata.validation.linaro.org:/home/testdata.validation.linaro.org/apks/workload-automation/build-tools.tar.gz /tmp/build-tools.tar.gz
        tar -C ${working_dir} -xvf /tmp/build-tools.tar.gz
        sudo rm -fr /tmp/build-tools.tar.gz
        export PATH=${PATH}:${working_dir}/build-tools/android-4.4/
        mkdir ${working_dir}/linaro ${working_dir}/google
        prepareCtsDir "${working_dir}/linaro" "${url_lcr}"
        prepareCtsDir "${working_dir}/google" "${url_google}"

        if diff ${working_dir}/linaro//modules.sort ${working_dir}/google//modules.sort; then
            cp ${working_dir}/google/android-cts/testcases/egl-master.txt ${working_dir}/google/egl-master.txt && \
            cp ${working_dir}/google/android-cts/tools/tradefed-prebuilt.jar ${working_dir}/google/tradefed-prebuilt.jar && \
            rm -fr ${working_dir}/google/android-cts

            mkdir -p ${working_dir}/google/android-cts//testcases/ ${working_dir}/google/android-cts//tools
            sed -i '/dEQP-EGL.functional.sharing.gles2.multithread.random.images.copyteximage2d/d' ${working_dir}/egl-master.txt > ${working_dir}/google/egl-master.txt

            rm -fr ${working_dir}/linaro/android-cts/tools/config
            cd ${working_dir}/linaro/android-cts/tools/ && jar -xf tradefed-prebuilt.jar config/cts- && mv config ${working_dir}/google/android-cts//tools

            cp ${working_dir}/google/tradefed-prebuilt.jar ${working_dir}/google/android-cts//tools && cd ${working_dir}/google/android-cts//tools && jar -uvf tradefed-prebuilt.jar config/

            cd ${working_dir}/google/ && zip -ru cts.zip android-cts && mv cts.zip ${package_name_linaro}

            sudo -u yongqin.liu scp -r ${package_name_linaro} testdata.validation.linaro.org:/home/testdata.validation.linaro.org/cts/${local_dir}

            sudo -u yongqin.liu ssh testdata.validation.linaro.org ln -s /home/testdata.validation.linaro.org/cts/${local_dir}/${package_name_linaro} /home/testdata.validation.linaro.org/cts/android-cts-${new_cts_version}.zip

            local new_url="http://testdata.validation.linaro.org/cts/android-cts-${new_cts_version}.zip"
            local reviewers="r=yongqin.liu@linaro.org,r=bernhard.rosenkranzer@linaro.org,r=vishal.bhoj@linaro.org,r=jakub.pavelek@linaro.org,r=milosz.wasilewski@linaro.org,r=naresh.kamboju@linaro.org"
            cd ${working_dir}/ && \
                sudo -u yongqin.liu git clone https://git.linaro.org/qa/test-plans.git && \
                cd test-plans && \
                sudo -u yongqin.liu sed -i "s%${url_lcr}%${new_url}%" android/*/*.json && \
                sudo -u yongqin.liu git add . && \
                sudo -u yongqin.liu git commit -s -m "update to cts version to ${new_cts_version}" && \
                sudo -u yongqin.liu git push ssh://yongqin.liu@android-review.linaro.org:29418/android-build-configs HEAD:refs/for/master%${reviewers}
        fi
    else
        echo "No java command is found, please generate the linaro cts package manually"
    fi
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
        local testdata_remote_file_to_check=$(sudo -u yongqin.liu ssh testdata.validation.linaro.org ls /home/testdata.validation.linaro.org/cts/${local_dir}/${package_name})
        if [ "X${testdata_remote_file}" = "X${testdata_remote_file_to_check}" ]; then
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
        generateLinaroCtsPackage
        irc_notify "${message}"
    else
        echo "No new tags released in AOSP"
    fi
}

main "$@"
