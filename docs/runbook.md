# Operations Runbook

Aquest document detalla les tasques comunes i els procediments d'administració per a l'equip d'operacions de Greendevcorp.

## 1. Common Tasks & User Management

### How to access the system (Accés Remot)
Per accedir al servidor (Debian VM) via SSH amb el Port Forwarding de VirtualBox:
* **Comanda de connexió per defecte:** `ssh -p 2222 <nom_usuari>@127.0.0.1`

### Add a new developer to the team
Si s'incorpora un nou desenvolupador (`dev5`):
1. **Crear l'usuari i assignar-lo a l'equip:** `sudo useradd -m -g greendevcorp -s /bin/bash dev5`
2. **Assignar contrasenya:** `sudo passwd dev5`
3. A l'iniciar sessió, el seu entorn es configurarà automàticament gràcies a `/etc/profile.d/greendevcorp.sh`.

### Handle a team member leaving
Quan un membre de l'equip marxa de l'empresa:
1. **Bloquejar l'accés immediatament:** `sudo usermod -L <nom_usuari>`
2. **Reassignar la propietat dels seus fitxers** (opcional): `sudo chown -R dev1 /home/greendevcorp/shared/fitxers_antics`
3. **Eliminar l'usuari (sense esborrar el seu home):** `sudo userdel <nom_usuari>`

## 2. Service Management & Troubleshooting (Week 2 & 3)

### Service Status and Logs
* **Comprovar logs globals ràpidament:** `sudo /opt/admin/Practica1/scripts/07-check-logs.sh`
* **Veure quan serà el pròxim backup:** `systemctl list-timers --all | grep backup`

### Diagnose a slow system
1. **Check System Load:** Executa `uptime`. Si els *load averages* superen el nombre de nuclis de CPU, hi ha sobrecàrrega.
2. **Identify the Culprit:** Executa `top` o el nostre script `08-process-diagnostics.sh` per trobar el PID problemàtic.
3. **Analyze & Act:** * Analitza els fills amb `pstree -p <PID>`.
   * Atura el procés suaument (Graceful): `kill -SIGTERM <PID>`
   * Si es queda clavat, força'l: `kill -SIGKILL <PID>`
  
## 3. Users & Access Management (Week 4)

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

## 4. Storage & Disaster Recovery (Week 5)

### How to mount a new disk manually
1. Particionar: `sudo parted -s /dev/sdc mklabel gpt mkpart primary ext4 0% 100%`
2. Formatar i Trobar UUID: `sudo mkfs.ext4 /dev/sdc1 && sudo blkid /dev/sdc1`
3. Afegir a FSTAB i muntar: `echo "UUID=XXXX /mnt/new_disk ext4 defaults 0 2" | sudo tee -a /etc/fstab && sudo mount -a`

### Step-by-Step Disaster Recovery Procedure (Restore from Backup)
Si la carpeta `/home/greendevcorp` s'esborra o corromp:
1. Aturar serveis que escriguin en aquest directori.
2. Localitzar el backup: `ls -la /mnt/storage/backups/latest/`
3. Executar restauració: `sudo rsync -a /mnt/storage/backups/latest/ /home/greendevcorp/`
4. Reaplicar permisos: Executar `sudo ./scripts/11-setup-team.sh` per assegurar el *setgid* i *sticky bit*.
*(Aquest procés pren habitualment menys de 5 minuts depenent de la mida de les dades).*

## 4. Escalation Procedures
Si els passos de *Troubleshooting* d'aquest Runbook no resolen la incidència:
* **Tier 1 (Autoservei):** Els desenvolupadors consulten aquest Runbook.
* **Tier 2 (Sysadmin Team):** Contactar amb Gerard Ros o Miquel Garcia via canal intern de l'empresa. S'analitzaran els logs profunds i problemes de xarxa.
* **Tier 3 (External / Architect):** Si hi ha pèrdua massiva de dades o el hardware físic falla, escalar a l'arquitecte d'infraestructura o el proveïdor de Cloud.
