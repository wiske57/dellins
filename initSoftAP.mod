#!/bin/bash
clear
echo "*************************************"
echo "   _____ __  __ _     _    _  _____ "
echo "  / ____|  \/  | |   | |  | |/ ____|"
echo " | (___ | \  / | |   | |  | | |  __ "
echo "  \___ \| |\/| | |   | |  | | | |_ |"
echo "  ____) | |  | | |___| |__| | |__| |"
echo " |_____/|_|  |_|______\____/ \_____|"
echo ""
echo "*************************************"
echo "             Secure AP          "
echo "*************************************"
#Initial wifi interface configuration
ip link set dev wlan0 up
ip -f inet addr add dev wlan0 local 10.0.0.1/24 broadcast 10.0.0.255 scope global
sleep 2

#Start BIND
systemctl start named.service

#Start DHCP
systemctl start dhcpd4.service

#Enable NAT
iptables -F
iptables -t nat -F
iptables -X
iptables -t nat -X
iptables -N INET_OUT
iptables -N INET_IN
iptables -A FORWARD -j INET_IN
iptables -A FORWARD -j INET_OUT
iptables -A INPUT -j INET_IN
iptables -A OUTPUT -j INET_OUT
iptables -t nat -A POSTROUTING -o enp2s8 -j MASQUERADE
iptables -A FORWARD -i wlan0 -j ACCEPT

#Enable ipv4 forwarding in the kernel 
sysctl -w net.ipv4.ip_forward=1

#start hostapd
hostapd /etc/hostapd/hostapd.conf
killall dhcpd
