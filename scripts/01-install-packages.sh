#!/bin/bash
# Script: 01-install-packages.sh
# Purpose: Install basic required packages for the environment and configure SSH
# Usage: sudo ./01-install-packages.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-04
# Exit Codes:
#   0 - Success
#   1 - Execution failed (not root, or lockfile exists)

set -euo pipefail

# Constants
readonly LOCKFILE="/tmp/install-packages.lock"
readonly SSHD_CONFIG="/etc/ssh/sshd_config"

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

acquire_lock() {
    if [ -e "$LOCKFILE" ]; then
        log_error "Script is already running or lockfile exists."
        exit 1
    fi
    trap 'rm -f "$LOCKFILE"' EXIT
    touch "$LOCKFILE"
}

install_packages() {
    local packages=(
        "git"            # Version control
        "vim"            # Text editor
        "curl"           # Network tool
        "sudo"           # Privilege escalation
        "net-tools"      # Network statistics
        "ufw"            # Firewall
        "openssh-server" # Secure remote connections
        "gnupg"          # Encryption tool for backups
        "psmisc"         # Process management (pstree, killall)
    )

    log_info "Updating package index..."
    apt-get update -y > /dev/null

    log_info "Installing packages: ${packages[*]}..."
    # We redirect stdout to /dev/null to keep the console output clean, 
    # but let errors (stderr) print to the terminal if something fails.
    apt-get install -y "${packages[@]}" > /dev/null
}

configure_ssh() {
    log_info "Configuring SSH rules for Windows compatibility..."
    if ! grep -q "KexAlgorithms" "$SSHD_CONFIG"; then
        echo "KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256" >> "$SSHD_CONFIG"
        echo "HostKeyAlgorithms ssh-ed25519,ssh-rsa" >> "$SSHD_CONFIG"
        systemctl restart ssh
        log_info "SSH configuration updated and service restarted."
    else
        log_info "SSH configuration was already applied (Idempotent)."
    fi
}

main() {
    check_root
    acquire_lock
    log_info "Starting basic package installation..."
    install_packages
    configure_ssh
    log_info "Installation completed successfully."
}

main "$@"