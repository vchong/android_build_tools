#!/bin/bash

hikey_weekly_jobs="https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-gearses2eclair.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-geekbench3.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-jbench.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-andebenchpro2015.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-glbenchmark-2.5.1.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-weekly.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-focused1.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-focused2.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-part1.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-part2-64.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-part2-32.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-part3.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-part4.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-opengl.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-media-32.json
https://git.linaro.org/qa/test-plans.git/blob_plain/HEAD:/android/hikey/template-cts-media-64.json
"
while read -r line; do
    job_url=${line}
    job_file=$(basename ${job_url})
    curl -L "${job_url}" >${job_file}
    sed -i 's=%%ANDROID_META_BUILD%%=139=' ${job_file}
    sed -i 's=%%ANDROID_META_NAME%%=android-lcr-member-hikey-n-premerge-ci=' ${job_file}
    sed -i 's=%%ANDROID_META_URL%%=/https://ci.linaro.org/jenkins/job/android-lcr-member-hikey-n-premerge-ci/139=' ${job_file}
    sed -i 's=%%DOWNLOAD_URL%%=http://snapshots.linaro.org//android/android-lcr-member-hikey-n-premerge-ci/139=' ${job_file}
    sed -i 's=%%ANDROID_SYSTEM%%=http://snapshots.linaro.org//android/android-lcr-member-hikey-n-premerge-ci/139/system.img.xz=' ${job_file}
    sed -i 's=%%ANDROID_DATA%%=http://snapshots.linaro.org//android/android-lcr-member-hikey-n-premerge-ci/139/userdata.img.xz=' ${job_file}
    sed -i 's=%%ANDROID_CACHE%%=http://snapshots.linaro.org//android/android-lcr-member-hikey-n-premerge-ci/139/cache.img.xz=' ${job_file}
    sed -i 's=%%JOB_NAME%%=android-lcr-member-hikey-n-premerge-ci=' ${job_file}
done < //tmp/workspace/jobs/jobs.txt
