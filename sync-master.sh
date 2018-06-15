#!/bin/bash

export BASE=$(cd $(dirname $0);pwd)
${BASE}/sync.sh -v master -d 2>&1 |tee sync-master.log
#${BASE}/sync.sh -v master -j 24 -d 2>&1 |tee sync-master.log
