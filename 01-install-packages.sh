#!/bin/bash
# Descripcio: Script per a la practica de GSX
# Autor: Gerard Ros i Miquel Garcia
# Data: 2026

# 1. SEGURETAT: Atura l'script si hi ha un error o una variable no definida
set -euo pipefail

# 2. MECANISME DE BLOQUEIG: Evita execucions simultanies (Hint de la practica)
LOCKFILE="/tmp/install-packages.lock"
if [ -e ${LOCKFILE} ]; then
    echo "Error: L'script ja s'esta executant o el fitxer de bloqueig existeix."
    exit 1
fi
trap "rm -f ${LOCKFILE}" EXIT
touch ${LOCKFILE}

echo "--- Iniciant la instal paquets basics---"

# 3. VERIFICACIO DE PRIVILEGIS: Cal ser root o usar sudo [cite: 126, 158]
if [ "$EUID" -ne 0 ]; then 
  echo "Si us plau, executa l'script amb sudo."
  exit 1
fi

# 4. ACTUALITZACIO I INSTALACIO (IDEMPOTENT)
echo "Actualitzant l'index de paquets..."
apt-get update -y

PACKAGES=(
    "git"           # Necessari per al repositori de la practica [cite: 19, 142]
    "vim"           # Editor de text recomanat
    "curl"          # Eina de xarxa
    "sudo"          # Per a l'escalada de privilegis [cite: 158]
    "net-tools"     # Comandes com ifconfig/netstat
    "ufw"           # Tallafoc per a futures setmanes
)

echo "Instalant paquets: ${PACKAGES[*]}..."
apt-get install -y "${PACKAGES[@]}"

echo "--- Instalacio completada correctament ---"
