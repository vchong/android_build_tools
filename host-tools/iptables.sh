#!/bin/bash

sudo sysctl -w net.ipv4.ip_forward=1

# ppp0 is the vpn interface
# http://www.revsys.com/writings/quicktips/nat.html
# http://www.karlrupp.net/en/computer/nat_tutorial
#sudo echo 1 > /proc/sys/net/ipv4/ip_forward
#sudo iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE
#sudo iptables -A FORWARD -i eth0 -o ppp0 -m state --state RELATED,ESTABLISHED -j ACCEPT
#sudo iptables -A FORWARD -i ppp0 -o eth0 -j ACCEPT


sudo iptables -F
sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
sudo iptables -A FORWARD -o tun0 -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -i tun0 -j ACCEPT

sudo iptables -t nat -F
sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o eno1 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o eno0 -j MASQUERADE
sudo iptables -A FORWARD -s 192.168.10.0/24 -o eno1 -j ACCEPT
sudo iptables -A FORWARD -d 192.168.10.0/24 -m conntrack --ctstate ESTABLISHED,RELATED -i eno1 -j ACCEPT


# Default policy to drop all incoming packets
iptables -P INPUT DROP
iptables -P FORWARD DROP

# Accept incoming packets from localhost and the LAN interface
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i eno4 -j ACCEPT

# Accept incoming packets from the WAN if the router initiated
# the connection
iptables -A INPUT -i eno0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Forward LAN packets to the WAN
iptables -A FORWARD -i eno4 -o eno0 -j ACCEPT

# Forward WAN packets to the LAN if the LAN initiated the
# connection
iptables -A FORWARD -i eno0 -o eno4 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# NAT traffic going out the WAN interface
iptables -t nat -A POSTROUTING -o eno0 -j MASQUERADE

# rc.local needs to exit with 0
exit 0
