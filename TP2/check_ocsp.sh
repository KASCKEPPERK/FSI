#!/bin/bash

depth=$1

if [ "$depth" -ne 0 ]; then
    exit 0
fi

if [ -z "$peer_cert" ]; then
    echo "Error: No peer_cert provided by OpenVPN."
    exit 1
fi

OCSP_URL="http://10.60.0.2:2560"
ISSUER_CERT="/etc/pki/CA/ca.crt"

STATUS=$(openssl ocsp -issuer "$ISSUER_CERT" \
                      -cert "$peer_cert" \
                      -url "$OCSP_URL" \
                      -CAfile "$ISSUER_CERT" 2>&1)

if echo "$STATUS" | grep -q ": good"; then
    exit 0
else
    echo "OCSP check failed or cert revoked: $STATUS"
    exit 1
fi
