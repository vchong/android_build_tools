#!/bin/bash

export BASE=$(cd $(dirname $0);pwd)
${BASE}/sync.sh -v p -d 2>&1 |tee sync-p.log
#${BASE}/sync.sh -v p -j 24 -d 2>&1 |tee sync-p.log
