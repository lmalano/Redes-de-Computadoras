#!/bin/bash

#agrega namespaces
ip netns add ns2.1
ip netns add ns2.2
ip netns add ns2.3
ip netns add ns2.4
ip netns add ns2.5
ip netns add ns2.6

#agrega el bridge que conectara con la interfaz fisica
#brctl addbr bridge-2

#agrega pares de interfaces conectadas entre si
ip link add int25-1 type veth peer name int23-1 #conexion entre ns2.5 y ns2.3
ip link add int26-1 type veth peer name int24-1 #conexion entre ns2.6 y ns2.4
ip link add int23-2 type veth peer name int24-2 #conexion entre ns2.3 y ns2.4
ip link add int24-3 type veth peer name int21-1 #conexion entre ns2.4 y ns2.1
ip link add int23-3 type veth peer name int21-2 #conexion entre ns2.3 y ns2.1
ip link add int21-3 type veth peer name int22-1 #conexion entre ns2.1 y ns2.2
ip link add int21-4 type veth peer name brdg-2 #conexion entre ns2.1 y el bridge

#agrega el bridge que conectara con la interfaz fisica
brctl addbr bridge-2

#se desactiva la interfaz fisica y se asocia con el bridge, y se asocia la interfaz virtual brdg-2
ifconfig enp0s3 down
brctl addif bridge-2 enp0s3 brdg-2

#se activa la interfaz fisica, virtual y el bridge
ifconfig enp0s3 up
ifconfig bridge-2 inet6 add 2001:AAAA:DDDD:1::2/64 up
ip link set dev brdg-2 up

#agrega ruta predeterminada
ip -6 route add default via 2001:AAAA:DDDD:1::1 dev bridge-2



#asigna una de las interfaces creadas anteriormente a un namespace
ip link set int25-1 netns ns2.5
ip link set int23-1 netns ns2.3
ip link set int26-1 netns ns2.6
ip link set int24-1 netns ns2.4
ip link set int23-2 netns ns2.3
ip link set int24-2 netns ns2.4
ip link set int24-3 netns ns2.4
ip link set int21-1 netns ns2.1
ip link set int23-3 netns ns2.3
ip link set int21-2 netns ns2.1
ip link set int21-3 netns ns2.1
ip link set int22-1 netns ns2.2
ip link set int21-4 netns ns2.1

#habilita interfaces loopback de cada namespace
ip netns exec ns2.1 ip link set dev lo up
ip netns exec ns2.2 ip link set dev lo up
ip netns exec ns2.3 ip link set dev lo up
ip netns exec ns2.4 ip link set dev lo up
ip netns exec ns2.5 ip link set dev lo up
ip netns exec ns2.6 ip link set dev lo up

#habilita interfaces virtuales agregadas a los namespaces
ip netns exec ns2.1 ip link set dev int21-1 up
ip netns exec ns2.1 ip link set dev int21-2 up
ip netns exec ns2.1 ip link set dev int21-3 up
ip netns exec ns2.1 ip link set dev int21-4 up
ip netns exec ns2.2 ip link set dev int22-1 up
ip netns exec ns2.3 ip link set dev int23-1 up
ip netns exec ns2.3 ip link set dev int23-2 up
ip netns exec ns2.3 ip link set dev int23-3 up
ip netns exec ns2.4 ip link set dev int24-1 up
ip netns exec ns2.4 ip link set dev int24-2 up
ip netns exec ns2.4 ip link set dev int24-3 up
ip netns exec ns2.5 ip link set dev int25-1 up
ip netns exec ns2.6 ip link set dev int26-1 up

