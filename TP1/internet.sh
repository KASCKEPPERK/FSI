#!/bin/bash

sudo ifconfig enp0s8 87.248.214.98 netmask 255.255.255.0
sudo ifconfig enp0s3 down
sudo route add default gw 87.248.214.97

IP_DNS2="193.137.16.75"
IP_EDEN="193.136.212.1"

sudo ip addr add $IP_DNS2/24 dev enp0s8
sudo ip addr add $IP_EDEN/24 dev enp0s8