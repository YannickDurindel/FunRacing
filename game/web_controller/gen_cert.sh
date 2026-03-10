#!/usr/bin/env bash
# Generate self-signed cert for HTTPS phone controller
# Run from: game/web_controller/

set -e
cd "$(dirname "$0")"

LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "Generating self-signed cert for IP: $LOCAL_IP"

openssl req -x509 -newkey rsa:2048 \
  -keyout key.pem -out cert.pem \
  -days 3650 -nodes \
  -subj "/CN=funracing" \
  -addext "subjectAltName=IP:${LOCAL_IP},DNS:localhost"

echo "Done. cert.pem and key.pem created."
echo "Serve with: python3 serve.py"
