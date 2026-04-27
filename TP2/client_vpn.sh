#!/bin/bash

# configure interfaces
sudo ifconfig enp0s8 193.136.212.2 netmask 255.255.255.0

sudo cp CA/ca.crt /etc/pki/CA/ca.crt
sudo cp CA/client.key /etc/pki/CA/client.key
sudo cp CA/client.crt /etc/pki/CA/client.crt
sudo cp client.conf /etc/openvpn/client/client.conf

sudo openvpn --config /etc/openvpn/client/client.conf
