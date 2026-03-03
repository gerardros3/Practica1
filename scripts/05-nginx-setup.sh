#!/bin/bash
# Descripció: Instal·la i configura Nginx per a auto-recuperació (Week 2)

set -euo pipefail

if [ "$EUID" -ne 0 ]; then 
  echo "Error: Si us plau, executa l'script amb sudo."
  exit 1
fi

echo "--- Iniciant instal·lació i configuració de Nginx ---"

# 1. Instal·lació idempotent
if ! dpkg-query -W -f='${Status}' nginx 2>/dev/null | grep -q "ok installed"; then
    echo "Instal·lant Nginx..."
    apt-get update -y
    apt-get install -y nginx
else
    echo "[OK] Nginx ja està instal·lat."
fi

# 2. Configuració de l'Auto-recuperació (Drop-in override de Systemd)
echo "Configurant resiliència de Nginx (Restart=always)..."
mkdir -p /etc/systemd/system/nginx.service.d

cat <<EOF > /etc/systemd/system/nginx.service.d/override.conf
[Service]
Restart=always
RestartSec=5
EOF

# 3. Aplicar canvis a Systemd
systemctl daemon-reload
systemctl enable nginx
systemctl restart nginx

echo "--- [EXIT] Nginx configurat per auto-recuperar-se si cau. ---"