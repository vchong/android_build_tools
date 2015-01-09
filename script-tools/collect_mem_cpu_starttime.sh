#!/bin/bash

apps="NULL,com.android.browser/.BrowserActivity,Browser"
apps="${apps} NULL,com.android.settings/.Settings,Settings"
apps="${apps} 01-3D_Volcano_Island.apk,com.omnigsoft.volcanoislandjava/.App,3D_Volcano_Island"
apps="${apps} 02-com.blong.jetboy_1.0.1.apk,com.blong.jetboy/.JetBoy,JetBoy"
apps="${apps} 03-HelloEffects.apk,com.example.android.mediafx/.HelloEffects,HelloEffects"
apps="${apps} 04-FREEdi_YouTube_Player_v2.2.apk,tw.com.freedi.youtube.player/.MainActivity,FREEdi_YouTube_Player"
apps="${apps} 17-GooglePlayBooks.apk,com.google.android.apps.books/.app.BooksActivity,GooglePlayBooks"
apps="${apps} 33-Pandora.apk,com.pandora.android/.Main,Pandora"
apps="${apps} 46-Zedge.apk,net.zedge.android/.activity.ControllerActivity,Zedge"
apps="${apps} 55-ShootBubbleDeluxe.apk,com.shootbubble.bubbledexlue/.FrozenBubble,ShootBubbleDeluxe"
apps="${apps} 57-BarcodeScanner.apk,com.google.zxing.client.android/.CaptureActivity,BarcodeScanner"
apps="${apps} 70-DUBatterySaver.apk,com.dianxinos.dxbs/com.dianxinos.powermanager.PowerMgrTabActivity,DUBatterySaver"

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
f_maps="activity_maps.raw"

f_res_starttime="activity_starttime.csv"
f_res_mem="activity_mem.csv"
f_res_cpu="activity_cpu.csv"
f_res_procrank="activity_procrank.csv"

dir_screenshot="screenshots"
NUM_COUNT=12
rm -fr ${dir_screenshot} logcat.log
mkdir -p ${dir_screenshot}

function collect_raw_procmem_data(){
    echo "===pid=${pid}, package=${app_package}, count=${count} start" >> "${f_procmem}"
    adb shell su 0 procmem ${pid} >> "${f_procmem}"
    echo "===pid=${pid}, package=${app_package}, count=${count} end" >> "${f_procmem}"

    echo "===pid=${pid}, package=${app_package}, count=${count} start" >> "${f_procmem}_p"
    adb shell su 0 procmem -p ${pid} >> "${f_procmem}_p"
    echo "===pid=${pid}, package=${app_package}, count=${count} end" >> "${f_procmem}_p"

    echo "===pid=${pid}, package=${app_package}, count=${count} start" >> "${f_procmem}_m"
    adb shell su 0 procmem -m ${pid} >> "${f_procmem}_m"
    echo "===pid=${pid}, package=${app_package}, count=${count} end" >> "${f_procmem}_m"
}

function collect_raw_logcat_data(){
    echo "===pid=${pid}, package=${app_package}, count=${count} start" >> "logcat.log"
    adb logcat -d -v time *:V >>logcat.log
    echo "===pid=${pid}, package=${app_package}, count=${count} start" >> "logcat.log"
    echo "===pid=${pid}, package=${app_package}, count=${count} start" >> "logcat-events.log"
    adb logcat -d -b events -v time *:V >>logcat-events.log
    echo "===pid=${pid}, package=${app_package}, count=${count} start" >> "logcat-events.log"
}

