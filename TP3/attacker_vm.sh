sudo ip addr flush dev eth1

sudo ip addr add 192.168.56.10/24 dev eth1
sudo ip link set eth1 up

ip route add 192.168.57.0/24 via 192.168.56.30
