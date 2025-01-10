#!/bin/bash
echo "8021q" >> /etc/modules

# Load the 802.1Q module (if not already loaded)
# modprobe 8021q

# Configure VLAN sub-interface for BLUE
ip link add name eth1.10 link eth1 type vlan id 10
ip link set eth1.10 up
ip addr add 172.16.1.5/30 dev eth1.10
ip route add 172.16.1.0/30 via 172.16.1.6
