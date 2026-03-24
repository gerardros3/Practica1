#!/bin/bash
# Script: 16-setup-nfs.sh
# Purpose: Configure NFS Server for team shared storage
# Usage: sudo ./16-setup-nfs.sh

set -euo pipefail

readonly NFS_DIR="/mnt/storage/nfs_shared"
readonly EXPORT_LINE="${NFS_DIR} *(rw,sync,no_subtree_check,no_root_squash)"

log_info() { echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $*"; }

main() {
    if [ "$EUID" -ne 0 ]; then exit 1; fi

    log_info "Installing NFS kernel server..."
    apt-get update -qq >/dev/null
    apt-get install -y nfs-kernel-server >/dev/null

    log_info "Configuring shared directory..."
    mkdir -p "$NFS_DIR"
    chown nobody:nogroup "$NFS_DIR"
    chmod 777 "$NFS_DIR"

    if ! grep -q "$NFS_DIR" /etc/exports; then
        echo "$EXPORT_LINE" >> /etc/exports
        log_info "Export added to /etc/exports."
    fi

    exportfs -a
    systemctl restart nfs-kernel-server
    systemctl enable nfs-kernel-server

    log_info "NFS Server configured. ${NFS_DIR} is now shared."
}

main "$@"