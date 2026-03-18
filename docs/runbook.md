# Operations Runbook

Aquest document detalla les tasques comunes i els procediments d'administració per a l'equip d'operacions de Greendevcorp.

## 1. Common Tasks

### How to access the system (Accés Remot)
Per accedir al servidor (Debian VM) de forma remota des de l'ordinador host, cal utilitzar SSH. Prèviament, s'ha de configurar una regla de *Port Forwarding* a VirtualBox que redirigeixi el port 2222 del host al port 22 (SSH) del convidat.
* **Comanda de connexió per defecte:** `ssh -p 2222 gsx@127.0.0.1`

## 2. Service Management (Week 2)

### Gestió de Nginx i Backups
La infraestructura utilitza `systemd` per a la gestió de serveis i `journald` per als logs.
* **Comprobar logs ràpidament:** Executar `sudo /opt/admin/Practica1/scripts/07-check-logs.sh`.
* **Reiniciar Nginx manualment:** `sudo systemctl restart nginx`
* **Veure quan serà el pròxim backup:** `systemctl list-timers --all | grep backup`

### Troubleshooting: Com diagnostiquem els errors?
* **Nginx cau a les 3 AM:** No cal fer res a l'instant. `systemd` està configurat per reiniciar-lo automàticament (`Restart=always`). L'endemà ho veurem als logs executant l'script d'observabilitat.
* **Backups fallen silenciosament:** Si el backup falla (ex: disc ple, error de GPG), el servei de systemd registrarà el codi de sortida d'error al `journald`. Ens n'adonarem revisant el nostre script de logs o comprovant si el pes de l'arxiu `.gpg` és 0.

## 3. Process & Resource Troubleshooting (Week 3)

### The server feels slow. What do I check?
1. **Check System Load & Uptime:** Run `uptime`. Look at the load averages (1m, 5m, 15m). If the number is higher than the amount of CPU cores, the system is overloaded.
2. **Identify the Culprit:** Run `top` or our diagnostic script `sudo ./scripts/08-process-diagnostics.sh`. Sort by `%CPU` or `%MEM` to find the rogue process ID (PID).
3. **Analyze the Process:** Use `pstree -p <PID>` to see if it spawned child processes.
4. **Take Action (Graceful first):** - Ask it nicely to stop: `kill -SIGTERM <PID>`
   - If it ignores you after 10 seconds (zombie/stuck): `kill -SIGKILL <PID>`