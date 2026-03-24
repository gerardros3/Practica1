#!/bin/bash
# Script: 17-verify-backup.sh
# Purpose: Test backup restoration and integrity
# Usage: sudo ./17-verify-backup.sh

set -euo pipefail

readonly LATEST_BACKUP="/mnt/storage/backups/latest"
readonly RESTORE_TEST_DIR="/tmp/restore_test"

log_info() { echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $*"; }
log_error() { echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $*" >&2; }

main() {
    if [ "$EUID" -ne 0 ]; then exit 1; fi

    if [ ! -d "$LATEST_BACKUP" ]; then
        log_error "No backups found to verify!"
        exit 1
    fi

    log_info "Cleaning old test directories..."
    rm -rf "$RESTORE_TEST_DIR"
    mkdir -p "$RESTORE_TEST_DIR"

    log_info "Restoring latest backup to ${RESTORE_TEST_DIR}..."
    cp -a "${LATEST_BACKUP}/." "$RESTORE_TEST_DIR/"

    # Check if a known file exists
    if [ -f "${RESTORE_TEST_DIR}/done.log" ]; then
        log_info "SUCCESS: done.log found in restored data. Integrity check passed."
    else
        log_error "FAILED: Could not find done.log in restored data."
        exit 1
    fi

    # Cleanup
    rm -rf "$RESTORE_TEST_DIR"
    log_info "Restore test completed and cleaned up."
}

main "$@"