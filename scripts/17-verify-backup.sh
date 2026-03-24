#!/bin/bash
# Script: 17-verify-backup.sh
# Purpose: Test backup restoration and integrity
# Usage: sudo ./17-verify-backup.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-24
# Exit Codes:
#   0 - Success
#   1 - Execution failed (not root, no backups found, or integrity check failed)

set -euo pipefail

# Constants
readonly LATEST_BACKUP="/mnt/storage/backups/latest"
readonly RESTORE_TEST_DIR="/tmp/restore_test"

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

test_restore() {
    if [ ! -d "$LATEST_BACKUP" ]; then
        log_error "No backups found to verify at $LATEST_BACKUP!"
        exit 1
    fi

    log_info "Cleaning old test directories..."
    rm -rf "$RESTORE_TEST_DIR"
    mkdir -p "$RESTORE_TEST_DIR"

    log_info "Restoring latest backup to ${RESTORE_TEST_DIR}..."
    cp -a "${LATEST_BACKUP}/." "$RESTORE_TEST_DIR/"

    # Check if a known file exists (testing integrity)
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

main() {
    check_root
    test_restore
}

main "$@"