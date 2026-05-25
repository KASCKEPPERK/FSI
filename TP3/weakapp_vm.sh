sudo ip addr flush dev enp0s9

sudo ip addr add 192.168.57.20/24 dev enp0s9
sudo ip link set enp0s9 up

sudo systemctl start docker

sudo docker rm -f juice-shop 2>/dev/null || true

sudo docker pull bkimminich/juice-shop

sudo docker run -d \--name juice-shop \--restart unless-stopped \-p 3000:3000 \bkimminich/juice-shop

sudo docker ps
