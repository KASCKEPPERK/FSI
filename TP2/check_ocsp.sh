#!/bin/bash

# OpenVPN passes the certificate depth as the first argument
depth=$1

# We only need to verify the client certificate (depth 0).
# The CA certificate (depth 1) is inherently trusted by our config.
if [ "$depth" -ne 0 ]; then
    exit 0
fi

# Ensure OpenVPN passed the peer_cert environment variable
if [ -z "$peer_cert" ]; then
    echo "Error: No peer_cert provided by OpenVPN."
    exit 1
fi

# --- Configuration ---
OCSP_URL="http://10.60.0.2:2560"
ISSUER_CERT="/etc/pki/CA/ca.crt"

# Run the OpenSSL OCSP command
# -noverify is used here on the response IF the OCSP responder uses the root CA to sign responses. 
# If using a delegated OCSP cert, adjust accordingly.
STATUS=$(openssl ocsp -issuer "$ISSUER_CERT" \
                      -cert "$peer_cert" \
                      -url "$OCSP_URL" \
                      -CAfile "$ISSUER_CERT" 2>&1)

# Check the output for the exact "good" status
if echo "$STATUS" | grep -q ": good"; then
    # Certificate is valid
    exit 0
else
    # Certificate is revoked, unknown, or the OCSP server is unreachable
    echo "OCSP check failed or cert revoked: $STATUS"
    exit 1
fi
