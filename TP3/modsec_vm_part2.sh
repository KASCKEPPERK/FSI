sudo ip addr flush enp0s8
sudo ip addr flush enp0s9

sudo ip addr add 192.168.56.30/24 dev enp0s8
sudo ip addr add 192.168.57.30/24 dev enp0s9

sudo ip link set enp0s8 up
sudo ip link set enp0s9 up

sudo systemctl disable firewalld
sudo systemctl stop firewalld
nft flush ruleset

iptables -F
iptables -t nat -F
iptables -P FORWARD ACCEPT

echo 1 > /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -A POSTROUTING -s 192.168.56.0 -o enp0s9 -j MASQUERADE

cp ../configs/juice_shop_proxy.conf /etc/httpd/conf.d/juice_shop_proxy.conf
cp ../configs/mod_security_custom.conf /etc/httpd/conf.d/mod_security_custom.conf

systemctl enable httpd
systemctl restart httpd
