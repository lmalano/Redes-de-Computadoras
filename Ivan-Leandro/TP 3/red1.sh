#!/bin/bash

#agrega namespaces
ip netns add ns1.1
ip netns add ns1.2
ip netns add ns1.3
ip netns add ns1.4
ip netns add ns1.5
ip netns add ns1.6

#agrega el bridge que conectara con la interfaz fisica
#brctl addbr bridge-1


#agrega pares de interfaces conectadas entre si
ip link add int15-1 type veth peer name int13-1 #conexion entre ns1.5 y ns1.3
ip link add int16-1 type veth peer name int14-1 #conexion entre ns1.6 y ns1.4
ip link add int13-2 type veth peer name int14-2 #conexion entre ns1.3 y ns1.4
ip link add int14-3 type veth peer name int11-1 #conexion entre ns1.4 y ns1.1
ip link add int13-3 type veth peer name int11-2 #conexion entre ns1.3 y ns1.1
ip link add int11-3 type veth peer name int12-1 #conexion entre ns1.1 y ns1.2
ip link add int11-4 type veth peer name brdg-1 #conexion entre ns1.1 y el bridge

#se configura la MTU de int11-4 con un valor de 500
#ip netns exec ns1.1 ip link set int11-4 mtu 500

#agrega el bridge que conectara con la interfaz fisica
brctl addbr bridge-1

#se desactiva la interfaz fisica y se asocia con el bridge, y se asocia la interfaz virtual brdg-2
#ifconfig enp0s3 down
brctl addif bridge-1 enp2s0
brctl addif bridge-1 brdg-1


#se activa la interfaz fisica, virtual y el bridge
#ifconfig enp0s3 up
ifconfig bridge-1 inet6 add 2001:AAAA:DDDD:1::10/64 #up
#ip link set dev brdg-1 up
ip link set up bridge-1
ip link set brdg-1 up

#agrega ruta predeterminada
#ip -6 route add default via 2001:AAAA:DDDD:1::2 dev bridge-1


#asigna una de las interfaces creadas anteriormente a un namespace
ip link set int15-1 netns ns1.5
ip link set int13-1 netns ns1.3
ip link set int16-1 netns ns1.6
ip link set int14-1 netns ns1.4
ip link set int13-2 netns ns1.3
ip link set int14-2 netns ns1.4
ip link set int14-3 netns ns1.4
ip link set int11-1 netns ns1.1
ip link set int13-3 netns ns1.3
ip link set int11-2 netns ns1.1
ip link set int11-3 netns ns1.1
ip link set int12-1 netns ns1.2
ip link set int11-4 netns ns1.1

#se configura la MTU de int11-4 con un valor de 500
ip netns exec ns1.1 ip link set int11-4 mtu 1280


#habilita interfaces loopback de cada namespace
ip netns exec ns1.1 ip link set dev lo up
ip netns exec ns1.2 ip link set dev lo up
ip netns exec ns1.3 ip link set dev lo up
ip netns exec ns1.4 ip link set dev lo up
ip netns exec ns1.5 ip link set dev lo up
ip netns exec ns1.6 ip link set dev lo up

#habilita interfaces virtuales agregadas a los namespaces
ip netns exec ns1.1 ip link set dev int11-1 up
ip netns exec ns1.1 ip link set dev int11-2 up
ip netns exec ns1.1 ip link set dev int11-3 up
ip netns exec ns1.1 ip link set dev int11-4 up
ip netns exec ns1.2 ip link set dev int12-1 up
ip netns exec ns1.3 ip link set dev int13-1 up
ip netns exec ns1.3 ip link set dev int13-2 up
ip netns exec ns1.3 ip link set dev int13-3 up
ip netns exec ns1.4 ip link set dev int14-1 up
ip netns exec ns1.4 ip link set dev int14-2 up
ip netns exec ns1.4 ip link set dev int14-3 up
ip netns exec ns1.5 ip link set dev int15-1 up
ip netns exec ns1.6 ip link set dev int16-1 up




