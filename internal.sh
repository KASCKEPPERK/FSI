sudo ifconfig enp0s8 192.168.10.1 netmask 255.255.255.0
sudo ifconfig enp0s3 down
sudo route add default gw 192.168.10.254

IP_DATASTORE="192.168.10.2"
IP_FTP="192.168.10.3"

sudo ip addr add $IP_DATASTORE/24 dev enp0s8
sudo ip addr add $IP_FTP/24 dev enp0s8