function collect_streamline_data_before(){
    if [ "X${COLLECT_STREAMLINE}" != "Xtrue" ]; then
        return
    fi
    app_name=$1 && shift
    if [ -z "${app_name}" ];then
        return
    fi
    adb shell rm -fr /data/local/tmp/streamline
    adb shell mkdir /data/local/tmp/streamline
    cat >session.xml <<__EOF__
<?xml version="1.0" encoding="US-ASCII" ?>
<session version="1" title="${app_name}" target_path="@F" call_stack_unwinding="yes" parse_debug_info="yes" high_resolution="no" buffer_mode="streaming" sample_rate="normal" duration="0">
</session>
__EOF__
    adb push session.xml /data/local/tmp/streamline/session.xml
    adb shell "su 0 gatord -s /data/local/tmp/streamline/session.xml -o /data/local/tmp/streamline/${app_name}.apc &"
    adb shell sleep 2
}

function collect_streamline_data_post(){
    if [ "X${COLLECT_STREAMLINE}" != "Xtrue" ]; then
        return
    fi
    app_name=$1 && shift
    if [ -z "${app_name}" ];then
        return
    fi

    ps_info=`adb shell ps -x | grep -E '\s+gatord\s+'`
    ##TODO maybe have multiple lines here
    pid=`echo $ps_info|cut -d \  -f 2|sed 's/\r//'`
    if [ -n "${pid}" ]; then
        adb shell kill $pid
    fi
    sleep 5
    adb pull /data/local/tmp/streamline/${app_name}.apc streamline/${app_name}.apc
    #streamline -analyze ${capture_dir}
    #streamline -report -function ${apd_f} |tee ${parent_dir}/streamlineReport.txt
}

