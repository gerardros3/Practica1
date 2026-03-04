#!/bin/bash
# Descripció: Mostra l'estat i els logs dels serveis crítics (Observabilitat)

echo "========================================="
echo "   ESTAT DELS SERVEIS - GREENDEVCORP     "
echo "========================================="

echo -e "\n---> 1. NGINX (Servidor Web)"
systemctl is-active --quiet nginx && echo "[ACTIU] Nginx està funcionant." || echo "[ERROR] Nginx està caigut."
echo "Últims 5 registres d'Nginx (journald):"
journalctl -u nginx -n 5 --no-pager

echo -e "\n---> 2. BACKUPS AUTOMÀTICS"
systemctl list-timers | grep backup.timer > /dev/null && echo "[ACTIU] El timer de backups està programat." || echo "[AVÍS] El timer no està programat."
echo "Últims 5 registres del servei de Backup:"
journalctl -u backup.service -n 5 --no-pager