#!/bin/bash

hikey_premerge_ci_jobs="
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-boottime.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-benchmarkpi.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cf-bench.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-javawhetstone.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-linpack.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-quadrantpro.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-scimark.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-rl-sqlite.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-vellamo3.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-applications.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-caffeinemark.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-antutu6.0.json
"
hikey_weekly_jobs="
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-part1.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-part2-64.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-part2-32.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-part3.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-part4.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-opengl.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-media-32.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-media-64.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-andebenchpro2015.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-glbenchmark-2.5.1.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-weekly.json
"
hikey_other_jobs="
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-gearses2eclair.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-geekbench3.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-jbench.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-focused1.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-focused2.json
"
hikey_jobs="${hikey_premerge_ci_jobs}
${hikey_other_jobs}
${hikey_weekly_jobs}
"

###########################################################################################################################
x15_premerge_ci_jobs="
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-boottime.json
"
x15_weekly_jobs="
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-cts-part1.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-cts-part2.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-cts-part3.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-cts-part4.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-cts-opengl.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-cts-media.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-andebenchpro2015.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-glbenchmark-2.5.1.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-weekly.json
"
x15_other_jobs="
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-cts-focused1.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-cts-focused2.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-benchmarkpi.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-cf-bench.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-gearses2eclair.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-geekbench3.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-javawhetstone.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-jbench.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-linpack.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-quadrantpro.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-scimark.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-rl-sqlite.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-vellamo3.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-applications.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-caffeinemark.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/x15/template-antutu6.0.json
"
x15_jobs="${x15_premerge_ci_jobs}
${x15_other_jobs}
${x15_weekly_jobs}
"
###########################################################################################################################

juno_premerge_ci_jobs="
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-boottime.json
"
juno_weekly_jobs="
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-cts-part1.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-cts-part2.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-cts-part3.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-cts-part4.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-cts-opengl-32.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-cts-opengl-64.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-cts-media-32.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-cts-media-64.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-glbenchmark-2.5.1.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-weekly.json
"
juno_other_jobs="
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-cts-focused1.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-cts-focused2.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-benchmarkpi.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-cf-bench.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-gearses2eclair.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-geekbench3.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-javawhetstone.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-jbench.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-linpack.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-quadrantpro.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-scimark.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-sqlite.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-rl-sqlite.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-vellamo3.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-applications.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-caffeinemark.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/lcr-member-juno-m/template-antutu6.0.json
"

juno_jobs="${juno_premerge_ci_jobs}
${juno_other_jobs}
${juno_weekly_jobs}
"
###########################################################################################################################

function submit_job(){
    local job_url="${1}"
    local build_number="${2}"
    local build_name="${3}"
    local img_ext="${4}"
    local lava_server="https://yongqin.liu@validation.linaro.org/RPC2/"

    local ANDROID_META_URL="https://ci.linaro.org/jenkins/job/${build_name}/${build_number}"
    local DOWNLOAD_URL="http://snapshots.linaro.org//android/${build_name}/${build_number}"
    local job_file=$(basename ${job_url})
    local tmp_dir=$(mktemp -d /tmp/XXX)
    job_file="${tmp_dir}/${job_file}"
    local count=1
    while true; do
        echo "Downloading tempate($count/10): ${job_url}"
        curl -L "${job_url}" >${job_file}
        if [ $? -ne 0 ]; then
            if [ $(count) -gt 10 ]; then
                echo "Failed to download job file: ${job_url}"
                echo "Please check the status and try again"
                exit 1
            fi
            count=$((count+1))
            sleep 5
        else
            break
        fi

    done

    sed -i "s=%%ANDROID_META_BUILD%%=${build_number}=" ${job_file}
    sed -i "s=%%ANDROID_META_NAME%%=${build_name}=" ${job_file}
    sed -i "s=%%ANDROID_META_URL%%=${ANDROID_META_URL}=" ${job_file}
    sed -i "s=%%DOWNLOAD_URL%%=${DOWNLOAD_URL}=" ${job_file}
    sed -i "s=%%ANDROID_BOOT%%=${DOWNLOAD_URL}/boot${IMG_EXT}=" ${job_file}
    sed -i "s=%%ANDROID_SYSTEM%%=${DOWNLOAD_URL}/system${IMG_EXT}=" ${job_file}
    sed -i "s=%%ANDROID_DATA%%=${DOWNLOAD_URL}/userdata${IMG_EXT}=" ${job_file}
    sed -i "s=%%ANDROID_CACHE%%=${DOWNLOAD_URL}/cache${IMG_EXT}=" ${job_file}
    sed -i "s=%%JOB_NAME%%=${build_name}=" ${job_file}

    lava-tool submit-job "${lava_server}" "${job_file}"
    if [ $? -ne 0 ]; then
        echo "Failed to submit job file to servier: ${lava_server}"
        echo "Failed job file is: ${job_file}"
        echo "Please check the status and try again"
        exit 1
    fi
    rm -fr "${tmp_dir}"
}

function submit_remain_jobs_for_x15_premerge(){
    local build_number="${1}"
    local build_name="android-lcr-member-x15-n-premerge-ci"
    local img_ext=".img"
    for job_url in ${x15_other_jobs} ${x15_weekly_jobs}; do
        submit_job "${job_url}" "${build_number}" "${build_name}" "${img_ext}"
    done
}

function submit_remain_jobs_for_hikey_premerge(){
    local build_number="${1}"
    local build_name="android-lcr-member-hikey-n-premerge-ci"
    local img_ext=".img.xz"
    for job_url in ${hikey_other_jobs} ${hikey_weekly_jobs}; do
        submit_job "${job_url}" "${build_number}" "${build_name}" "${img_ext}"
    done
}

function submit_remain_jobs_for_juno_premerge(){
    local build_number="${1}"
    local build_name="android-lcr-member-juno-n-premerge-ci"
    local img_ext=".img.xz"
    for job_url in ${juno_other_jobs} ${juno_weekly_jobs}; do
        submit_job "${job_url}" "${build_number}" "${build_name}" "${img_ext}"
    done
}

function main(){
    submit_remain_jobs_for_x15_premerge 142
}

main "$@"
