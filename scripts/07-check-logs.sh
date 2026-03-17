#!/bin/bash
# Script: 07-check-logs.sh
# Purpose: Display status and logs for critical services (Observability)
# Usage: sudo ./07-check-logs.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-04
# Exit Codes:
#   0 - Success

set -euo pipefail

log_header() {
    echo "========================================="
    echo "   SERVICE STATUS - GREENDEVCORP         "
    echo "========================================="
}

check_nginx() {
    echo -e "\n---> 1. NGINX (Web Server)"
    if systemctl is-active --quiet nginx; then
        echo "[ACTIVE] Nginx is running."
    else
        echo "[ERROR] Nginx is down."
    fi
    echo "Last 5 Nginx log entries (journald):"
    journalctl -u nginx -n 5 --no-pager
}

check_backups() {
    echo -e "\n---> 2. AUTOMATED BACKUPS"
    if systemctl list-timers | grep -q "backup.timer"; then
        echo "[ACTIVE] The backup timer is scheduled."
    else
        echo "[WARNING] The backup timer is not scheduled."
    fi
    echo "Last 5 Backup service log entries:"
    journalctl -u backup.service -n 5 --no-pager
}

main() {
    log_header
    check_nginx
    check_backups
}

main "$@"