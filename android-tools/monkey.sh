#!/system/bin/sh

#/system/bin/disablesuspend.sh
monkey -s 1 --pct-touch 10 --pct-motion 20 --pct-nav 20 --pct-majornav 30 --pct-appswitch 20 --throttle 500 --pkg-blacklist-file /data/monkey_black_list 30000
echo RET=$?
