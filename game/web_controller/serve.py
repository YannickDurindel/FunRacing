#!/usr/bin/env python3
"""
Serve the phone controller page over HTTPS.
DeviceOrientation API requires HTTPS on LAN.

Usage:
  cd game/web_controller
  python3 serve.py

Then open https://YOUR_IP:8443/controller.html on your phone.
Accept the self-signed cert warning.

Generate cert first (one-time):
  openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem \\
    -days 3650 -nodes -subj "/CN=funracing"
"""

import http.server
import ssl
import os
import socket

PORT = 8443
SERVE_DIR = os.path.dirname(os.path.abspath(__file__))
CERT = os.path.join(SERVE_DIR, "cert.pem")
KEY  = os.path.join(SERVE_DIR, "key.pem")


def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        return s.getsockname()[0]
    except Exception:
        return "127.0.0.1"
    finally:
        s.close()


def main():
    if not os.path.exists(CERT) or not os.path.exists(KEY):
        print("ERROR: cert.pem / key.pem not found.")
        print("Generate with:")
        print(f"  cd {SERVE_DIR}")
        print("  openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem \\")
        print("    -days 3650 -nodes -subj \"/CN=funracing\"")
        return

    os.chdir(SERVE_DIR)
    handler = http.server.SimpleHTTPRequestHandler

    ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ctx.load_cert_chain(CERT, KEY)

    with http.server.HTTPServer(("0.0.0.0", PORT), handler) as httpd:
        httpd.socket = ctx.wrap_socket(httpd.socket, server_side=True)
        ip = get_local_ip()
        print(f"Serving on https://{ip}:{PORT}/controller.html")
        print("Open this URL on your phone (accept cert warning).")
        print("Press Ctrl+C to stop.")
        httpd.serve_forever()


if __name__ == "__main__":
    main()
