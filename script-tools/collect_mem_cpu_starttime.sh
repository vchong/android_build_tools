#!/bin/bash

apps="01-3D_Volcano_Island.apk,com.omnigsoft.volcanoislandjava/.App"
apps="${apps} 02-com.blong.jetboy_1.0.1.apk,com.blong.jetboy/.JetBoy"
apps="${apps} 03-HelloEffects.apk,com.example.android.mediafx/.HelloEffects"
apps="${apps} 04-FREEdi_YouTube_Player_v2.2.apk,tw.com.freedi.youtube.player/.MainActivity"
apps="${apps} 17-GooglePlayBooks.apk,com.google.android.apps.books/.app.BooksActivity"
apps="${apps} 33-Pandora.apk,com.pandora.android/.Main"
apps="${apps} 46-Zedge.apk,net.zedge.android/.activity.ControllerActivity"
apps="${apps} 55-ShootBubbleDeluxe.apk,com.shootbubble.bubbledexlue/.FrozenBubble"
apps="${apps} 57-BarcodeScanner.apk,com.google.zxing.client.android/.CaptureActivity"
apps="${apps} 70-DUBatterySaver.apk,com.dianxinos.dxbs/com.dianxinos.powermanager.PowerMgrTabActivity"
apps="${apps} NULL,com.android.browser/.BrowserActivity"
apps="${apps} NULL,com.android.settings/.Settings"

#01-Gmail.apk,com.google.android.gm/.welcome.WelcomeTourActivity \
#20-GooglePlayMusic.apk,com.google.android.music/com.android.music.activitymanagement.TopLevelActivity \
#44-Flipboard.apk,flipboard.app/flipboard.activities.FirstRunActivity \
#68-GooglePlayNewsstand.apk,com.google.android.apps.magazines/com.google.apps.dots.android.newsstand.onboard.NSOnboardHostActivity \

f_starttime="activity_starttime.raw"
f_mem="activity_mem.raw"
f_cpu="activity_cpu.raw"
f_procrank="activity_procrank.raw"
f_stat="activity_stat.raw"
f_procmem="activity_procmem.raw"

f_res_starttime="activity_starttime.csv"
f_res_mem="activity_mem.csv"
f_res_cpu="activity_cpu.csv"
f_res_procrank="activity_procrank.csv"

dir_screenshot="screenshots"
NUM_COUNT=12
rm -fr ${dir_screenshot} logcat.log
mkdir -p ${dir_screenshot}

function collect_raw_data(){
    rm -fr "${f_starttime}" "${f_mem}" "${f_cpu}" "${f_procrank}" "${f_stat}" "${f_procmem}"
    for apk in ${apps}; do
        app_apk=$(echo $apk|cut -d, -f1)
        app_start_activity=$(echo $apk|cut -d, -f2)
        app_package=$(echo $app_start_activity|cut -d\/ -f1)

        if [ "X${app_apk}" != "XNULL" ];then
            adb uninstall $app_package
        else
            pid=$(adb shell ps|grep ${app_package}|awk '{print $2}')
            if [ -n "${pid}" ];then
                adb shell su 0 kill -9 "${pid}"
            fi
        fi
        let -i count=0;
        while [ $count -lt ${NUM_COUNT} ]; do
            adb logcat -c
            sleep 3

            cpu_time_before=$(adb shell cat /proc/stat|grep 'cpu '|tr -d '\n')
            if [ "X${app_apk}" != "XNULL" ];then
                adb install -r $app_apk
            fi
            adb shell am start $app_start_activity
            while ! adb logcat -d|grep -q "Displayed $app_start_activity"; do
                sleep 1
            done
            sleep 3
            # get cpu information
            cpu_time_after=$(adb shell cat /proc/stat|grep 'cpu '|tr -d '\n')
            echo "${app_package},${cpu_time_before},${cpu_time_after}" >>"${f_cpu}"
            # get activity start time information
            #time_info=$(adb logcat -d|grep -q "Displayed $app_start_activity")
            adb logcat -d|grep "Displayed ${app_start_activity}" >>"${f_starttime}"
            # get memory info
            adb shell ps|grep "${app_package}" >>"${f_mem}"
            adb shell su 0 procrank|grep "${app_package}" >> "${f_procrank}"

            pid=$(adb shell ps|grep ${app_package}|awk '{print $2}')
            if [ -n "${pid}" ]; then
                adb shell su 0 cat /proc/${pid}/stat >> "${f_stat}"
                echo "===pid=${pid}, package=${app_package}, count=${count} start" >> "${f_procmem}"
                adb shell su 0 procmem ${pid} >> "${f_procmem}"
                echo "===pid=${pid}, package=${app_package}, count=${count} end" >> "${f_procmem}"
            fi
            # get screen shot
            adb shell screencap /data/local/tmp/app_screen.png
            adb pull /data/local/tmp/app_screen.png ${dir_screenshot}/${app_package}_${count}.png

            if [ "X${app_apk}" != "XNULL" ];then
                adb uninstall $app_package
            else
                if [ -n "${pid}" ];then
                    adb shell su 0 kill -9 "${pid}"
                fi
            fi
            count=$((count + 1 ))
            echo "" >>"${f_starttime}"
            echo "" >>"${f_mem}"
            echo "" >>"${f_cpu}"
            adb logcat -d -v time *:V >>logcat.log
        done
    done
}

function format_starttime_raw_data(){
    sed '/^\s*$/d' "${f_starttime}" |tr -s ' '|tr -d '\r'|sed 's/^.*Displayed\ //'|sed 's/(.*$//' |sed 's/: +/,/' >"${f_res_starttime}.tmp"
    for line in $(cat "${f_res_starttime}.tmp"); do
        app_pkg=$(echo $line|cut -d, -f1)
        app_time=$(echo $line|cut -d, -f2|sed 's/ms//g')
        # assumed no minute here
        if echo $app_time|grep -q 's'; then
            app_sec=$(echo $app_time|cut -ds -f1)
            app_msec=$(echo $app_time|cut -ds -f2)
            app_time=$((app_sec * 1000 + app_msec))
        fi
        echo "${app_pkg},${app_time}" >>"${f_res_starttime}"
    done
    rm -f "${f_res_starttime}.tmp"
}

function format_mem_raw_data(){
    sed '/^\s*$/d' "${f_mem}" |tr -s ' '|tr -d '\r'|awk '{printf "%s,%s,%s\n", $9, $4, $5;}' >"${f_res_mem}"
}

function format_cpu_raw_data(){
    sed '/^\s*$/d' "${f_cpu}" |tr -d '\r'|tr -s ' '|tr ' ' ','|sed 's/cpu,//g' >"${f_res_cpu}"
}

function format_procrank_data(){
    sed '/^\s*$/d' "${f_procrank}" |sed 's/^\s*//'|tr -d '\r'|awk '{printf("%s,%s,%s,%s,%s\n", $6, $2, $3, $4, $5)}'|tr -d 'K'>"${f_res_procrank}"
}

function format_raw_data(){
    rm -fr ${f_res_starttime} ${f_res_mem} ${f_res_cpu} ${f_res_procrank}

    format_starttime_raw_data
    format_mem_raw_data
    format_cpu_raw_data
    format_procrank_data
}

function main(){
    collect_raw_data
    format_raw_data
}

main "$@"
