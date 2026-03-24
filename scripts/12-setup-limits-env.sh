#!/bin/bash
# Script: 12-setup-limits-env.sh
# Purpose: Configure resource limits (PAM) and shared shell environment for the team
# Usage: sudo ./12-setup-limits-env.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-21
# Exit Codes:
#   0 - Success
#   1 - Execution failed (not root)

set -euo pipefail

# Constants
readonly LIMITS_FILE="/etc/security/limits.d/greendevcorp.conf"
readonly PROFILE_FILE="/etc/profile.d/greendevcorp.sh"

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

configure_limits() {
    log_info "Configuring resource limits via PAM..."
    cat << 'EOF' > "$LIMITS_FILE"
# Limits for GreenDevCorp development team
# Format: <domain> <type> <item> <value>

# Max processes per user
@greendevcorp hard nproc 100

# Max open files per user
@greendevcorp hard nofile 1024

# Max virtual memory size in KB (e.g., 500MB = 500000)
@greendevcorp hard as 500000

# Max CPU time in minutes
@greendevcorp hard cpu 10
EOF
    log_info "Limits saved to ${LIMITS_FILE}."
}

configure_environment() {
    log_info "Configuring shared environment variables..."
    cat << 'EOF' > "$PROFILE_FILE"
# Shared shell configuration for GreenDevCorp team

if id -nG "$USER" 2>/dev/null | grep -qw "greendevcorp"; then
    export PATH="$PATH:/home/greendevcorp/bin"
    alias ll='ls -lah'
    alias tasks='cat /home/greendevcorp/done.log'
fi
EOF
    # Must be executable to be evaluated during login
    chmod +x "$PROFILE_FILE"
    log_info "Environment saved to ${PROFILE_FILE}."
}

main() {
    check_root
    log_info "Starting limits and environment configuration..."
    configure_limits
    configure_environment
    log_info "Limits and environment configuration completed."
}

main "$@"