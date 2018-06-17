#!/bin/bash

./sync.sh -d 2>&1 |tee sync-master.log
#./sync.sh -bm pinned-manifest-YYYY-MM-DD_HH:MM -d 2>&1 |tee sync-master.log
#./sync.sh -j 24 -d 2>&1 |tee sync-master.log
