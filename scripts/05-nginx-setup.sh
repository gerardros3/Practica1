#!/bin/bash
# Script: 05-nginx-setup.sh
# Purpose: Install and configure Nginx for auto-recovery
# Usage: sudo ./05-nginx-setup.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-04
# Exit Codes:
#   0 - Success
#   1 - Execution failed (not root)

set -euo pipefail

# Constants
readonly OVERRIDE_DIR="/etc/systemd/system/nginx.service.d"
readonly OVERRIDE_FILE="${OVERRIDE_DIR}/override.conf"

log_info() { echo "[INFO] $*"; }
log_error() { echo "[ERROR] $*" >&2; }

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run the script with sudo."
        exit 1
    fi
}

install_nginx() {
    if ! dpkg-query -W -f='${Status}' nginx 2>/dev/null | grep -q "ok installed"; then
        log_info "Installing Nginx..."
        apt-get update -y > /dev/null
        apt-get install -y nginx > /dev/null
    else
        log_info "Nginx is already installed."
    fi
}

configure_resilience() {
    log_info "Configuring Nginx resilience (Restart=always)..."

    # We use a drop-in override directory (*.service.d) instead of modifying 
    # the main nginx.service file directly. This prevents package updates 
    # from overwriting our custom resilience rules.
    mkdir -p "$OVERRIDE_DIR"

    cat <<EOF > "$OVERRIDE_FILE"
[Service]
Restart=always
RestartSec=5
EOF

    systemctl daemon-reload
    systemctl enable nginx
    systemctl restart nginx
}

main() {
    check_root
    log_info "Starting Nginx installation and configuration..."
    install_nginx
    configure_resilience
    log_info "Nginx configured to auto-recover on failure."
}

main "$@"