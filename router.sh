sudo ifconfig enp0s8 23.214.219.254 netmask 255.255.255.128
sudo ifconfig enp0s9 192.168.10.254 netmask 255.255.255.0
sudo ifconfig enp0s10 87.248.215.97 netmask 255.255.255.0

sudo sysctl -w net.ipv4.ip_forward=1


EXT_IF="enp0s3"       
DMZ_IF="enp0s8"         
INT_IF="enp0s9"         

FW_EXT_IP="87.248.215.97" 

# DMZ 
IP_DNS="23.214.219.130"
IP_SMTP="23.214.219.131"
IP_MAIL="23.214.219.132"
IP_WWW="23.214.219.133"
IP_VPN_GW="23.214.219.134"

IP_FTP="23.214.219.130"

# Internal Servers & Networks
NET_INT="192.168.10.0/24"
IP_DATASTORE="192.168.10.2"

# External Entities
IP_DNS2="193.137.16.74"
IP_EDEN="193.136.212.1"

# clear all rules and drop all communications entering
sudo iptables --flush
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# send traficc to nfq to use suricata
sudo iptables -A INPUT -j NFQUEUE --queue-num 0
sudo iptables -A FORWARD -j NFQUEUE --queue-num 0

# Firewall configuration to protect the router: 

# dns (no need for OUTPUT as policy is ACCEPT)
sudo iptables -A INPUT -p udp --dport domain -j ACCEPT

# ssh from internal or vpn
sudo iptables -A INPUT -p tcp --dport ssh -s $NET_INT -j ACCEPT
sudo iptables -A INPUT -p tcp --dport ssh -s $IP_VPN_GW -j ACCEPT

# Firewall configuration to authorize direct communications (without NAT):

# Domain name resolutions using the dns server:
# The dns server should be able to resolve names using DNS servers on the Internet (dns2 and also others):
sudo iptables -A FORWARD -p udp --dport domain -d $IP_DNS -j ACCEPT
sudo iptables -A FORWARD -p udp --dport domain -s $IP_DNS -j ACCEPT

# The dns and dns2 servers should be able to synchronize the contents of DNS zones:
sudo iptables -A FORWARD -p tcp --dport domain -s $IP_DNS -d $IP_DNS2 -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport domain -d $IP_DNS -s $IP_DNS2 -j ACCEPT

# SMTP connections to the smtp server:
sudo iptables -A FORWARD -p tcp --dport smtp -d $IP_SMTP -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport smtp -s $IP_SMTP -j ACCEPT

# POP and IMAP connections to the mail server:
sudo iptables -A FORWARD -p tcp --dport imap -d $IP_MAIL -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport imap -s $IP_MAIL -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport pop3 -d $IP_MAIL -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport pop3 -s $IP_MAIL -j ACCEPT


# HTTP and HTTPS connections to the www server:
sudo iptables -A FORWARD -p tcp --dport http -d $IP_WWW -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport http -s $IP_WWW -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport https -d $IP_WWW -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport https -s $IP_WWW -j ACCEPT

# OpenVPN connections to the vpn-gw server:
sudo iptables -A FORWARD -p udp --dport openvpn -d $IP_VPN_GW -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport openvpn -d $IP_VPN_GW -j ACCEPT

# VPN clients connected to the gateway (vpn-gw) should be able to connect to all services in the Internal network:
sudo iptables -A FORWARD -s $IP_VPN_GW -j ACCEPT



sudo suricata -q 0 -c /etc/suricata/suricata.yaml -D