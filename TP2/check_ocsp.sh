#!/bin/bash
# OpenVPN passes the certificate depth ($1) and the temporary certificate file ($2)

depth=$1
cert_file=$2

# We only want to check the client certificate (depth 0), not the CA itself
if [ "$depth" -ne 0 ]; then
    exit 0
fi

# Ask the Internal VM's OCSP responder if the cert is good
# (Replace 10.60.0.2 with your actual Internal VM IP if it changed)
STATUS=$(openssl ocsp -issuer /etc/pki/CA/ca.crt \
                      -CAfile /etc/pki/CA/ca.crt \
                      -cert "$cert_file" \
                      -url http://10.60.0.2:2560 \
                      -noverify 2>&1)

# Check if the output contains "revoked"
if echo "$STATUS" | grep -q "revoked"; then
    echo "CERTIFICATE REVOKED"
    exit 1  # 1 tells OpenVPN to reject the connection
else
    echo "CERTIFICATE VALID"
    exit 0  # 0 tells OpenVPN to allow the connection
fi
