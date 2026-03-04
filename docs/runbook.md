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