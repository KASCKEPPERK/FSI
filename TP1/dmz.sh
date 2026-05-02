#!/bin/bash

sudo ifconfig enp0s8 23.214.219.129 netmask 255.255.255.128
sudo ifconfig enp0s3 down
sudo route add default gw 23.214.219.254

IP_DNS="23.214.219.130"
IP_SMTP="23.214.219.131"
IP_MAIL="23.214.219.132"
IP_WWW="23.214.219.133"
IP_VPN_GW="23.214.219.134"

sudo ip addr add $IP_DNS/25 dev enp0s8
sudo ip addr add $IP_SMTP/25 dev enp0s8
sudo ip addr add $IP_MAIL/25 dev enp0s8
sudo ip addr add $IP_WWW/25 dev enp0s8
sudo ip addr add $IP_VPN_GW/25 dev enp0s8




