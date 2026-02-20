#!/bin/bash
# Descripció: Verifica que els paquets i directoris existeixen
# Autor: Gerard Ros i Miquel Garcia

set -euo pipefail

if [ "$EUID" -ne 0 ]; then 
  echo "Error: Si us plau, executa l'script amb sudo."
  exit 1
fi

echo "--- Iniciant verificació del sistema ---"
NEEDS_PACKAGES=0
NEEDS_DIRS=0

# 1. VERIFICACIÓ DE PAQUETS
PACKAGES=("git" "vim" "curl" "ufw")
for pkg in "${PACKAGES[@]}"; do
    # Comprovem si el paquet està instal·lat correctament
    if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "ok installed"; then
        echo "[AVÍS] El paquet '$pkg' no està instal·lat."
        NEEDS_PACKAGES=1
    else
        echo "[OK] Paquet '$pkg' correcte."
    fi
done

# 2. VERIFICACIÓ DE DIRECTORIS
BASE_DIR="/home/greendevcorp"
DIRS=("bin" "shared" "backups" "logs" "data")
for dir in "${DIRS[@]}"; do
    if [ ! -d "${BASE_DIR}/${dir}" ]; then
        echo "[AVÍS] Falta el directori '${BASE_DIR}/${dir}'."
        NEEDS_DIRS=1
    else
        echo "[OK] Directori '${dir}' trobat."
    fi
done

if [ ! -f "${BASE_DIR}/done.log" ]; then
    echo "[AVÍS] Falta el fitxer 'done.log'."
    NEEDS_DIRS=1
else
    echo "[OK] Fitxer 'done.log' trobat."
fi

# 3. AUTO-REPARACIÓ (IDEMPOTÈNCIA)
if [ "$NEEDS_PACKAGES" -eq 1 ]; then
    echo "--- [ACCIÓ] Re-aplicant l'script de paquets... ---"
    bash ./01-install-packages.sh
fi

if [ "$NEEDS_DIRS" -eq 1 ]; then
    echo "--- [ACCIÓ] Re-aplicant l'script de directoris... ---"
    bash ./02-directories.sh
fi

echo "--- [ÈXIT] Verificació completada. El sistema està en l'estat desitjat. ---"