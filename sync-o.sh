#!/bin/bash

export BASE=$(cd $(dirname $0);pwd)
${BASE}/sync.sh -v o -d 2>&1 |tee sync-o.log
#${BASE}/sync.sh -v o -j24 -d 2>&1 |tee sync-o.log
