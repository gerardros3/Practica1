#!/bin/bash
# Script: 08-process-diagnostics.sh
# Purpose: Identify top resource consumers, show process relationships, and extract metrics
# Usage: sudo ./08-process-diagnostics.sh
# Author: Gerard Ros & Miquel Garcia
# Date: 2026-03-18

set -euo pipefail

log_header() {
    echo "========================================="
    echo "   PROCESS DIAGNOSTICS - GREENDEVCORP    "
    echo "========================================="
}

show_top_consumers() {
    echo -e "\n---> 1. TOP 5 CPU CONSUMERS"
    # -e (all processes), -o (custom output formatting), --sort=-%cpu (descending CPU order)
    ps -eo pid,user,%cpu,%mem,cmd --sort=-%cpu | head -n 6

    echo -e "\n---> 2. TOP 5 MEMORY CONSUMERS"
    ps -eo pid,user,%cpu,%mem,cmd --sort=-%mem | head -n 6
}

show_process_tree() {
    echo -e "\n---> 3. PROCESS TREE (NGINX)"
    # We display the tree for a specific service (Nginx) to show parent/child relationships (fork/exec)
    if pgrep -x nginx > /dev/null; then
        local master_pid
        master_pid=$(pgrep -x nginx | head -n 1)
        pstree -p "$master_pid"
    else
        echo "[INFO] Nginx is not currently running."
    fi
}

extract_metrics() {
    echo -e "\n---> 4. SYSTEM AVERAGES & METRICS"
    echo "Current Load Average (1m, 5m, 15m):"
    uptime
    
    echo -e "\nTotal Memory Usage:"
    free -m
}

main() {
    log_header
    show_top_consumers
    show_process_tree
    extract_metrics
}

main "$@"