#!/bin/bash
# Descripcio: Instal·la paquets bàsics necessaris per a la pràctica
# Autor: Gerard Ros i Miquel Garcia

# 1. SEGURETAT: Atura l'script si hi ha un error o una variable no definida
set -euo pipefail

# 2. MECANISME DE BLOQUEIG: Evita execucions simultanies
LOCKFILE="/tmp/install-packages.lock"
if [ -e ${LOCKFILE} ]; then
    echo "Error: L'script ja s'esta executant o el fitxer de bloqueig existeix."
    exit 1
fi
trap "rm -f ${LOCKFILE}" EXIT
touch ${LOCKFILE}

echo "--- Iniciant la instal paquets basics---"

# 3. VERIFICACIO DE PRIVILEGIS: Cal ser root o usar sudo
if [ "$EUID" -ne 0 ]; then 
  echo "Si us plau, executa l'script amb sudo."
  exit 1
fi

# 4. ACTUALITZACIO I INSTALACIO (IDEMPOTENT)
echo "Actualitzant l'index de paquets..."
apt-get update -y

PACKAGES=(
    "git"            # Necessari per al repositori de la practica
    "vim"            # Editor de text recomanat
    "curl"           # Eina de xarxa
    "sudo"           # Per a l'escalada de privilegis
    "net-tools"      # Comandes com ifconfig/netstat
    "ufw"            # Tallafoc
    "openssh-server" # Per a connexions remotes segures
    "gnupg"          # Per a xifratge i gestió de claus (usat en el backup)
)

echo "Instalant paquets: ${PACKAGES[*]}..."
apt-get install -y "${PACKAGES[@]}"

echo "--- Instalacio completada correctament ---"
