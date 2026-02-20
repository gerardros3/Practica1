#!/bin/bash
# Descripció: Crea l'estructura de directoris administrativa alineada amb Week 4
# Autor: Gerard Ros i Miquel Garcia

set -euo pipefail

if [ "$EUID" -ne 0 ]; then 
  echo "Error: Si us plau, executa l'script amb sudo."
  exit 1
fi

echo "--- Iniciant la creació de l'estructura de directoris ---"

BASE_DIR="/home/greendevcorp"
DIRS=(
    "${BASE_DIR}/bin"      # Scripts i eines administratives
    "${BASE_DIR}/shared"   # Carpeta de treball compartit
    "${BASE_DIR}/backups"  # Còpies de seguretat
    "${BASE_DIR}/logs"     # Logs d'activitat i errors
    "${BASE_DIR}/data"     # Dades sensibles i fitxers de treball
)

# Creació de directoris
for dir in "${DIRS[@]}"; do
    echo "Configurant directori: ${dir}"
    mkdir -p "${dir}"
done

# Creació del fitxer de logs d'activitat
touch "${BASE_DIR}/done.log"

echo "Establint permisos base..."
# Assignar propietat a l'usuari gsx i grup gsx, i establir permisos restrictius
chown -R gsx:gsx "${BASE_DIR}"
# permisos: propietari pot llegir, escriure i executar; grup pot llegir i executar; altres no tenen accés
chmod -R 750 "${BASE_DIR}"

echo "--- Estructura de directoris creada correctament a ${BASE_DIR} ---"