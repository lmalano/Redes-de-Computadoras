#!/bin/bash

docker exec -it ospf_r1_1 ip -6 route del default
docker exec -it ospf_r2_1 ip -6 route del default
docker exec -it ospf_r3_1 ip -6 route del default
docker exec -it ospf_r4_1 ip -6 route del default
docker exec -it ospf_r5_1 ip -6 route del default
docker exec -it ospf_r6_1 ip -6 route del default
docker exec -it ospf_r7_1 ip -6 route del default
docker exec -it ospf_r8_1 ip -6 route del default
docker exec -it ospf_h1_1 ip -6 route del default
docker exec -it ospf_h2_1 ip -6 route del default
docker exec -it ospf_h3_1 ip -6 route del default
docker exec -it ospf_h4_1 ip -6 route del default

docker exec -it ospf_h1_1 ip -6 route add default via 2001:aaaa:bbbb:1::3
docker exec -it ospf_h2_1 ip -6 route add default via 2001:aaaa:bbbb:3::3
docker exec -it ospf_h3_1 ip -6 route add default via 2001:aaaa:cccc:1::3
docker exec -it ospf_h4_1 ip -6 route add default via 2001:aaaa:cccc:3::3
