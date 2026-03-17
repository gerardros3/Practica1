#!/bin/bash
# Script: 04-backup.sh
# Purpose: Package and encrypt sensitive data while preserving attributes
# Usage: sudo ./04-backup.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-04
# Exit Codes:
#   0 - Success
#   1 - Execution failed (not root, missing secrets, or encryption failed)

set -euo pipefail

# Constants
readonly SOURCE_DIR="/home/greendevcorp/data"
readonly BACKUP_DIR="/home/greendevcorp/backups"
readonly SECRET_FILE="/root/secrets/backup_pass.txt"

log_info() { echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $*"; }
log_error() { echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $*" >&2; }

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run the script with sudo."
        exit 1
    fi
}

prepare_environment() {
    mkdir -p "$SOURCE_DIR"
    mkdir -p "$BACKUP_DIR"
    # Create dummy data for testing purposes
    touch "${SOURCE_DIR}/test_data_prova.txt"
}

create_backup() {
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local temp_archive="${BACKUP_DIR}/backup_${timestamp}.tar.gz"
    local final_archive="${temp_archive}.gpg"

    # Document non-obvious logic:
    # -c (create), -z (compress with gzip), -p (preserve permissions), -f (specify filename)
    log_info "Generating Tar archive preserving permissions..."
    tar -czpf "$temp_archive" -C "$SOURCE_DIR" .

    if [ ! -f "$SECRET_FILE" ]; then
        log_error "Password file not found at $SECRET_FILE"
        rm -f "$temp_archive"
        exit 1
    fi

    # Document non-obvious logic:
    # --batch and --yes are crucial here to prevent GPG from prompting for user input
    # during unattended automated runs (e.g., systemd timers at 3 AM).
    log_info "Encrypting the backup non-interactively..."
    gpg --symmetric --cipher-algo AES256 --batch --yes --passphrase-file "$SECRET_FILE" "$temp_archive"

    if [ -f "$final_archive" ]; then
        log_info "Cleaning up unencrypted temporary archive..."
        rm -f "$temp_archive"
        log_info "Backup successfully completed: $final_archive"
    else
        log_error "There was a problem encrypting the backup."
        exit 1
    fi
}

main() {
    check_root
    log_info "Starting Secure Backup process..."
    prepare_environment
    create_backup
}

main "$@"