#!/system/bin/sh

setenforce Permissive
export TERMINFO=/system/etc/terminfo/
export PATH=$PATH:/data/local/tmp

while true; do
    remain=$(($RANDOM % 4))
    if [ $remain -eq 0 ]; then
        sl-h -F
    elif [ $remain -eq 1 ]; then
        sl-h -l
    elif [ $remain -eq 2 ]; then
        sl-h -a
    elif [ $remain -eq 3 ]; then
        sl-h -e
    fi
done
setenforce Enforcing
