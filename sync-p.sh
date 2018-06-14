#!/bin/bash

export BASE=$(cd $(dirname $0);pwd)
${BASE}/sync.sh -b "android-p-preview-1" -v p -n linaro-p-preview