function collect_raw_data(){
    rm -fr "${f_starttime}" "${f_mem}" "${f_cpu}" "${f_procrank}" "${f_stat}" "${f_procmem}" "${f_procmem}_m" "${f_procmem}_p"
    for apk in ${apps}; do
        app_apk=$(echo $apk|cut -d, -f1)
        app_start_activity=$(echo $apk|cut -d, -f2)
        app_package=$(echo $app_start_activity|cut -d\/ -f1)
        app_name=$(echo $apk|cut -d, -f3)

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
            # clean logcat
            adb logcat -c
            adb logcat -b events -c
            sleep 3

            # install apk
            if [ "X${app_apk}" != "XNULL" ];then
                adb install -r $app_apk
            fi

            # catch the cpu information before start activity
            cpu_time_before=$(adb shell cat /proc/stat|grep 'cpu '|tr -d '\n')

            collect_streamline_data_before "${app_name}_${count}"

            # start activity
            adb shell am start $app_start_activity

            # wait for activity to be displayed int logcat
            while ! adb logcat -d|grep -q "Displayed $app_start_activity"; do
                sleep 1
            done
            sleep 30

            # get cpu information
            cpu_time_after=$(adb shell cat /proc/stat|grep 'cpu '|tr -d '\n')
            echo "${app_name},${cpu_time_before},${cpu_time_after}" >>"${f_cpu}"

            # get activity start time information
            adb logcat -d|grep "Displayed ${app_start_activity}" >>"${f_starttime}"

            # get memory info
            adb shell ps|grep "${app_package}" >>"${f_mem}"
            adb shell su 0 procrank|grep "${app_package}" >> "${f_procrank}"

            pid=$(adb shell ps|grep ${app_package}|awk '{print $2}')
            if [ -n "${pid}" ]; then
                adb shell su 0 cat /proc/${pid}/stat >> "${f_stat}"
                echo "===pid=${pid}, package=${app_package}, count=${count} start" >> "${f_maps}"
                adb shell su 0 cat /proc/${pid}/maps >> "${f_maps}"
                echo "===pid=${pid}, package=${app_package}, count=${count} end" >> "${f_maps}"

                collect_raw_procmem_data
            fi

            collect_streamline_data_post "${app_name}_${count}"

            # capture screen shot
            adb shell screencap /data/local/tmp/app_screen.png
            adb pull /data/local/tmp/app_screen.png ${dir_screenshot}/${app_package}_${count}.png

            # uninstall or kill the app process
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
            collect_raw_logcat_data
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

function format_cputime(){
    local f_data=$1 && shift
    if ! [ -f "$f_data" ]; then
        return
    fi
    rm -fr "${f_data}_2nd"
    for line in $(cat "${f_data}"); do
        if ! echo "$line"|grep -q ,; then
            continue
        fi
        key=$(echo $line|cut -d, -f1)

        val_user=$(calculate_field_value "$line" 2)
        val_nice=$(calculate_field_value "$line" 3)

        val_system=$(calculate_field_value "$line" 4)
        val_idle=$(calculate_field_value "$line" 5)
        val_io_wait=$(calculate_field_value "$line" 6)
        val_irq=$(calculate_field_value "$line" 7)
        val_softirq=$(calculate_field_value "$line" 8)

        val_total_user=$(echo "scale=2; ${val_user}+${val_nice}"|bc)
        val_total_system=$(echo "scale=2; ${val_system}+${val_irq}+${val_softirq}"|bc)
        val_total_idle=$val_idle
        val_total_iowait=$val_io_wait
        val_total=$(echo "scale=2; ${val_total_system}+${val_total_user}+${val_total_idle}+${val_total_iowait}"|bc)
        percent_user=$(echo "scale=2; $val_total_user*100/$val_total"|bc)
        percent_sys=$(echo "scale=2; $val_total_system*100/$val_total"|bc)
        percent_idle=$(echo "scale=2; $val_total_idle*100/$val_total"|bc)
        echo "$key,$percent_user,$percent_sys,$percent_idle" >> "${f_data}_2nd"
    done
}

function format_cpu_raw_data(){
    sed '/^\s*$/d' "${f_cpu}" |tr -d '\r'|tr -s ' '|tr ' ' ','|sed 's/cpu,//g' >"${f_res_cpu}"
    format_cputime
}

function format_procrank_data(){
    sed '/^\s*$/d' "${f_procrank}" |sed 's/^\s*//'|tr -d '\r'|awk '{printf("%s,%s,%s,%s,%s\n", $6, $2, $3, $4, $5)}'|tr -d 'K'>"${f_res_procrank}"
}

function format_procmem_data(){
    sed 's/^\s*//' "${f_procmem}" |tr -s ' '|tr ' ' ',' >"${f_procmem}.csv"
    sed 's/^\s*//' "${f_procmem}_p" |tr -s ' '|tr ' ' ',' >"${f_procmem}_p.csv"
    sed 's/^\s*//' "${f_procmem}_m" |tr -s ' '|tr ' ' ',' >"${f_procmem}_m.csv"
}

function format_raw_data(){
    rm -fr ${f_res_starttime} ${f_res_mem} ${f_res_cpu} ${f_res_procrank}

    format_starttime_raw_data
    format_mem_raw_data
    format_cpu_raw_data
    format_procrank_data
}

function set_browser_homepage(){
    pref_file="com.android.browser_preferences.xml"
    pref_dir="/data/data/com.android.browser/shared_prefs/"
    pref_content='<?xml version="1.0" encoding="utf-8" standalone="yes" ?>
<map>
    <boolean name="enable_hardware_accel_skia" value="false" />
    <boolean name="autofill_enabled" value="true" />
    <string name="homepage">about:blank</string>
    <boolean name="last_paused" value="false" />
    <boolean name="debug_menu" value="false" />
</map>'

    # start browser for the first time to genrate preference file
    adb shell am start com.android.browser/.BrowserActivity
    sleep 5
    user_grp=$(adb shell su 0 ls -l "${pref_dir}/${pref_file}"|awk '{printf "%s:%s", $2, $3}')
    close_browser

    echo "${pref_content}" > "${pref_file}"
    adb push "${pref_file}" "/data/local/tmp/${pref_file}"
    adb shell su 0 cp "/data/local/tmp/${pref_file}" "${pref_dir}/${pref_file}"
    adb shell su 0 chown ${user_grp} "${pref_dir}/${pref_file}"
    adb shell su 0 chmod 660 "${pref_dir}/${pref_file}"

    adb shell am start com.android.browser/.BrowserActivity
    sleep 5
    close_browser
    adb shell am start com.android.browser/.BrowserActivity
    sleep 5
    close_browser
}

function close_browser(){
    pid=$(adb shell ps |grep com.android.browser|awk '{printf $2}')
    if [ -n "${pid}" ]; then
        adb shell su 0 kill -9 "${pid}"
        sleep 5
    fi
}

function prepare(){
    set_browser_homepage
    svc power stayon true
}

function f_max(){
    local val1=$1 && shift
    local val2=$1 && shift
    [ -z "$val1" ] && return $val2
    [ -z "$val2" ] && return $val1

    local compare=$(echo "$val1>$val2"|bc)
    if [ "X$compare" = "X1" ];then
        echo $val1
    else
        echo $val2
    fi
}

function f_min(){
    local val1=$1 && shift
    local val2=$1 && shift
    [ -z "$val1" ] && return $val1
    [ -z "$val2" ] && return $val2

    local compare=$(echo "$val1<$val2"|bc)
    if [ "X$compare" = "X1" ];then
        echo $val1
    else
        echo $val2
    fi
}

function statistic(){
    local f_data=$1 && shift
    if ! [ -f "$f_data" ]; then
        return
    fi
    local field_no=$1 && shift
    if [ -z "$field_no" ]; then
        field_no=2
    fi
    local total=0
    local max=0
    local min=0
    local old_key=""
    local new_key=""
    local count=0
    for line in $(cat "${f_data}"); do
        if ! echo "$line"|grep -q ,; then
            continue
        fi
        new_key=$(echo $line|cut -d, -f1)
        value=$(echo $line|cut -d, -f${field_no})
        if [ "X${new_key}" = "X${old_key}" ]; then
            total=$(echo "scale=2; ${total}+${value}"|bc -s)
            count=$(echo "$count + 1"|bc)
            max=$(f_max "$max" "$value")
            min=$(f_min "$min" "$value")
        else
            if [ "X${old_key}" != "X" ]; then
                average=$(echo "scale=2; ($total-$max-$min)/($count-2)"|bc)
                echo "$old_key=$average"
            fi
            total="${value}"
            max="${value}"
            min="${value}"
            old_key="${new_key}"
            count=1
        fi
    done
    if [ "X${new_key}" != "X" ]; then
        average=$(echo "scale=2; ($total-$max-$min)/($count-2)"|bc)
        echo "$new_key=$average"
    fi
}

function statistic_data(){
    statistic "$f_res_starttime" 2|sed "s/^/starttime_/"
    echo "--------------------------------"
    statistic "${f_res_mem}" 2|sed "s/^/ps_vss_/"
    echo "--------------------------------"
    statistic "${f_res_mem}" 3|sed "s/^/ps_rss_/"
    echo "--------------------------------"
    statistic "${f_res_procrank}" 2|sed "s/^/proc_vss_/"
    echo "--------------------------------"
    statistic "${f_res_procrank}" 3|sed "s/^/proc_rss_/"
    echo "--------------------------------"
    statistic "${f_res_procrank}" 4|sed "s/^/proc_pss_/"
    echo "--------------------------------"
    statistic "${f_res_procrank}" 5|sed "s/^/proc_uss_/"
    echo "--------------------------------"
    statistic "${f_res_cpu}_2nd" 2|sed "s/^/cpu_user_/"
    echo "--------------------------------"
    statistic "${f_res_cpu}_2nd" 3|sed "s/^/cpu_sys_/"
    echo "--------------------------------"
    statistic "${f_res_cpu}_2nd" 4|sed "s/^/cpu_idle_/"
}

function main(){
    prepare
    collect_raw_data
    format_raw_data
    statistic_data
}

main "$@"
