#!/bin/bash

export BASE=$(cd $(dirname $0);pwd)
${BASE}/sync.sh -b "android-8.1.0_r29" -v o -n linaro-oreo