#agrega las direcciones ip a cada interfaz de cada namespace
ip netns exec ns1.1 ip address add 2001:AAAA:BBBB:5::2/64 dev int11-1
ip netns exec ns1.1 ip address add 2001:AAAA:BBBB:2::2/64 dev int11-2
ip netns exec ns1.1 ip address add 2001:AAAA:BBBB:6::1/64 dev int11-3
ip netns exec ns1.1 ip address add 2001:AAAA:DDDD:1::1/64 dev int11-4
ip netns exec ns1.2 ip address add 2001:AAAA:BBBB:6::2/64 dev int12-1
ip netns exec ns1.3 ip address add 2001:AAAA:BBBB:1::1/64 dev int13-1
ip netns exec ns1.3 ip address add 2001:AAAA:BBBB:4::1/64 dev int13-2
ip netns exec ns1.3 ip address add 2001:AAAA:BBBB:2::1/64 dev int13-3
ip netns exec ns1.4 ip address add 2001:AAAA:BBBB:3::1/64 dev int14-1
ip netns exec ns1.4 ip address add 2001:AAAA:BBBB:4::2/64 dev int14-2
ip netns exec ns1.4 ip address add 2001:AAAA:BBBB:5::1/64 dev int14-3
ip netns exec ns1.5 ip address add 2001:AAAA:BBBB:1::10/64 dev int15-1
ip netns exec ns1.6 ip address add 2001:AAAA:BBBB:3::20/64 dev int16-1

#agrega una puerta de enlacce predeterminada a cada uno de los dos hosts
ip netns exec ns1.5 ip -6 route add default via 2001:AAAA:BBBB:1::1
ip netns exec ns1.6 ip -6 route add default via 2001:AAAA:BBBB:3::1

#se habilitan como routers los namespaces indicados:
ip netns exec ns1.1 sysctl -w net.ipv6.conf.all.forwarding=1
ip netns exec ns1.2 sysctl -w net.ipv6.conf.all.forwarding=1
ip netns exec ns1.3 sysctl -w net.ipv6.conf.all.forwarding=1
ip netns exec ns1.4 sysctl -w net.ipv6.conf.all.forwarding=1

#se agregan rutas a los distintos enrutadores
ip netns exec ns1.1 ip -6 route add 2001:AAAA:BBBB:1::0/64 via 2001:AAAA:BBBB:2::1
ip netns exec ns1.1 ip -6 route add 2001:AAAA:BBBB:3::0/64 via 2001:AAAA:BBBB:5::1
ip netns exec ns1.1 ip -6 route add 2001:AAAA:BBBB:4::0/64 via 2001:AAAA:BBBB:5::1
ip netns exec ns1.1 ip -6 route add 2001:AAAA::0/8 via 2001:AAAA:DDDD:1::2
ip netns exec ns1.2 ip -6 route add 2001:AAAA:BBBB:1::0/64 via 2001:AAAA:BBBB:6::1
ip netns exec ns1.2 ip -6 route add 2001:AAAA:BBBB:2::0/64 via 2001:AAAA:BBBB:6::1
ip netns exec ns1.2 ip -6 route add 2001:AAAA:BBBB:3::0/64 via 2001:AAAA:BBBB:6::1
ip netns exec ns1.2 ip -6 route add 2001:AAAA:BBBB:4::0/64 via 2001:AAAA:BBBB:6::1
ip netns exec ns1.2 ip -6 route add 2001:AAAA:BBBB:5::0/64 via 2001:AAAA:BBBB:6::1
ip netns exec ns1.2 ip -6 route add 2001:AAAA::0/8 via 2001:AAAA:BBBB:6::1
ip netns exec ns1.3 ip -6 route add 2001:AAAA:BBBB:3::0/64 via 2001:AAAA:BBBB:4::2
ip netns exec ns1.3 ip -6 route add 2001:AAAA:BBBB:5::0/64 via 2001:AAAA:BBBB:4::2
ip netns exec ns1.3 ip -6 route add 2001:AAAA:BBBB:6::0/64 via 2001:AAAA:BBBB:2::2
ip netns exec ns1.3 ip -6 route add 2001:AAAA::0/8 via 2001:AAAA:BBBB:2::2
ip netns exec ns1.4 ip -6 route add 2001:AAAA:BBBB:1::0/64 via 2001:AAAA:BBBB:4::1
ip netns exec ns1.4 ip -6 route add 2001:AAAA:BBBB:2::0/64 via 2001:AAAA:BBBB:4::1
ip netns exec ns1.4 ip -6 route add 2001:AAAA:BBBB:6::0/64 via 2001:AAAA:BBBB:5::2
ip netns exec ns1.4 ip -6 route add 2001:AAAA::0/8 via 2001:AAAA:BBBB:5::2


#se configura la MTU de int11-4 con un valor de 500
#ip netns exec ns1.1 ip link set int11-4 mtu 500
