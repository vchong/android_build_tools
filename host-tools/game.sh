#!/bin/bash

while true; do
    remain=$(($RANDOM % 20))
    echo "$remain"
    sleep 5
done
