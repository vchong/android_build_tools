#!/bin/bash
TOKEN=""
SERVER_URL="https://yongqin.liu:${TOKEN}@lkft.validation.linaro.org/RPC2/"
AP_SSID="LAVATEST"
AP_KEY="NepjqGbq"
function submit_one_job(){
    local job_file="${1}"
    local build_number="${2}"
    local build_name="${3}"
    local img_ext="${4}"

    local ANDROID_META_URL="https://ci.linaro.org/jenkins/job/${build_name}/${build_number}"
    local DOWNLOAD_URL="http://snapshots.linaro.org//android/${build_name}/${build_number}"
    echo $f

    sed -i "s=%%JOB_NAME%%=${build_name}=" ${job_file}
    sed -i "s=%%ANDROID_META_BUILD%%=${build_number}=" ${job_file}
    sed -i "s=%%ANDROID_META_NAME%%=${build_name}=" ${job_file}
    sed -i "s=%%ANDROID_META_URL%%=${ANDROID_META_URL}=" ${job_file}
    sed -i "s=%%DOWNLOAD_URL%%=${DOWNLOAD_URL}=" ${job_file}
    sed -i "s=%%ANDROID_BOOT%%=${DOWNLOAD_URL}/boot${img_ext}=" ${job_file}
    sed -i "s=%%ANDROID_SYSTEM%%=${DOWNLOAD_URL}/system${img_ext}=" ${job_file}
    sed -i "s=%%ANDROID_DATA%%=${DOWNLOAD_URL}/userdata${img_ext}=" ${job_file}
    sed -i "s=%%ANDROID_CACHE%%=${DOWNLOAD_URL}/cache${img_ext}=" ${job_file}

    sed -i "s=%%AP_SSID%%=${AP_SSID}=" ${job_file}
    sed -i "s=%%AP_KEY%%=${AP_KEY}=" ${job_file}

    #lava-tool submit-job "${SERVER_URL}" "${job_file}"
    #/development/srv/test-plans/android/submit.py "${job_file}"
    #/development/android/master/host-tools/lava_submit_jobs2.py "${job_file}" "${SERVER_URL}"
    /data/master/host-tools/lava_submit_jobs2.py "${job_file}" "${SERVER_URL}"
    if [ $? -ne 0 ]; then
        echo "Failed mit job file to servier: ${SERVER_URL}"
        echo "Failed job file is: ${job_file}"
        echo "Please check the status and try again"
        exit 1
    fi
}

function main(){
    local build_number="73"
    local build_name="android-lcr-reference-hikey-o"
    local img_ext=".img.xz"
#    local template_dir="/development/srv/test-plans/android/xtest/"
#    local template_dir="/development/srv/test-plans/android/cts/"
    #local template_dir="/development/srv/test-plans/android/hikey-v2/"
    local template_dir="/SATA3/srv/test-plans/android/hikey-v2/"

    #for f in $(ls ${template_dir}/*); do
    #for f in $(ls ${template_dir}/template*); do
    for f in $(ls ${template_dir}/template-cts-*.yaml); do
        f_basename=$(basename $f)
        job_file="/tmp/${f_basename}"
        cp -vf "${f}" ${job_file}
        submit_one_job "${job_file}" "${build_number}" "${build_name}" "${img_ext}"
        rm ${job_file}
    done
}

main
