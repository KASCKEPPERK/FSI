sudo ifconfig enp0s8 192.168.10.1 netmask 255.255.255.0
sudo ifconfig enp0s3 down
sudo route add default gw 192.168.10.254
