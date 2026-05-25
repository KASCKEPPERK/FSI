ip addr flush enp0s8
ip addr flush enp0s9

ip addr add 192.168.56.30/24 dev enp0s8
ip addr add 192.168.57.30/24 dev enp0s9

ip link set enp0s8 up
ip link set enp0s9 up

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING \-s 192.168.56.0/24 \-o enp0s9 \-j MASQUERADE
