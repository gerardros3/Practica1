#!/bin/bash
# Script: 06-setup-timers.sh
# Purpose: Configure systemd timers for automated backups
# Usage: sudo ./06-setup-timers.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-04
# Exit Codes:
#   0 - Success
#   1 - Execution failed (not root)

set -euo pipefail

# Constants
readonly SECRET_DIR="/root/secrets"
readonly SECRET_FILE="${SECRET_DIR}/backup_pass.txt"
readonly SYSTEMD_DIR="/etc/systemd/system/"
readonly PROJECT_SYSTEMD_DIR="/opt/admin/Practica1/systemd"

log_info() { echo "[INFO] $*"; }
log_error() { echo "[ERROR] $*" >&2; }

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run the script with sudo."
        exit 1
    fi
}

setup_secrets() {
    log_info "Preparing secure environment..."
    if [ ! -f "$SECRET_FILE" ]; then
        log_info "Initial setup: You must establish a password for automated backups."
        mkdir -p "$SECRET_DIR"
        chmod 700 "$SECRET_DIR"
        
        local backup_pass
        # -s hides input for security
        read -r -s -p "Enter the encryption password (e.g., gsx2026): " backup_pass
        echo "" # Newline after silent prompt
        
        echo "$backup_pass" > "$SECRET_FILE"
        chmod 600 "$SECRET_FILE"
        log_info "Secret securely saved at $SECRET_FILE"
    else
        log_info "Secrets file is already configured."
    fi
}

install_systemd_units() {
    log_info "Installing automation services..."
    
    # Check if files exist before copying
    if [ ! -f "${PROJECT_SYSTEMD_DIR}/backup.service" ] || [ ! -f "${PROJECT_SYSTEMD_DIR}/backup.timer" ]; then
        log_error "Systemd unit files not found in ${PROJECT_SYSTEMD_DIR}. Please check your repository."
        exit 1
    fi

    cp "${PROJECT_SYSTEMD_DIR}/backup.service" "$SYSTEMD_DIR"
    cp "${PROJECT_SYSTEMD_DIR}/backup.timer" "$SYSTEMD_DIR"

    systemctl daemon-reload
    systemctl enable --now backup.timer
}

main() {
    check_root
    setup_secrets
    install_systemd_units
    log_info "Backup timer installed and activated successfully."
}

main "$@"