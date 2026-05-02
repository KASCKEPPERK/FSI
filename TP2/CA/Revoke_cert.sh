#!/bin/bash


REVOKE=$1

sudo openssl ca -config openssl.cnf -revoke $REVOKE -keyfile ca.key -cert ca.crt

sudo killall openssl
sudo openssl ocsp -index index.txt \
  -port 2560 \
  -rsigner ocsp.crt \
  -rkey ocsp.key \
  -CA ca.crt \
  -text \
  -url http://10.60.0.2:2560 >/var/log/ocsp_responder.log 2>&1 &