#!/bin/bash
# Script: 16-setup-nfs.sh
# Purpose: Configure NFS Server for team shared storage
# Usage: sudo ./16-setup-nfs.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-24
# Exit Codes:
#   0 - Success
#   1 - Execution failed (not root)

set -euo pipefail

# Constants
readonly NFS_DIR="/mnt/storage/nfs_shared"
readonly EXPORT_LINE="${NFS_DIR} *(rw,sync,no_subtree_check,no_root_squash)"

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

install_nfs() {
    log_info "Installing NFS kernel server..."
    apt-get update -qq >/dev/null
    apt-get install -y nfs-kernel-server >/dev/null
}

configure_exports() {
    log_info "Configuring shared directory..."
    mkdir -p "$NFS_DIR"
    chown nobody:nogroup "$NFS_DIR"
    chmod 777 "$NFS_DIR"

    if ! grep -q "$NFS_DIR" /etc/exports; then
        echo "$EXPORT_LINE" >> /etc/exports
        log_info "Export added to /etc/exports."
    else
        log_info "Export entry already exists in /etc/exports."
    fi

    exportfs -a
    systemctl restart nfs-kernel-server
    systemctl enable nfs-kernel-server
}

main() {
    check_root
    install_nfs
    configure_exports
    log_info "NFS Server configured. ${NFS_DIR} is now shared."
}

main "$@"