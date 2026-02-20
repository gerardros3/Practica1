#!/bin/bash
# Descripció: Verifica que els paquets i directoris existeixen
# Autor: Gerard Ros i Miquel Garcia

set -euo pipefail

if [ "$EUID" -ne 0 ]; then 
  echo "Error: Si us plau, executa l'script amb sudo."
  exit 1
fi

echo "--- Iniciant verificació del sistema ---"
ERRORS=0

# 1. VERIFICACIÓ DE PAQUETS
PACKAGES=("git" "vim" "curl" "ufw")
for pkg in "${PACKAGES[@]}"; do
    # Comprova si el paquet està instal·lat dpkg
    if ! dpkg -l | grep -qw "$pkg"; then
        echo "[ERROR] El paquet '$pkg' no està instal·lat."
        ERRORS=$((ERRORS + 1))
    else
        echo "[OK] Paquet '$pkg' instal·lat."
    fi
done

# 2. VERIFICACIÓ DE DIRECTORIS
BASE_DIR="/home/greendevcorp"
DIRS=("bin" "shared" "backups" "logs" "data")
for dir in "${DIRS[@]}"; do
    if [ ! -d "${BASE_DIR}/${dir}" ]; then
        echo "[AVÍS] Falta el directori '${BASE_DIR}/${dir}'."
        NEEDS_DIRS=1
    fi
done

# Verifica si existeix el fitxer done.log
if [ ! -f "${BASE_DIR}/done.log" ]; then
    echo "[AVÍS] Falta el fitxer '${BASE_DIR}/done.log'."
    NEEDS_DIRS=1
fi

# 3. RESULTAT FINAL
if [ "$ERRORS" -gt 0 ]; then
    echo "--- [ATENCIÓ] S'han trobat $ERRORS errors. Has d'executar els scripts anteriors! ---"
    exit 1
else
    echo "--- [ÈXIT] Tot el sistema està configurat correctament! ---"
fi