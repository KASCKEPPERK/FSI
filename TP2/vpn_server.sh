#!/bin/bash

# configure interfaces
sudo ifconfig enp0s8 193.136.212.1 netmask 255.255.255.0
sudo ifconfig enp0s9 10.60.0.1 netmask 255.255.255.0

sudo cp CA/ca.crt /etc/pki/CA/ca.crt
sudo cp CA/vpn.key /etc/pki/CA/vpn.key
sudo cp CA/vpn.crt /etc/pki/CA/vpn.crt
sudo cp CA/dh2048.pem /etc/openvpn/server/dh2048.pem
sudo cp server.conf /etc/openvpn/server/server.conf
sudo cp totp /etc/pam.d/totp
sudo cp check_ocsp.sh /etc/openvpn/server/check_ocsp.sh

sudo openvpn --config /etc/openvpn/server/server.conf
