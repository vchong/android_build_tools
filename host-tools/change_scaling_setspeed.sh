#!/bin/bash

dir_sys_cpu="/sys/devices/system/cpu/"
function set2userspace(){
    for cpu in $(adb shell ls -d ${dir_sys_cpu}/cpu[0-9]* |tr '\r' ' '); do
        local dir_cpu_cpufreq="${cpu}/cpufreq"
        adb shell "echo userspace>${dir_cpu_cpufreq}/scaling_governor"
        #adb shell "cat ${dir_cpu_cpufreq}/scaling_max_freq >${dir_cpu_cpufreq}/scaling_setspeed"
        local frequencies=$(adb shell "cat ${dir_cpu_cpufreq}/scaling_available_frequencies"|tr -d '\r'|sed 's/ \+$//')
        local target_freq=$(echo "${frequencies}"|tr ' ' '\n\r'|tail -n2|head -n1)
        adb shell "echo ${target_freq} >${dir_cpu_cpufreq}/scaling_setspeed"
    done
}

function set2ondemand(){
    for cpu in $(adb shell ls -d ${dir_sys_cpu}/cpu[0-9]* |tr '\r' ' '); do
        local dir_cpu_cpufreq="${cpu}/cpufreq"
        adb shell "echo ondemand>${dir_cpu_cpufreq}/scaling_governor"
    done
}

function set2performance(){
    for cpu in $(adb shell ls -d ${dir_sys_cpu}/cpu[0-9]* |tr '\r' ' '); do
        local dir_cpu_cpufreq="${cpu}/cpufreq"
        adb shell "echo performance>${dir_cpu_cpufreq}/scaling_governor"
    done
}

function func_showcurrent(){
    for cpu in $(adb shell ls -d ${dir_sys_cpu}/cpu[0-9]* |tr '\r' ' '); do
        echo "Information for cpu: ${cpu}"
        #cpu=$(echo ${cpu}|tr -d '\r')
        local dir_cpu_cpufreq="${cpu}/cpufreq"
        local scaling_governor=$(adb shell "cat ${dir_cpu_cpufreq}/scaling_governor")
        echo "  scaling_governor: ${scaling_governor}"
        local cpuinfo_cur_freq=$(adb shell "cat ${dir_cpu_cpufreq}/cpuinfo_cur_freq")
        echo "  cpuinfo_cur_freq: ${cpuinfo_cur_freq}"
        local frequencies=$(adb shell "cat ${dir_cpu_cpufreq}/scaling_available_frequencies"|tr -d '\r'|sed 's/ \+$//')
        echo "  scaling_available_frequencies: ${frequencies}"
    done
}

governor=$1

case ${governor} in
    userspace )
        set2userspace
        ;;
    ondemand )
        set2ondemand
        ;;
    onperformance )
        set2performance
        ;;
    showcurrent )
        func_showcurrent
        ;;
    *)
        echo "Not supported governor:${governor}"
        echo "Please specify with userspace, or ondemand, or onperformance, or showcurrent"
        exit 1
        ;;
esac
