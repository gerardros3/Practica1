#!/bin/bash
# Descripció: Empaqueta i xifra dades sensibles preservant atributs
# Autor: Gerard Ros i Miquel Garcia

set -euo pipefail

if [ "$EUID" -ne 0 ]; then 
  echo "Error: Si us plau, executa l'script amb sudo."
  exit 1
fi

echo "--- Iniciant procés de Backup Segur ---"

# 1. VARIABLES
SOURCE_DIR="/home/greendevcorp/data"
BACKUP_DIR="/home/greendevcorp/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEMP_ARCHIVE="${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz"
FINAL_ARCHIVE="${TEMP_ARCHIVE}.gpg"

# Assegurem que el directori d'origen existeix i té alguna cosa
mkdir -p "${SOURCE_DIR}"
touch "${SOURCE_DIR}/test_data_prova.txt" # Fitxer de prova temporal

# 2. EMPAQUETAR PRESERVANT ATRIBUTS
echo "Generant arxiu Tar amb permisos preservats..."
# -c (create), -z (gzip), -p (preserve permissions), -f (file)
tar -czpf "${TEMP_ARCHIVE}" -C "${SOURCE_DIR}" .

# 3. XIFRAR L'ARXIU (GPG)
echo "Xifrant la còpia de seguretat..."
echo "ATENCIÓ: Se't demanarà que introdueixis una contrasenya de xifratge."
# Creem un xifrat simètric amb AES256
gpg --symmetric --cipher-algo AES256 --pinentry-mode loopback "${TEMP_ARCHIVE}"

# 4. NETEJA POST-BACKUP
if [ -f "${FINAL_ARCHIVE}" ]; then
    echo "Netejant arxiu temporal no xifrat..."
    rm -f "${TEMP_ARCHIVE}"
    echo "--- [ÈXIT] Backup completat: ${FINAL_ARCHIVE} ---"
else
    echo "--- [ERROR] Hi ha hagut un problema xifrant el backup. ---"
    exit 1
fi