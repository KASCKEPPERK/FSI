#!/bin/bash

sudo ifconfig enp0s3 87.248.215.97 netmask 255.255.255.0
sudo ifconfig enp0s8 23.214.219.254 netmask 255.255.255.128
sudo ifconfig enp0s9 192.168.10.254 netmask 255.255.255.0

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


iptables --flush

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT


iptables -A INPUT -j NFQUEUE --queue-num 0
iptables -A FORWARD -j NFQUEUE --queue-num 0


iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT


# ssh
iptables -A INPUT -p tcp --dport ssh -s $NET_INT -i $INT_IF -j ACCEPT
iptables -A INPUT -p tcp --dport ssh -s $IP_VPN_GW -i $DMZ_IF -j ACCEPT


# DNS resolutions to the 'dns' server
iptables -A FORWARD -p udp --dport domain -d $IP_DNS -j ACCEPT
iptables -A FORWARD -p tcp --dport domain -d $IP_DNS -j ACCEPT

# 'dns' server to resolve names using 'dns2' and others
iptables -A FORWARD -p udp --dport domain -s $IP_DNS -j ACCEPT
iptables -A FORWARD -p tcp --dport domain -s $IP_DNS -j ACCEPT

# Zone transfer sync between 'dns' and 'dns2' (requires TCP 53)
iptables -A FORWARD -p tcp --dport domain -s $IP_DNS2 -d $IP_DNS -j ACCEPT
iptables -A FORWARD -p tcp --dport domain -s $IP_DNS -d $IP_DNS2 -j ACCEPT

# mail
iptables -A FORWARD -p tcp --dport smtp -d $IP_SMTP -j ACCEPT
iptables -A FORWARD -p tcp --dport imap -d $IP_MAIL -j ACCEPT
iptables -A FORWARD -p tcp --dport pop3 -d $IP_MAIL -j ACCEPT

# www
iptables -A FORWARD -p tcp --dport http -d $IP_WWW -j ACCEPT
iptables -A FORWARD -p tcp --dport https -d $IP_WWW -j ACCEPT

# openvpn 
iptables -A FORWARD -p udp --dport openvpn -d $IP_VPN_GW -j ACCEPT
iptables -A FORWARD -p tcp --dport openvpn -d $IP_VPN_GW -j ACCEPT

# VPN clients 
iptables -A FORWARD -s $IP_VPN_GW -d $NET_INT -j ACCEPT

# FTP to the 'ftp' server (Active and Passive handled by conntrack helper)
iptables -t nat -A PREROUTING -i $EXT_IF -d $FW_EXT_IP -p tcp --dport ftp -j DNAT --to-destination $IP_FTP:21
iptables -A FORWARD -p tcp --dport ftp -d $IP_FTP -j ACCEPT

# SSH to 'datastore', ONLY from 'eden' or 'dns2'
# We use port 2222 on the external IP to map to port 22 on the datastore.
iptables -t nat -A PREROUTING -i $EXT_IF -s $IP_EDEN -d $FW_EXT_IP -p tcp --dport 2222 -j DNAT --to-destination $IP_DATASTORE:22
iptables -t nat -A PREROUTING -i $EXT_IF -s $IP_DNS2 -d $FW_EXT_IP -p tcp --dport 2222 -j DNAT --to-destination $IP_DATASTORE:22
iptables -A FORWARD -p tcp --dport 22 -d $IP_DATASTORE -s $IP_EDEN -j ACCEPT
iptables -A FORWARD -p tcp --dport 22 -d $IP_DATASTORE -s $IP_DNS2 -j ACCEPT

# ==============================================================================
# 7. INTERNAL TO EXTERNAL VIA NAT (POSTROUTING + FORWARD)
# ==============================================================================
# Apply MASQUERADE (SNAT) for internal network going out the external interface
iptables -t nat -A POSTROUTING -s $NET_INT -o $EXT_IF -j MASQUERADE

# Authorize specific outbound traffic
# DNS
iptables -A FORWARD -i $INT_IF -s $NET_INT -p udp --dport domain -o $EXT_IF -j ACCEPT
iptables -A FORWARD -i $INT_IF -s $NET_INT -p tcp --dport domain -o $EXT_IF -j ACCEPT
# HTTP, HTTPS, SSH
iptables -A FORWARD -i $INT_IF -s $NET_INT -p tcp -m multiport --dports 80,443,22 -o $EXT_IF -j ACCEPT
# FTP (passive/active data ports are covered by RELATED rule)
iptables -A FORWARD -i $INT_IF -s $NET_INT -p tcp --dport 21 -o $EXT_IF -j ACCEPT

echo "Firewall rules applied successfully."