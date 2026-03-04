#!/bin/bash
# Descripció: Configura els timers de Systemd per als backups

set -euo pipefail

if [ "$EUID" -ne 0 ]; then 
  echo "Error: Executa amb sudo."
  exit 1
fi

echo "--- Preparant l'entorn segur ---"
SECRET_DIR="/root/secrets"
SECRET_FILE="${SECRET_DIR}/backup_pass.txt"

# Creem el secret només si no existeix (Idempotència)
if [ ! -f "$SECRET_FILE" ]; then
    echo "Configuració inicial: Cal establir la contrasenya per als backups automàtics."
    mkdir -p "$SECRET_DIR"
    chmod 700 "$SECRET_DIR"
    
    # La opció -s de read amaga el text mentre tecleges (seguretat)
    read -s -p "Introdueix la contrasenya de xifratge (ex: gsx2026): " BACKUP_PASS
    echo "" # Salt de línia
    
    echo "$BACKUP_PASS" > "$SECRET_FILE"
    chmod 600 "$SECRET_FILE"
    echo "[OK] Secret guardat de forma segura a $SECRET_FILE"
else
    echo "[OK] El fitxer de secrets ja està configurat."
fi

echo "--- Instal·lant serveis d'automatització ---"

# Copiem els arxius de configuració de systemd
cp /opt/admin/Practica1/systemd/backup.service /etc/systemd/system/
cp /opt/admin/Practica1/systemd/backup.timer /etc/systemd/system/

# Recarreguem el dimoni de systemd perquè detecti els nous arxius
systemctl daemon-reload

# Activem el temporitzador
systemctl enable --now backup.timer

echo "--- [EXIT] Temporitzador de backup instal·lat i activat. ---"