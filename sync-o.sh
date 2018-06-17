#!/bin/bash

./sync.sh -v o -d 2>&1 |tee sync-o.log
#./sync.sh -v o -bm pinned-manifest-YYYY-MM-DD_HH:MM -d 2>&1 |tee sync-o.log
#./sync.sh -v o -j24 -d 2>&1 |tee sync-o.log
