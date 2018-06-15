#!/bin/bash

export BASE=$(cd $(dirname $0);pwd)
${BASE}/sync.sh -v o -j $(getconf _NPROCESSORS_ONLN) -d 2>&1 |tee sync-o.log
