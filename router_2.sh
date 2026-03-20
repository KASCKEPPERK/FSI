#!/bin/bash

sudo ifconfig enp0s8 23.214.219.254 netmask 255.255.255.128
sudo ifconfig enp0s9 192.168.10.254 netmask 255.255.255.0
sudo ifconfig enp0s10 87.248.214.97 netmask 255.255.255.0
sudo ifconfig enp0s3 down
sudo route add default gw 87.248.214.98

EXT_IF="enp0s10"       
DMZ_IF="enp0s8"         
INT_IF="enp0s9"         

FW_EXT_IP="87.248.214.97" 

# DMZ 
IP_DNS="23.214.219.130"
IP_SMTP="23.214.219.131"
IP_MAIL="23.214.219.132"
IP_WWW="23.214.219.133"
IP_VPN_GW="23.214.219.134"

IP_FTP="192.168.10.3"

# Internal
NET_INT="192.168.10.0/24"
IP_DATASTORE="192.168.10.2"

# internet
IP_DNS2="193.137.16.75"
IP_EDEN="193.136.212.1"

# enable forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Flush existing rules
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -X

# Set default policies to DROP for security 
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# send traficc to nfq to use suricata
sudo iptables -A INPUT -j NFQUEUE --queue-num 0
sudo iptables -A FORWARD -j NFQUEUE --queue-num 0

# Firewall configuration to protect the router: 

# Allow established and related traffic (essential for stateful inspection)
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT

# dns (no need for OUTPUT as policy is ACCEPT)
sudo iptables -A INPUT -p udp --sport domain -m state --state RELATED,ESTABLISHED -j ACCEPT

# ssh from internal or vpn
sudo iptables -A INPUT -p tcp -s $NET_INT --dport ssh -j ACCEPT
sudo iptables -A INPUT -p tcp -s $IP_VPN_GW --dport ssh -j ACCEPT

echo "Firewall configuration to protect the router: Done"

# Firewall configuration to authorize direct communications (without NAT):

sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Domain name resolutions using the dns server:
sudo iptables -A FORWARD -p udp --dport domain -d $IP_DNS -j ACCEPT

# The dns server should be able to resolve names using DNS servers on the Internet (dns2 and also others):
sudo iptables -A FORWARD -p udp --dport domain -s $IP_DNS -j ACCEPT

# The dns and dns2 servers should be able to synchronize the contents of DNS zones:
sudo iptables -A FORWARD -p tcp --dport domain -s $IP_DNS -d $IP_DNS2 -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport domain -d $IP_DNS -s $IP_DNS2 -j ACCEPT

# SMTP connections to the smtp server:
sudo iptables -A FORWARD -p tcp --dport smtp -d $IP_SMTP -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport smtp -s $IP_SMTP -j ACCEPT

# POP and IMAP connections to the mail server:
sudo iptables -A FORWARD -p tcp --dport imap -d $IP_MAIL -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport pop3 -d $IP_MAIL -j ACCEPT

# HTTP and HTTPS connections to the www server:
sudo iptables -A FORWARD -p tcp --dport http -d $IP_WWW -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport https -d $IP_WWW -j ACCEPT

# OpenVPN connections to the vpn-gw server:
sudo iptables -A FORWARD -p udp --dport openvpn -d $IP_VPN_GW -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport openvpn -d $IP_VPN_GW -j ACCEPT

# VPN clients connected to the gateway (vpn-gw) should be able to connect to all services in the Internal network:
sudo iptables -A FORWARD -s $IP_VPN_GW -d $NET_INT -j ACCEPT

echo "# Firewall configuration to authorize direct communications (without NAT): Done"

#Firewall configuration for connections to the external IP address of the firewall (using NAT):

#FTP connections (in passive and active modes) to the ftp server:
modprobe nf_conntrack_ftp
modprobe nf_nat_ftp
sudo iptables -t nat -A PREROUTING -i $EXT_IF -d $FW_EXT_IP -p tcp --dport ftp -j DNAT --to-destination $IP_FTP
sudo iptables -A FORWARD -p tcp -d $IP_FTP --dport ftp -j ACCEPT

# SSH connections to the datastore server, but only if originated at the eden or dns2 servers.
sudo iptables -t nat -A PREROUTING -i $EXT_IF -d $FW_EXT_IP -p tcp --dport ssh -s $IP_EDEN -j DNAT --to-destination $IP_DATASTORE
sudo iptables -t nat -A PREROUTING -i $EXT_IF -d $FW_EXT_IP -p tcp --dport ssh -s $IP_DNS2 -j DNAT --to-destination $IP_DATASTORE
sudo iptables -A FORWARD -p tcp -s $IP_EDEN -d $IP_DATASTORE --dport ssh -j ACCEPT
sudo iptables -A FORWARD -p tcp -s $IP_DNS2 -d $IP_DATASTORE --dport ssh -j ACCEPT

echo "#Firewall configuration for connections to the external IP address of the firewall (using NAT): Done"

# Firewall configuration for communications from the internal network to the outside (using NAT)
 
# SNAT
sudo iptables -t nat -A POSTROUTING -o $EXT_IF -s $NET_INT -j MASQUERADE

# Domain name resolutions using DNS.
sudo iptables -A FORWARD -s $NET_INT -p udp --dport domain -j ACCEPT

# HTTP, HTTPS and SSH connections
sudo iptables -A FORWARD -s $NET_INT -p tcp --dport http -j ACCEPT
sudo iptables -A FORWARD -s $NET_INT -p tcp --dport https -j ACCEPT
sudo iptables -A FORWARD -s $NET_INT -p tcp --dport ssh -j ACCEPT

# FTP connections (in passive and active modes) to external FTP servers.
sudo iptables -A FORWARD -s $NET_INT -p tcp --dport ftp -j ACCEPT

echo "Firewall configuration for communications from the internal network to the outside (using NAT)"

## Copies the suricata.yaml no suricata.yaml default location
cp suricata.yaml /etc/suricata/suricata_FSI.yaml
## This is the additional rules file made to ensure XSS, SQLi and port scanning is detected and blocked
cp local.rules /var/lib/suricata/rules/local.rules

## This downloads the current Emerging Threats Open ruleset into suricata.rules file
suricata-update

sudo suricata -q 0 -c /etc/suricata/suricata_FSI.yaml -D


