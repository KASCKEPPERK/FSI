sudo ifconfig enp0s8 23.214.219.129 netmask 255.255.255.128
sudo ip route del default
sudo ip route add default gw 23.214.219.254


# Add Web server IP
sudo ip addr add 23.214.219.133/25 dev enp0s8

# Add Mail server IP
sudo ip addr add 23.214.219.132/25 dev enp0s8

# Add DNS server IP
sudo ip addr add 23.214.219.130/25 dev enp0s8

