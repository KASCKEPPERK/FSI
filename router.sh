sudo ifconfig enp0s3 87.248.215.97 netmask 255.255.255.0
sudo ifconfig enp0s8 23.214.219.254 netmask 255.255.255.128
sudo ifconfig enp0s9 192.168.10.254 netmask 255.255.255.0


#internet
dns2=197.137.16.75
eden=193.136.212.1

sudo iptables -flush

sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP

#dns
sudo iptables -A OUTPUT -p udp --dport domain  -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport domain  -j ACCEPT
#ssh
sudo iptables -A INPUT  -p tcp -s 192.168.10.0/24 --dport ssh -j ACCEPT
sudo iptables -A INPUT  -p tcp -s $vpn_gw --dport ssh  -j ACCEPT

#dns on internet
sudo iptables -A FORWARD -p tcp -d 87.248.214.97 --dport domain -j ACCEPT
sudo iptables -A FORWARD -p udp -d 87.248.214.97 --dport domain -j ACCEPT
sudo iptables -A FORWARD -p tcp -s 87.248.214.97 --dport domain -j ACCEPT
sudo iptables -A FORWARD -p udp -s 87.248.214.97 --dport domain -j ACCEPT