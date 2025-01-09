#!/bin/bash
echo "8021q" >> /etc/modules

# Load the 802.1Q module (if not already loaded)
# modprobe 8021q

# Create network namespaces
ip netns add BLUE
ip netns add GREEN

# Configure VLAN sub-interface for BLUE
ip link add name eth1.10 link eth1 type vlan id 10
ip link set dev eth1.10 netns BLUE
ip netns exec BLUE ip link set lo up
ip netns exec BLUE ip link set eth1.10 up
ip netns exec BLUE ip addr add 172.16.1.1/30 dev eth1.10
ip netns exec BLUE ip route add default via 172.16.1.2

# Configure VLAN sub-interface for GREEN    
ip link add name eth1.20 link eth1 type vlan id 20
ip link set dev eth1.20 netns GREEN
ip netns exec GREEN ip link set lo up
ip netns exec GREEN ip link set eth1.20 up
ip netns exec GREEN ip addr add 172.17.1.1/30 dev eth1.20
ip netns exec GREEN ip route add default via 172.17.1.2
