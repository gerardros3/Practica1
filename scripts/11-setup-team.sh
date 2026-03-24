#!/bin/bash
# Script: 11-setup-team.sh
# Purpose: Configure users, groups, and directory permissions for the development team
# Usage: sudo ./11-setup-team.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-21
# Exit Codes:
#   0 - Success
#   1 - Execution failed (not root)

set -euo pipefail

# Constants
readonly BASE_DIR="/home/greendevcorp"
readonly TEAM_GROUP="greendevcorp"
readonly TEAM_USERS=("dev1" "dev2" "dev3" "dev4")
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

setup_group_and_users() {
    log_info "Ensuring group ${TEAM_GROUP} exists..."
    if ! getent group "$TEAM_GROUP" >/dev/null; then
        groupadd "$TEAM_GROUP"
        log_info "Group ${TEAM_GROUP} created."
    fi

    for user in "${TEAM_USERS[@]}"; do
        if ! id -u "$user" >/dev/null 2>&1; then
            useradd -m -g "$TEAM_GROUP" -s /bin/bash "$user"
            log_info "User $user created."
        else
            log_info "User $user already exists."
        fi
    done
}

setup_directories_and_permissions() {
    log_info "Configuring team directories..."
    mkdir -p "${BASE_DIR}/bin"
    mkdir -p "${BASE_DIR}/shared"

    log_info "Applying base ownership..."
    chown root:"$TEAM_GROUP" "${BASE_DIR}/bin"
    chown root:"$TEAM_GROUP" "${BASE_DIR}/shared"

    log_info "Applying specific permissions (Least Privilege)..."
    # /home/greendevcorp/bin: Read/execute for group, full for root, nothing for others
    chmod 750 "${BASE_DIR}/bin"

    # /home/greendevcorp/shared: Shared workspace with setgid (2) and sticky bit (1)
    # 2770 = setgid, 1770 = sticky bit -> 3770 (setgid + sticky bit)
    chmod 3770 "${BASE_DIR}/shared"

    log_info "Configuring ${LOG_FILE}..."
    touch "$LOG_FILE"
    chown dev1:"$TEAM_GROUP" "$LOG_FILE"
    # dev1 can write, everyone else in the system can read
    chmod 644 "$LOG_FILE"
    
        log_info "Ensuring developers can traverse the base directory..."
	    chgrp "$TEAM_GROUP" "$BASE_DIR"
	        chmod 750 "$BASE_DIR"

}

main() {
    check_root
    log_info "Starting Team & Directories setup..."
    setup_group_and_users
    setup_directories_and_permissions
    log_info "Team setup completed successfully."
}

main "$@"
