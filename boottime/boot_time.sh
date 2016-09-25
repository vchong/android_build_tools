#!/bin/bash
#
# Android boot time test.
#
# Copyright (C) 2014, Linaro Limited.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# Author: Yongqin Liu <yongqin.liu@linaro.org>
# Author: Milosz Wasilewski <milosz.wasilewski@linaro.org>
#
# Use the following information in logcat to record the android boot time
# I/SurfaceFlinger( 683): Boot is finished (91104 ms)
# Use dmesg to check the boot time from beginning of clock ticks
# to the moment rootfs is mounted.
# The test requires dc to be available in rootfs

local_file_path="$0"
local_file_parent=$(cd $(dirname ${local_file_path}); pwd)

function output_test_result(){
    echo $1,$3,$4
}


# dmeg line example
# [    7.410422] init: Starting service 'logd'...
getTime(){
    local key=$1
    if [ -z "${key}" ]; then
        return
    fi

    local key_line=$(grep -e "${key}" ${LOG_DMESG})
    if [ -n "${key_line}" ]; then
        local timestamp=$(echo "${key_line}"|awk '{print $2}' | awk -F "]" '{print $1}')
        echo "${timestamp}"
    fi
}

function getboottime(){
    # dmesg starts before all timers are initialized, so kernel reports time as 0.0.
    # we can't work around this without external time metering.
    # here we presume kernel message starts from 0
    CONSOLE_SECONDS_START=0
    CONSOLE_SECONDS_END=$(getTime "Freeing unused kernel memory")
    CONSOLE_SECONDS=`echo "$CONSOLE_SECONDS_END $CONSOLE_SECONDS_START - p" | dc`
    output_test_result "KERNEL_BOOT_TIME" "pass" "${CONSOLE_SECONDS}" "s"

    POINT_FS_MOUNT_START=$(getTime "Freeing unused kernel memory:"|tail -n1)
    POINT_FS_MOUNT_END=$(getTime "fs_mgr:"|tail -n 1)
    FS_MOUNT_TIME=`echo "${POINT_FS_MOUNT_END} ${POINT_FS_MOUNT_START} - p" | dc`
    output_test_result "FS_MOUNT_TIME" "pass" "${FS_MOUNT_TIME}" "s"

    POINT_FS_DURATION_START=$(getTime "init: /dev/hw_random not found"|tail -n1)
    POINT_FS_DURATION_END=$(getTime "fs_mgr:"|tail -n 1)
    FS_MOUNT_DURATION=`echo "${POINT_FS_DURATION_END} ${POINT_FS_DURATION_START} - p" | dc`
    output_test_result "FS_MOUNT_DURATION" "pass" "${FS_MOUNT_DURATION}" "s"

    POINT_SERVICE_BOOTANIM_START=$(getTime "init: Starting service 'bootanim'...")
    POINT_SERVICE_BOOTANIM_END=$(getTime "init: Service 'bootanim'.* exited with status")
    BOOTANIM_TIME=`echo "${POINT_SERVICE_BOOTANIM_END} ${POINT_SERVICE_BOOTANIM_START} - p" | dc`
    output_test_result "BOOTANIM_TIME" "pass" "${BOOTANIM_TIME}" "s"

    POINT_SERVICE_SURFACEFLINGER_START=$(getTime "init: Starting service 'surfaceflinger'...")
    ANDROID_INIT_SURFACEFLINGER_TIME=`echo "${POINT_SERVICE_SURFACEFLINGER_START} ${CONSOLE_SECONDS_END} - p" | dc`
    output_test_result "ANDROID_INIT_SURFACEFLINGER_TIME" "pass" "${ANDROID_INIT_SURFACEFLINGER_TIME}" "s"

    TIME_INFO=$(grep "I/SurfaceFlinger" ${F_LOGCAT} |grep "Boot is finished")
    if [ -z "${TIME_INFO}" ]; then
        output_test_result "ANDROID_BOOT_TIME" "fail" "-1" "s"
    else
        while echo "${TIME_INFO}"|grep -q "("; do
            TIME_INFO=$(echo "${TIME_INFO}"|cut -d\( -f3)
        done
        TIME_VALUE=$(echo "${TIME_INFO}"|cut -d\  -f1)
        #ANDROID_BOOT_TIME=`echo scale=2; $TIME_VALUE 1000 / p | bc`
        ANDROID_BOOT_TIME=`echo $TIME_VALUE 1000|awk '{print $1/$2}'`
        output_test_result "ANDROID_BOOT_TIME" "pass" "${ANDROID_BOOT_TIME}" "s"
    fi

    SERVICE_START_TIME_INFO=$(cat $LOG_DMESG|grep "healthd:"|head -n 1)
    SERVICE_START_TIME_END=$(echo "$SERVICE_START_TIME_INFO"|cut -d] -f 1|cut -d[ -f2| tr -d " ")
    if [ -z "${SERVICE_START_TIME_END}" ]; then
        output_test_result "ANDROID_SERVICE_START_TIME" "fail" "-1" "s"
    else
        SERVICE_START_TIME=`echo "$SERVICE_START_TIME_END $CONSOLE_SECONDS_START - p" | dc`
        output_test_result "ANDROID_SERVICE_START_TIME" "pass" "${SERVICE_START_TIME}" "s"
    fi

    #echo "$CONSOLE_SECONDS $TIME_VALUE 1000 / + p"
    TOTAL_SECONDS=$(echo $CONSOLE_SECONDS $ANDROID_INIT_SURFACEFLINGER_TIME $ANDROID_BOOT_TIME|awk '{print $1 + $2 + $3}')
    output_test_result "TOTAL_BOOT_TIME" "pass" "${TOTAL_SECONDS}" "s"
}

function getTimeFromEvents(){
    POINT_BOOT_PROGRESS_START=$(grep -e boot_progress_start ${F_LOGCAT_EVENTS} |cut -d/ -f2|sed 's/(.*)://'|awk '{print $2}')
    grep -n -e boot_progress -e sf_stop_bootanim -e wm_boot_animation_done  ${F_LOGCAT_EVENTS} |cut -d/ -f2|sed 's/(.*)://'|awk -v boot_progress_start=${POINT_BOOT_PROGRESS_START} '{printf "%s,%0.3f\n", $1,($2-boot_progress_start)/1000}'
}
for i in {1..13}; do
    #echo "==================get boottime for cound ${i}"
    F_LOGCAT="/SATA3/nougat/boottime/logcat_all_${i}.log"
    LOG_DMESG="/SATA3/nougat/boottime/dmesg_${i}.txt"
    F_LOGCAT_EVENTS="/SATA3/nougat/boottime/logcat_events_${i}.log"
    #getboottime
    getTimeFromEvents
done


