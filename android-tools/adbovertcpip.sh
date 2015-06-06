#!/system/bin/sh
#
# Author: Linaro Validation Team <linaro-dev@lists.linaro.org>
#
# These files are Copyright (C) 2012 Linaro Limited and they
# are licensed under the Apache License, Version 2.0.
# You may obtain a copy of this license at
# http://www.apache.org/licenses/LICENSE-2.0

# usb-ethernet convert need to be plugged before the board started
# same as "adb tcpip 5555" on host side
stop adbd
setprop service.adb.tcp.port 5555
setprop service.adb.root 1
start adbd

echo "ip info"
ifconfig eth0
