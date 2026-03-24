#!/bin/bash
# Script: 14-setup-storage.sh
# Purpose: Format and mount a new secondary disk persistently
# Usage: sudo ./14-setup-storage.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-24
# Exit Codes:
#   0 - Success
#   1 - Execution failed (not root or missing disk)

set -euo pipefail

# Constants
readonly DISK="/dev/sdb"
readonly MOUNT_POINT="/mnt/storage"
readonly FSTAB_ENTRY="${DISK}1 ${MOUNT_POINT} ext4 defaults 0 2"

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

check_disk() {
    if [ ! -b "$DISK" ]; then
        log_error "Disk $DISK not found. Please add a virtual disk in VirtualBox first."
        exit 1
    fi
}

install_dependencies() {
    log_info "Checking dependencies..."
    if ! command -v parted >/dev/null 2>&1; then
        log_info "Installing 'parted'..."
        apt-get update -qq >/dev/null
        apt-get install -y parted >/dev/null
    fi
}

setup_storage() {
    log_info "Setting up storage on $DISK..."

    # Check if partition already exists to ensure idempotence
    if ! blkid "${DISK}1" >/dev/null 2>&1; then
        log_info "Partitioning ${DISK}..."
        parted -s "$DISK" mklabel gpt
        parted -s "$DISK" mkpart primary ext4 0% 100%
        
        # Give the OS a second to recognize the new partition
        sleep 2
        
        log_info "Formatting ${DISK}1 to ext4..."
        mkfs.ext4 "${DISK}1"
    else
        log_info "Partition ${DISK}1 already exists. Skipping formatting."
    fi

    log_info "Creating mount point ${MOUNT_POINT}..."
    mkdir -p "$MOUNT_POINT"

    log_info "Configuring /etc/fstab for persistent mounting..."
    if ! grep -q "${MOUNT_POINT}" /etc/fstab; then
        echo "$FSTAB_ENTRY" >> /etc/fstab
        log_info "Added entry to /etc/fstab."
    else
        log_info "Entry in /etc/fstab already exists."
    fi

    log_info "Mounting the disk..."
    # 'mount -a' will read fstab and mount sdb1 to /mnt/storage
    mount -a
    
    # Set proper permissions for the backup directory
    mkdir -p "${MOUNT_POINT}/backups"
    mkdir -p "${MOUNT_POINT}/nfs_shared"
    chown -R root:root "${MOUNT_POINT}/backups"
    chmod 700 "${MOUNT_POINT}/backups"
}

main() {
    check_root
    check_disk
    install_dependencies
    setup_storage
    log_info "Storage setup completed successfully! Disk mounted at $MOUNT_POINT"
}

main "$@"