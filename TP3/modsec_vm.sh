sudo ip addr flush enp0s8
sudo ip addr flush enp0s9

sudo ip addr add 192.168.56.30/24 dev enp0s8
sudo ip addr add 192.168.57.20/24 dev enp0s9

sudo ip link set enp0s8 up
sudo ip link set enp0s9 up

echo 1 > /proc/sys/net/ipv4/ip_forward
