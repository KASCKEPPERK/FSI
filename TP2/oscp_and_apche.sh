#!/bin/bash

echo "Starting Internal Network Services (OCSP & Apache)..."

# 1. Configure Interface
# (Assuming enp0s8 is the internal adapter and 10.60.0.2 is the IP we discussed)
sudo ifconfig enp0s8 10.60.0.2 netmask 255.255.255.0
echo "[OK] Network interface configured: 10.60.0.2"

# 2. Start the OCSP Responder
# We navigate to your CA folder and run the server in the background (using '&')
# so the script can continue to the Apache steps.
cd /path/to/your/CA/folder  # <-- UPDATE THIS PATH to where your CA folder is!

echo "Starting OpenSSL OCSP Responder on port 2560..."
sudo openssl ocsp -index index.txt \
      -port 2560 \
      -rsigner CA/ocsp.crt \
      -rkey CA/ocsp.key \
      -CA CA/ca.crt \
      -text \
      -url http://10.60.0.2:2560 > /var/log/ocsp_responder.log 2>&1 &

echo "[OK] OCSP Responder running in the background."

# ==========================================
# 3. APACHE WEB SERVER (PLACEHOLDERS)
# ==========================================

echo "Configuring Apache Web Server..."

# Copy Apache certificates to the system directories once you generate them
# sudo cp certs/apache.crt /etc/pki/tls/certs/apache.crt
# sudo cp private/apache.key /etc/pki/tls/private/apache.key

# Copy your future custom Apache config file to the correct directory
# sudo cp my_apache_config.conf /etc/httpd/conf.d/vpn_secure.conf

# Restart the Apache service to apply changes
# sudo systemctl restart httpd

echo "[PLACEHOLDER] Apache configuration skipped. Uncomment when ready."

echo "All available services started successfully!"
