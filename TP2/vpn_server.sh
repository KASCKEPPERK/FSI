#!/bin/bash

# configure interfaces
sudo ifconfig enp0s8 193.136.212.1 netmask 255.255.255.0
sudo ifconfig enp0s9 10.60.0.1 netmask 255.255.255.0

sudo cp CA/ca.crt /etc/pki/CA/ca.crt
sudo cp CA/vpn.key /etc/pki/CA/vpn.key
sudo cp CA/vpn.crt /etc/pki/CA/vpn.crt

sudo openvpn --config server.conf
