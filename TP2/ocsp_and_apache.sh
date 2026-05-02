#!/bin/bash
sudo ifconfig enp0s8 10.60.0.2 netmask 255.255.255.0

cd CA 

echo "Starting OpenSSL OCSP Responder on port 2560..."
sudo openssl ocsp -index index.txt \
  -port 2560 \
  -rsigner ocsp.crt \
  -rkey ocsp.key \
  -CA ca.crt \
  -text \
  -url http://10.60.0.2:2560 >/var/log/ocsp_responder.log 2>&1 &


sudo cp apache.crt /etc/pki/tls/certs/apache.crt
sudo cp apache.key /etc/pki/tls/private/apache.key
sudo cp ca.crt     /etc/pki/CA/ca.crt
sudo cp ../totp_2   /etc/pam.d/totp_2
sudo cp ../apache.conf /etc/httpd/conf.d/vpn_secure.conf

sudo httpd

echo "All available services started successfully!"
