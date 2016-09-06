#!/bin/bash

SCOPE=100
FILE_TEST="/tmp/workspace/test.txt"

function generate_2nd_operand(){
    local first_operand=$1
    local add_operator=$2
    local operand2
    local operand2_1
    local operand2_2

    if [ -z "${first_operand}" ] || [ -z "${add_operator}" ]; then
        return
    fi

    local first_operand_1=$(( ${first_operand} % 10 ))
    local first_operand_2=$(( ${first_operand} / 10 ))

    if [ "X${add_operator}" = "Xtrue" ]; then
        if [ ${first_operand_1} -eq 0 ]; then
            operand2_1=$(( $RANDOM % 10 ))
        else
            operand2_1=$(( $RANDOM % ${first_operand_1} + 10 - ${first_operand_1}))
        fi
        operand2_tens=$(( (${SCOPE} - ${first_operand} - ${operand2_1}) / 10 ))
        if [ $operand2_tens -eq 0 ]; then
            operand2=${operand2_1}
        else
            operand2_2=$(( ($RANDOM % $operand2_tens) + 1 ))
            operand2="${operand2_2}${operand2_1}"
        fi
    else
        if [ ${first_operand} -eq 0 ]; then
            operand2=0
        elif [ ${first_operand} -le 10 ]; then
            operand2=$(($RANDOM % ${first_operand} ))
        else
            operand2_1=$(($RANDOM % (10 - ${first_operand_1}) + ${first_operand_1}))
            operand2_2=$(($RANDOM % ${first_operand_2}))
            if [ ${operand2_2} -eq 0 ]; then
                operand2="${operand2_1}"
            else
                operand2="${operand2_2}${operand2_1}"
            fi
        fi
    fi

    echo "${operand2}"
}

function generate_two_operands(){
    local operand1=$(( $RANDOM % 100 ))
    local add_operator=$(($RANDOM % 2))
    local test_str=""
    local operand2=0

    if [ $operand1 -eq 0 ]; then
        add_operator=0
        operand1=$(( $SCOPE / 2 ))
    elif [ $operand1 -le 10 ]; then
        operand1=$(($operand1 + 10 ))
    fi
    if [ $add_operator -eq 0 ]; then
        operand2=$(generate_2nd_operand ${operand1} "true")
        test_str="${operand1} + ${operand2}"
    else
        operand2=$(generate_2nd_operand ${operand1} "false")
        test_str="${operand1} - ${operand2}"
    fi
    echo "${test_str}"
}

function generate_one_test(){
    local num_operantors=$(($RANDOM % 2 + 1))
    local test_str=""
    case $num_operantors in
        1)
            test_str=$(generate_two_operands)
            ;;
        2)
            test_str=$(generate_two_operands)
            test_result=$(( $test_str ))
            add_operator=$(($RANDOM % 2))
            if [ $add_operator -eq 0 ]; then
                operand2=$(generate_2nd_operand ${test_result} "true")
                test_str="${test_str} + ${operand2}"
            else
                operand2=$(generate_2nd_operand ${test_result} "false")
                test_str="${test_str} - ${operand2}"
            fi
            ;;
    esac

    echo "$test_str"
}

function main(){
    local count=0
    rm -fr ${FILE_TEST} && touch ${FILE_TEST}
    while true; do
        local test_str=$(generate_one_test)
        if ! grep -q "${test_str}" ${FILE_TEST}; then
            echo "${test_str} = " |tee -a ${FILE_TEST}
            count=$((count + 1))
        fi
        if [ $count -ge 50 ]; then
            break
        fi
    done
}

main "$@"