#agrega las direcciones ip a cada interfaz de cada namespace
ip netns exec ns2.1 ip address add 2001:AAAA:CCCC:5::2/64 dev int21-1
ip netns exec ns2.1 ip address add 2001:AAAA:CCCC:2::2/64 dev int21-2
ip netns exec ns2.1 ip address add 2001:AAAA:CCCC:6::1/64 dev int21-3
ip netns exec ns2.1 ip address add 2001:AAAA:DDDD:1::2/64 dev int21-4
ip netns exec ns2.2 ip address add 2001:AAAA:CCCC:6::2/64 dev int22-1
ip netns exec ns2.3 ip address add 2001:AAAA:CCCC:1::1/64 dev int23-1
ip netns exec ns2.3 ip address add 2001:AAAA:CCCC:4::1/64 dev int23-2
ip netns exec ns2.3 ip address add 2001:AAAA:CCCC:2::1/64 dev int23-3
ip netns exec ns2.4 ip address add 2001:AAAA:CCCC:3::1/64 dev int24-1
ip netns exec ns2.4 ip address add 2001:AAAA:CCCC:4::2/64 dev int24-2
ip netns exec ns2.4 ip address add 2001:AAAA:CCCC:5::1/64 dev int24-3
ip netns exec ns2.5 ip address add 2001:AAAA:CCCC:1::10/64 dev int25-1
ip netns exec ns2.6 ip address add 2001:AAAA:CCCC:3::20/64 dev int26-1

#agrega una puerta de enlacce predeterminada a cada uno de los dos hosts
ip netns exec ns2.5 ip -6 route add default via 2001:AAAA:CCCC:1::1
ip netns exec ns2.6 ip -6 route add default via 2001:AAAA:CCCC:3::1

#se habilitan como routers los namespaces indicados:
ip netns exec ns2.1 sysctl -w net.ipv6.conf.all.forwarding=1
ip netns exec ns2.2 sysctl -w net.ipv6.conf.all.forwarding=1
ip netns exec ns2.3 sysctl -w net.ipv6.conf.all.forwarding=1
ip netns exec ns2.4 sysctl -w net.ipv6.conf.all.forwarding=1

#se agregan rutas a los distintos enrutadores
ip netns exec ns2.1 ip -6 route add 2001:AAAA:CCCC:1::0/64 via 2001:AAAA:CCCC:2::1
ip netns exec ns2.1 ip -6 route add 2001:AAAA:CCCC:3::0/64 via 2001:AAAA:CCCC:5::1
ip netns exec ns2.1 ip -6 route add 2001:AAAA:CCCC:4::0/64 via 2001:AAAA:CCCC:5::1
ip netns exec ns2.1 ip -6 route add 2001:AAAA::0/8 via 2001:AAAA:DDDD:1::1
ip netns exec ns2.2 ip -6 route add 2001:AAAA:CCCC:1::0/64 via 2001:AAAA:CCCC:6::1
ip netns exec ns2.2 ip -6 route add 2001:AAAA:CCCC:2::0/64 via 2001:AAAA:CCCC:6::1
ip netns exec ns2.2 ip -6 route add 2001:AAAA:CCCC:3::0/64 via 2001:AAAA:CCCC:6::1
ip netns exec ns2.2 ip -6 route add 2001:AAAA:CCCC:4::0/64 via 2001:AAAA:CCCC:6::1
ip netns exec ns2.2 ip -6 route add 2001:AAAA:CCCC:5::0/64 via 2001:AAAA:CCCC:6::1
ip netns exec ns2.2 ip -6 route add 2001:AAAA::0/8 via 2001:AAAA:CCCC:6::1
ip netns exec ns2.3 ip -6 route add 2001:AAAA:CCCC:3::0/64 via 2001:AAAA:CCCC:4::2
ip netns exec ns2.3 ip -6 route add 2001:AAAA:CCCC:5::0/64 via 2001:AAAA:CCCC:4::2
ip netns exec ns2.3 ip -6 route add 2001:AAAA:CCCC:6::0/64 via 2001:AAAA:CCCC:2::2
ip netns exec ns2.3 ip -6 route add 2001:AAAA::0/8 via 2001:AAAA:CCCC:2::2
ip netns exec ns2.4 ip -6 route add 2001:AAAA:CCCC:1::0/64 via 2001:AAAA:CCCC:4::1
ip netns exec ns2.4 ip -6 route add 2001:AAAA:CCCC:2::0/64 via 2001:AAAA:CCCC:4::1
ip netns exec ns2.4 ip -6 route add 2001:AAAA:CCCC:6::0/64 via 2001:AAAA:CCCC:5::2
ip netns exec ns2.4 ip -6 route add 2001:AAAA::0/8 via 2001:AAAA:CCCC:5::2


