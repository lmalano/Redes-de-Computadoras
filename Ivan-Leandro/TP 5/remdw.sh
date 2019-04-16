#!/bin/bash

docker exec -it bgp_r2_1 ip -6 route del default
docker exec -it bgp_r3_1 ip -6 route del default
docker exec -it bgp_r4_1 ip -6 route del default
docker exec -it bgp_r5_1 ip -6 route del default
docker exec -it bgp_r6_1 ip -6 route del default
docker exec -it bgp_r7_1 ip -6 route del default
docker exec -it bgp_r8_1 ip -6 route del default
docker exec -it bgp_h11_1 ip -6 route del default
docker exec -it bgp_h12_1 ip -6 route del default
docker exec -it bgp_h13_1 ip -6 route del default
docker exec -it bgp_h14_1 ip -6 route del default
docker exec -it bgp_b1_1 ip -6 route del default
docker exec -it bgp_b2_1 ip -6 route del default
docker exec -it bgp_b3_1 ip -6 route del default

docker exec -it bgp_h11_1 ip -6 route add default via 2001:aaaa:aaaa:1::3
docker exec -it bgp_h12_1 ip -6 route add default via 2001:aaaa:bbbb:1::3
docker exec -it bgp_h13_1 ip -6 route add default via 2001:aaaa:aaaa:3::3
docker exec -it bgp_h14_1 ip -6 route add default via 2001:aaaa:bbbb:3::3
