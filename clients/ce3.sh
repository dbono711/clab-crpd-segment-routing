#!/bin/bash
echo "8021q" >> /etc/modules

# Load the 802.1Q module (if not already loaded)
# modprobe 8021q

# Configure VLAN sub-interface for GREEN
ip link add name eth1.20 link eth1 type vlan id 20
ip link set eth1.20 up
ip addr add 172.17.1.5/30 dev eth1.20
ip route add 172.17.1.0/30 via 172.17.1.6