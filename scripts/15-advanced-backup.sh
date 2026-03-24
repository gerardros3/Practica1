#!/bin/bash
# Script: 15-advanced-backup.sh
# Purpose: Perform incremental snapshot backups using rsync
# Usage: sudo ./15-advanced-backup.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-24
# Exit Codes:
#   0 - Success
#   1 - Execution failed (not root)

set -euo pipefail

# Constants
readonly SOURCE_DIR="/home/greendevcorp"
readonly BACKUP_BASE="/mnt/storage/backups"
readonly DATE=$(date +'%Y-%m-%d_%H-%M-%S')
readonly DEST_DIR="${BACKUP_BASE}/backup_${DATE}"
readonly LATEST_LINK="${BACKUP_BASE}/latest"

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

install_dependencies() {
    if ! command -v rsync >/dev/null 2>&1; then
        log_info "Installing 'rsync'..."
        apt-get update -qq >/dev/null
        apt-get install -y rsync >/dev/null
    fi
}

perform_backup() {
    mkdir -p "$BACKUP_BASE"
    log_info "Starting backup of ${SOURCE_DIR} to ${DEST_DIR}..."

    if [ -L "$LATEST_LINK" ]; then
        log_info "Found previous backup. Performing incremental backup (hard-linking)..."
        rsync -a --delete --link-dest="$LATEST_LINK" "$SOURCE_DIR/" "$DEST_DIR/"
    else
        log_info "No previous backup found. Performing FULL backup..."
        rsync -a --delete "$SOURCE_DIR/" "$DEST_DIR/"
    fi

    # Update the 'latest' symlink
    ln -sfn "$DEST_DIR" "$LATEST_LINK"
}

main() {
    check_root
    install_dependencies
    perform_backup
    log_info "Backup completed successfully!"
}

main "$@"