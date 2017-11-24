#!/bin/bash

sudo sysctl -w net.ipv4.ip_forward=1

# ppp0 is the vpn interface
# http://www.revsys.com/writings/quicktips/nat.html
# http://www.karlrupp.net/en/computer/nat_tutorial
#sudo echo 1 > /proc/sys/net/ipv4/ip_forward
#sudo iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE
#sudo iptables -A FORWARD -i eth0 -o ppp0 -m state --state RELATED,ESTABLISHED -j ACCEPT
#sudo iptables -A FORWARD -i ppp0 -o eth0 -j ACCEPT

out_inf="eno1"
out_inf="tun0"
local_inf="eno4"

sudo iptables -F
#sudo iptables -t nat -A POSTROUTING -o ${out_inf} -j MASQUERADE
#sudo iptables -A FORWARD -o ${out_inf}  -j ACCEPT
#sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -i ${out_inf} -j ACCEPT

sudo iptables -t nat -F
sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o ${out_inf} -j MASQUERADE
#sudo iptables -t nat -A POSTROUTING -o ${out_inf} -j MASQUERADE
sudo iptables -A FORWARD -s 192.168.10.0/24 -o ${out_inf} -j ACCEPT
sudo iptables -A FORWARD -d 192.168.10.0/24 -m conntrack --ctstate ESTABLISHED,RELATED -i ${out_inf} -j ACCEPT


# Default policy to drop all incoming packets
#sudo iptables -P INPUT DROP
#sudo iptables -P FORWARD DROP

# Accept incoming packets from localhost and the LAN interface
#sudo iptables -A INPUT -i lo -j ACCEPT
#sudo iptables -A INPUT -i ${local_inf} -j ACCEPT

# Accept incoming packets from the WAN if the router initiated
# the connection
#sudo iptables -A INPUT -i ${out_inf} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Forward LAN packets to the WAN
#sudo iptables -A FORWARD -i ${local_inf} -o ${out_inf} -j ACCEPT

# Forward WAN packets to the LAN if the LAN initiated the
# connection
#sudo iptables -A FORWARD -i ${out_inf} -o ${local_inf} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# NAT traffic going out the WAN interface
#sudo iptables -t nat -A POSTROUTING -o ${out_inf} -j MASQUERADE

# rc.local needs to exit with 0
exit 0
