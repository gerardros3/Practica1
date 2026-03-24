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

## 4. Users & Access Management (Week 4)

### Troubleshooting: A user can't access a shared file. How do I debug?
1. **Verificar els Grups de l'Usuari:** Executar `groups <nom_usuari>` o `id <nom_usuari>`. L'usuari hauria d'estar dins del grup correcte (`greendevcorp`).
2. **Revisar Propietat i Permisos:** Executar `ls -lah <ruta_del_fitxer>`. Fixar-se en:
   * Els permisos (ex. `rw-r-----`). Si la 2a columna (grup) no té la lletra `r` o `w`, el membre de l'equip no hi podrà interactuar.
   * El grup assignat. Si el fitxer no està assignat al grup `greendevcorp`, s'ha de solucionar amb `chown :greendevcorp <fitxer>`.
3. **El Sticky bit dóna problemes:** Recordar que si algú no pot **esborrar** un fitxer però sí pot llegir i escriure, pot ser degut al *Sticky Bit* aplicat a la carpeta (`t` en els permisos `drwxrwx--T`). Només el propietari del fitxer el pot esborrar.

### Onboarding Guide for New Team Members
Si s'incorpora un nou desenvolupador (`dev5`):
1. **Crear l'usuari i assignar-lo a l'equip:** 
   `sudo useradd -m -g greendevcorp -s /bin/bash dev5`
2. **Assignar contrasenya o clau SSH:**
   `sudo passwd dev5`
3. **Entorn personalitzat:**
   Al moment de fer el login, el nou membre carregarà automàticament la configuració general ubicada a `/etc/profile.d/greendevcorp.sh`, la qual li habilitarà el `$PATH` correcte per utilitzar les eines internes col·locades a `/home/greendevcorp/bin` i els àlies configurats.

## 5. Storage & Disaster Recovery (Week 5)

### How to mount a new disk manually
Si VirtualBox afegeix un tercer disc (`/dev/sdc`):
1. Particionar: `sudo parted -s /dev/sdc mklabel gpt mkpart primary ext4 0% 100%`
2. Formatar: `sudo mkfs.ext4 /dev/sdc1`
3. Trobar la UUID: `sudo blkid /dev/sdc1`
4. Afegir a FSTAB i muntar: `echo "UUID=XXXX /mnt/new_disk ext4 defaults 0 2" | sudo tee -a /etc/fstab && sudo mount -a`

### Step-by-Step Disaster Recovery Procedure
Si la carpeta `/home/greendevcorp` ha estat esborrada accidentalment:
1. Aturar l'escriptura (aturar serveis Nginx si depenen d'aquest directori).
2. Llistar l'últim backup disponible: `ls -la /mnt/storage/backups/latest/`
3. Executar la restauració usant `rsync`:
   `sudo rsync -a /mnt/storage/backups/latest/ /home/greendevcorp/`
4. Confirmar els permisos i propietaris:
   `sudo ./scripts/11-setup-team.sh` (això re-aplicarà el *setgid* i *sticky bit* als directoris recentment restaurats sense tocar les dades).