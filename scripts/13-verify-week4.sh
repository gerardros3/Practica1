#!/bin/bash
# Script: 13-verify-week4.sh
# Purpose: Verify least privilege access control and limits enforcement
# Usage: sudo ./13-verify-week4.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-21
# Exit Codes:
#   0 - Success
#   1 - Execution failed (not root)
#   2 - Verification failed

set -euo pipefail

readonly BASE_DIR="/home/greendevcorp"
readonly SHARED_DIR="${BASE_DIR}/shared"
readonly LOG_FILE="${BASE_DIR}/done.log"

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

verify_permissions() {
    log_info "Verifying shared directory permissions (setgid & sticky bit)..."
    
    # dev2 creates a file
    sudo -u dev2 touch "${SHARED_DIR}/dev2_test_file"
    local group_owner
    group_owner=$(stat -c "%G" "${SHARED_DIR}/dev2_test_file")
    
    if [ "$group_owner" != "greendevcorp" ]; then
        log_error "setgid failed: File did not inherit group 'greendevcorp'."
        exit 2
    fi
    log_info "setgid verified successfully."

    # dev3 tries to remove dev2's file
    set +e # Disable strict exit for the failing command
    sudo -u dev3 rm "${SHARED_DIR}/dev2_test_file" 2>/dev/null
    local rm_exit=$?
    set -e
    
    if [ ! -f "${SHARED_DIR}/dev2_test_file" ]; then
        log_error "Sticky bit failed: dev3 was able to delete dev2's file."
        exit 2
    fi
    log_info "Sticky bit verified successfully."
    
    # Cleanup
    rm "${SHARED_DIR}/dev2_test_file"

    log_info "Verifying done.log access..."
    # dev3 attempts to write
    set +e
    sudo -u dev3 bash -c "echo 'hack' >> ${LOG_FILE}" 2>/dev/null
    local write_exit=$?
    set -e
    
    if [ $write_exit -eq 0 ]; then
        log_error "Least Privilege failed: dev3 can write to done.log."
        exit 2
    fi

    # dev1 attempts to write
    sudo -u dev1 bash -c "echo 'Verified Week 4' >> ${LOG_FILE}"
    log_info "done.log permissions verified successfully."
}

verify_limits() {
    log_info "Verifying PAM limits for dev1..."
    
    # Extract hard limits directly querying as dev1
    local max_procs
    max_procs=$(sudo -u dev1 bash -c "ulimit -Hu")
    if [ "$max_procs" -ne 100 ]; then
        log_error "Process limit incorrect. Expected 100, got $max_procs"
        exit 2
    fi
    log_info "Process limit (nproc) verified."
}

main() {
    check_root
    log_info "Starting Week 4 verifications..."
    verify_permissions
    verify_limits
    log_info "All Week 4 verifications passed successfully!"
}

main "$@"