#!/bin/bash

export BASE=$(cd $(dirname $0);pwd)
${BASE}/sync.sh -v p -j $(getconf _NPROCESSORS_ONLN) -d 2>&1 |tee sync-p.log
