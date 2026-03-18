#!/bin/bash
# Script: 10-setup-workload.sh
# Purpose: Install and limit the workload service using cgroups
set -euo pipefail

cp /opt/admin/Practica1/systemd/workload.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now workload.service

echo "[INFO] Workload service started. Check CPU usage with 'top' (it should not exceed 20%)."