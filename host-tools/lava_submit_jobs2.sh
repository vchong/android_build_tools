#!/bin/bash
TOKEN="n2ab47pbfbu4um0sw5r3zd22q1zdorj7nlnj3qaaaqwdfigahkn6j1kp0ze49jjir84cud7dq4kezhms0jrwy14k1m609e8q50kxmgn9je3zlum0yrlr0njxc87bpss9"
SERVER_URL="https://yongqin.liu:${TOKEN}@validation.linaro.org/RPC2/"

TOKEN="ty1dprzx7wysqrqmzuytccufwbyyl9xthwowgim0p0z5hm00t6mzwebyp4dgagmyg2f1kag9ln0s9dh212s3wdaxhasm0df7bqnumrwz1m5mbmf4xg780xgeo9x1348k"
SERVER_URL="https://yongqin.liu:${TOKEN}@staging.validation.linaro.org/RPC2/"

function submit_one_job(){
    local job_file="${1}"
    local build_number="${2}"
    local build_name="${3}"
    local img_ext="${4}"
    local lava_server="https://yongqin.liu@staging.validation.linaro.org/RPC2/"

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

    #lava-tool submit-job "${lava_server}" "${job_file}"
    #/development/srv/test-plans/android/submit.py "${job_file}"
    /development/android/master/host-tools/lava_submit_jobs2.py "${job_file}" "${SERVER_URL}"
    if [ $? -ne 0 ]; then
        echo "Failed mit job file to servier: ${lava_server}"
        echo "Failed job file is: ${job_file}"
        echo "Please check the status and try again"
        exit 1
    fi
}

function main(){
    local build_number="5"
    local build_name="android-lcr-reference-hikey-o"
    local img_ext=".img.xz"
#    local template_dir="/development/srv/test-plans/android/xtest/"
    local template_dir="/development/srv/test-plans/android/cts/"
    local template_dir="/development/srv/test-plans/android/hikey-v2/"

    #for f in $(ls ${template_dir}/*); do
    for f in $(ls ${template_dir}/template-cts-media*); do
        f_basename=$(basename $f)
        job_file="/tmp/${f_basename}"
        cp -vf "${f}" ${job_file}
        submit_one_job "${job_file}" "${build_number}" "${build_name}" "${img_ext}"
        rm ${job_file}
    done
}

main
