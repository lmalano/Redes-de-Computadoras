#!/bin/bash
# Defino los namespaces
ip netns add ns1.1
ip netns add ns1.2
ip netns add ns1.3
ip netns add ns1.4
ip netns add ns1.5
ip netns add ns1.6
# Creo el bridge
brctl addbr br-externo
# Desconecto interfaz fisica
ifconfig enp2s0 down
# Creo y conecto veth peer entre el bridge e interfaz externa
ip link add cable1-br type veth peer name cablebr-1
brctl addif br-externo enp2s0 cablebr-1
# Creo y conecto veth peer entre los namespaces
ip link set cable1-br netns ns1.1
ip link add cable1-2 type veth peer name cable2-1
ip link set cable1-2 netns ns1.1
ip link set cable2-1 netns ns1.2
ip link add cable1-3 type veth peer name cable3-1
ip link set cable1-3 netns ns1.1
ip link set cable3-1 netns ns1.3
ip link add cable1-4 type veth peer name cable4-1
ip link set cable1-4 netns ns1.1
ip link set cable4-1 netns ns1.4
ip link add cable3-4 type veth peer name cable4-3
ip link set cable3-4 netns ns1.3
ip link set cable4-3 netns ns1.4
ip link add cable3-5 type veth peer name cable5-3
ip link set cable3-5 netns ns1.3
ip link set cable5-3 netns ns1.5
ip link add cable4-6 type veth peer name cable6-4
ip link set cable4-6 netns ns1.4
ip link set cable6-4 netns ns1.6
# Configuro ips para cada interfaz
ip netns exec ns1.1 ip -6 addr add 2001:aaaa:bbbb::1/64 dev cable1-br
ip netns exec ns1.1 ip -6 addr add 2001:aaaa:aaaa:1::1/64 dev cable1-2
ip netns exec ns1.1 ip -6 addr add 2001:aaaa:aaaa:2::1/64 dev cable1-3
ip netns exec ns1.1 ip -6 addr add 2001:aaaa:aaaa:3::1/64 dev cable1-4
ip netns exec ns1.2 ip -6 addr add 2001:aaaa:aaaa:1::2/64 dev cable2-1
ip netns exec ns1.2 ip -6 addr add 2001:aaaa:aaaa:7::1/64 dev lo
ip netns exec ns1.3 ip -6 addr add 2001:aaaa:aaaa:2::2/64 dev cable3-1
ip netns exec ns1.3 ip -6 addr add 2001:aaaa:aaaa:4::2/64 dev cable3-4
ip netns exec ns1.3 ip -6 addr add 2001:aaaa:aaaa:5::1/64 dev cable3-5
ip netns exec ns1.4 ip -6 addr add 2001:aaaa:aaaa:3::2/64 dev cable4-1
ip netns exec ns1.4 ip -6 addr add 2001:aaaa:aaaa:4::1/64 dev cable4-3
ip netns exec ns1.4 ip -6 addr add 2001:aaaa:aaaa:6::1/64 dev cable4-6
ip netns exec ns1.5 ip -6 addr add 2001:aaaa:aaaa:5::2/64 dev cable5-3
ip netns exec ns1.6 ip -6 addr add 2001:aaaa:aaaa:6::2/64 dev cable6-4
##ip -6 addr add 2001:aaaa:bbbb::2/64 dev cablebr-1
ifconfig br-externo inet6 add 2001:aaaa:bbbb::3/64 up
# Levanto las interfaces de los namespaces
ip netns exec ns1.1 ip link set up dev cable1-br
ip netns exec ns1.1 ip link set up dev cable1-2
ip netns exec ns1.1 ip link set up dev cable1-3
ip netns exec ns1.1 ip link set up dev cable1-4
ip netns exec ns1.2 ip link set up dev lo
ip netns exec ns1.2 ip link set up dev cable2-1
ip netns exec ns1.3 ip link set up dev cable3-1
ip netns exec ns1.3 ip link set up dev cable3-4
ip netns exec ns1.3 ip link set up dev cable3-5
ip netns exec ns1.4 ip link set up dev cable4-1
ip netns exec ns1.4 ip link set up dev cable4-3
ip netns exec ns1.4 ip link set up dev cable4-6
ip netns exec ns1.5 ip link set up dev cable5-3
ip netns exec ns1.6 ip link set up dev cable6-4
ip link set up dev cablebr-1
ifconfig enp2s0 up
# Habilito el forwarding en los routers
ip netns exec ns1.1 sysctl -w net.ipv6.conf.all.forwarding=1
ip netns exec ns1.2 sysctl -w net.ipv6.conf.all.forwarding=1
ip netns exec ns1.3 sysctl -w net.ipv6.conf.all.forwarding=1
ip netns exec ns1.4 sysctl -w net.ipv6.conf.all.forwarding=1
# Configuro ruteo estatico
ip netns exec ns1.1 ip -6 route add 2001:aaaa:aaaa:7::0/64 via 2001:aaaa:aaaa:1::2
ip netns exec ns1.1 ip -6 route add 2001:aaaa:aaaa:5::0/64 via 2001:aaaa:aaaa:2::2
ip netns exec ns1.1 ip -6 route add 2001:aaaa:aaaa:4::0/64 via 2001:aaaa:aaaa:2::2
ip netns exec ns1.1 ip -6 route add 2001:aaaa:aaaa:6::0/64 via 2001:aaaa:aaaa:3::2
ip netns exec ns1.1 ip -6 route add 2001:bbbb::0/8 via 2001:aaaa:bbbb::2
ip netns exec ns1.2 ip -6 route add 2001:aaaa:aaaa:2::0/64 via 2001:aaaa:aaaa:1::1
ip netns exec ns1.2 ip -6 route add 2001:aaaa:aaaa:3::0/64 via 2001:aaaa:aaaa:1::1
ip netns exec ns1.2 ip -6 route add 2001:aaaa:aaaa:4::0/64 via 2001:aaaa:aaaa:1::1
ip netns exec ns1.2 ip -6 route add 2001:aaaa:aaaa:5::0/64 via 2001:aaaa:aaaa:1::1
ip netns exec ns1.2 ip -6 route add 2001:aaaa:aaaa:6::0/64 via 2001:aaaa:aaaa:1::1
ip netns exec ns1.2 ip -6 route add 2001:aaaa:bbbb::0/64 via 2001:aaaa:aaaa:1::1
ip netns exec ns1.2 ip -6 route add 2001:bbbb::0/8 via 2001:aaaa:aaaa:1::1
ip netns exec ns1.3 ip -6 route add 2001:aaaa:aaaa:6::0/64 via 2001:aaaa:aaaa:4::1
ip netns exec ns1.3 ip -6 route add 2001:aaaa:aaaa:3::0/64 via 2001:aaaa:aaaa:2::1
ip netns exec ns1.3 ip -6 route add 2001:aaaa:aaaa:1::0/64 via 2001:aaaa:aaaa:2::1
ip netns exec ns1.3 ip -6 route add 2001:aaaa:aaaa:7::0/64 via 2001:aaaa:aaaa:2::1
ip netns exec ns1.3 ip -6 route add 2001:aaaa:bbbb::0/64 via 2001:aaaa:aaaa:2::1
ip netns exec ns1.3 ip -6 route add 2001:bbbb::0/8 via 2001:aaaa:aaaa:2::1
ip netns exec ns1.4 ip -6 route add 2001:aaaa:aaaa:5::0/64 via 2001:aaaa:aaaa:4::2
ip netns exec ns1.4 ip -6 route add 2001:aaaa:aaaa:2::0/64 via 2001:aaaa:aaaa:4::2
ip netns exec ns1.4 ip -6 route add 2001:aaaa:aaaa:1::0/64 via 2001:aaaa:aaaa:3::1
ip netns exec ns1.4 ip -6 route add 2001:aaaa:aaaa:7::0/64 via 2001:aaaa:aaaa:3::1
ip netns exec ns1.4 ip -6 route add 2001:aaaa:bbbb::0/64 via 2001:aaaa:aaaa:3::1
ip netns exec ns1.4 ip -6 route add 2001:bbbb::0/8 via 2001:aaaa:aaaa:3::1
# Configuro default gateway de los hosts
ip netns exec ns1.5 ip -6 route add default via 2001:aaaa:aaaa:5::1
ip netns exec ns1.6 ip -6 route add default via 2001:aaaa:aaaa:6::1
# Configuro el mtu del bridge a 500
#ip netns exec ns1.1 ip link set cable1-br mtu 500
