#!/bin/bash

./sync.sh -v p -d 2>&1 |tee sync-p.log
#./sync.sh -v p -bm pinned-manifest-YYYY-MM-DD_HH:MM -d 2>&1 |tee sync-p.log
#./sync.sh -v p -j 24 -d 2>&1 |tee sync-p.log
