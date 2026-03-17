#!/bin/bash
# Script: 02-directories.sh
# Purpose: Create the administrative directory structure
# Usage: sudo ./02-directories.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-04
# Exit Codes:
#   0 - Success
#   1 - Execution failed (not root)

set -euo pipefail

# Constants
readonly BASE_DIR="/home/greendevcorp"
readonly LOG_FILE="${BASE_DIR}/done.log"
readonly TARGET_USER="gsx"
readonly TARGET_GROUP="gsx"

log_info() {
    echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $*"
}

log_error() {
    echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $*" >&2
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run the script with sudo."
        exit 1
    fi
}

create_directories() {
    local dirs=(
        "${BASE_DIR}/bin"      # Scripts and admin tools
        "${BASE_DIR}/shared"   # Shared workspace
        "${BASE_DIR}/backups"  # Security backups
        "${BASE_DIR}/logs"     # Activity and error logs
        "${BASE_DIR}/data"     # Sensitive data
    )

    for dir in "${dirs[@]}"; do
        log_info "Configuring directory: $dir"
        mkdir -p "$dir"
    done
}

apply_permissions() {
    log_info "Setting base permissions..."
    touch "$LOG_FILE"
    
    chown -R "${TARGET_USER}:${TARGET_GROUP}" "$BASE_DIR"
    chmod -R 750 "$BASE_DIR"
}

main() {
    check_root
    log_info "Starting directory structure creation..."
    create_directories
    apply_permissions
    log_info "Directory structure successfully created at $BASE_DIR."
}

main "$@"