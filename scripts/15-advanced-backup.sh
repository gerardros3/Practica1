#!/bin/bash
# Script: 15-advanced-backup.sh
# Purpose: Perform incremental snapshot backups using rsync
# Usage: sudo ./15-advanced-backup.sh
# Author: Gerard Ros & Miquel Garcia

set -euo pipefail

readonly SOURCE_DIR="/home/greendevcorp"
readonly BACKUP_BASE="/mnt/storage/backups"
readonly DATE=$(date +'%Y-%m-%d_%H-%M-%S')
readonly DEST_DIR="${BACKUP_BASE}/backup_${DATE}"
readonly LATEST_LINK="${BACKUP_BASE}/latest"

log_info() { echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $*"; }

main() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root." >&2
        exit 1
    fi

    mkdir -p "$BACKUP_BASE"
    log_info "Starting incremental backup of ${SOURCE_DIR} to ${DEST_DIR}..."

    if [ -L "$LATEST_LINK" ]; then
        log_info "Found previous backup. Performing incremental backup (hard-linking)..."
        rsync -a --delete --link-dest="$LATEST_LINK" "$SOURCE_DIR/" "$DEST_DIR/"
    else
        log_info "No previous backup found. Performing FULL backup..."
        rsync -a --delete "$SOURCE_DIR/" "$DEST_DIR/"
    fi

    # Update the 'latest' symlink
    ln -sfn "$DEST_DIR" "$LATEST_LINK"

    log_info "Backup completed successfully!"
}

main "$@"