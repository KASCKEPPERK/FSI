sudo ip addr flush dev enp0s9

sudo ip addr add 192.168.57.20/24 dev enp0s9
sudo ip link set enp0s9 up

ip addr show enp0s9
