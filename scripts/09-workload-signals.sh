#!/bin/bash
# Script: 09-workload-signals.sh
# Purpose: Demonstrate process control, background jobs, and signal handling
# Usage: sudo ./09-workload-signals.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-18

set -euo pipefail

log_info() { echo "[INFO] $(date +'%H:%M:%S') - $*"; }

# Array to keep track of background PIDs
WORKER_PIDS=()

# The Cleanup function (Graceful Shutdown)
cleanup() {
    log_info "Graceful shutdown initiated. Saving state..."
    for pid in "${WORKER_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            log_info "Stopping worker PID $pid elegantly (SIGTERM)..."
            kill -15 "$pid" # SIGTERM
        fi
    done
    log_info "Cleanup complete. Exiting."
    exit 0
}

# Signal Traps (Catching signals before they kill the script)
trap 'log_info "Received SIGINT (Ctrl+C)."; cleanup' SIGINT
trap 'log_info "Received SIGTERM (Systemd stop)."; cleanup' SIGTERM
trap 'log_info "Received SIGUSR1. Status: Running smoothly."' SIGUSR1
trap 'log_info "Received SIGUSR2. Simulating config reload..."' SIGUSR2

main() {
    log_info "Starting intensive workload simulation..."
    log_info "My PID is: $$"
    
    # Launch 2 background jobs that consume CPU using 'yes'
    yes > /dev/null &
    WORKER_PIDS+=($!)
    yes > /dev/null &
    WORKER_PIDS+=($!)
    
    log_info "Workers started with PIDs: ${WORKER_PIDS[*]}"
    log_info "Waiting for signals... (Open another terminal to send: kill -SIGUSR1 $$)"
    
    # Infinite loop to keep the script alive and waiting for signals
    while true; do
        sleep 1
    done
}

main "$@"