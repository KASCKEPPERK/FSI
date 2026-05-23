sudo ip addr flush dev enp0s9

sudo ip addr add 192.168.57.20/24 dev enp0s9
sudo ip link set enp0s9 up

ip route add 192.168.56.0/24 via 192.168.57.30

systemctl start docker

docker pull bkimminich/juice-shop

docker run -d \--name juice-shop \--restart unless-stopped \-p 3000:3000 \bkimminich/juice-shop

docker ps
