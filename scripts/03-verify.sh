#!/bin/bash
# Script: 03-verify.sh
# Purpose: Verify that required packages and directories exist, auto-repair if needed
# Usage: sudo ./03-verify.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-04
# Exit Codes:
#   0 - Success
#   1 - Execution failed (not root)

set -euo pipefail

# Constants
readonly BASE_DIR="/home/greendevcorp"
readonly DONE_LOG="${BASE_DIR}/done.log"

log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*"; }
log_error() { echo "[ERROR] $*" >&2; }

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run the script with sudo."
        exit 1
    fi
}

verify_packages() {
    local packages=("git" "vim" "curl" "ufw")
    local needs_packages=0

    for pkg in "${packages[@]}"; do
        if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "ok installed"; then
            log_warn "Package '$pkg' is not installed."
            needs_packages=1
        else
            log_info "Package '$pkg' is correctly installed."
        fi
    done
    return "$needs_packages"
}

verify_directories() {
    local dirs=("bin" "shared" "backups" "logs" "data")
    local needs_dirs=0

    for dir in "${dirs[@]}"; do
        if [ ! -d "${BASE_DIR}/${dir}" ]; then
            log_warn "Missing directory: ${BASE_DIR}/${dir}"
            needs_dirs=1
        else
            log_info "Directory '$dir' found."
        fi
    done

    if [ ! -f "$DONE_LOG" ]; then
        log_warn "Missing marker file '$DONE_LOG'."
        needs_dirs=1
    else
        log_info "Marker file '$DONE_LOG' found."
    fi
    return "$needs_dirs"
}

main() {
    check_root
    log_info "Starting system verification..."

    local trigger_packages=0
    local trigger_dirs=0

    verify_packages || trigger_packages=1
    verify_directories || trigger_dirs=1

    if [ "$trigger_packages" -eq 1 ]; then
        log_info "Auto-repairing: Running package installation script..."
        bash ./01-install-packages.sh
    fi

    if [ "$trigger_dirs" -eq 1 ]; then
        log_info "Auto-repairing: Running directory creation script..."
        bash ./02-directories.sh
    fi

    log_info "Verification completed. System is in the desired state."
}

main "$@"