# Infrastructure Automation (Week 1)
Durant aquesta primera setmana hem passat de veure l'administració de sistemes com un procés manual a entendre-la com a **Infraestructura com a Codi (IaC)**. 

El concepte més important ha estat la **idempotència**. Hem après a dissenyar scripts perquè defineixin l'estat desitjat del sistema, podent executar-los desenes de vegades consecutives sense trencar dependències. També hem après l'ús de mecanismes de bloqueig (*lockfiles*) per prevenir la concurrència no planificada.

# Services & Observability (Week 2)
La clau de l'observabilitat és que elimina les "suposicions". Mostrant l'historial del `journalctl` on un procés mor per un `SIGKILL` i systemd el reanima, es demostra a l'equip per què va fallar i com l'automatització ens salva d'una incidència. Si els backups fallen, el servei de `systemd` capturarà l'Exit Code i ho registrarà automàticament al `journald`.

# Process Management & Resource Control (Week 3)
`SIGTERM` és una petició educada per tancar, permetent a l'aplicació guardar dades (via `trap`), mentre que `SIGKILL` és una aturada forçada pel kernel que pot corrompre dades. Un servei correcte ha de respondre al `SIGTERM` netejant processos fills per no deixar "orfes". 

Per verificar si un límit de recursos funciona, apliquem el mètode científic: ofeguem la CPU amb la comanda `yes`, apliquem `cgroups` (CPUQuota), i validem amb `top` que el límit matemàtic s'aplica.

# Team Collaboration & Security (Week 4)
Per compartir arxius utilitzem el **setgid** en un directori perquè qualsevol fitxer hereti el grup compartit. A més, configurem permisos `640` o `644` perquè l'equip ho pugui llegir sense usar `777`. El model de seguretat el verifiquem de forma empírica simulant accessos (`sudo -u dev3 rm...`) i validant els *Exit Codes* d'error.

# Storage, Backup & Recovery (Week 5)

**If you back up every file every night, you’ll have massive backups. How could you reduce storage overhead? What’s the trade-off?**
Per reduir l'impacte, implementem **Backups Incrementals** usant `rsync --link-dest` (hard links). El *trade-off* és que si el disc físic falla o es corromp l'inode, perdem múltiples dies de backup de cop.

**What is the 3-2-1 principle?**
L'estratègia 3-2-1 significa tenir **3** còpies de les dades, en **2** mitjans d'emmagatzematge diferents, i **1** còpia "*offsite*" (fora de les oficines, al núvol).

**How would you handle a database that’s currently being written to?**
No podem fer un `cp` dels fitxers crus d'una BD activa. Cal utilitzar eines del gestor (`pg_dump`) per extreure un SQL lògic, o fer servir un **Snapshot LVM** per congelar l'estat del disc en mil·lisegons abans de la còpia.

---

# Final Reflection Essay

**Gerard Ros:**
* **What was the most challenging aspect of this project?** ...
* **What would you do differently if you started over?** ...
* **How has your understanding of system administration changed?** ...
* **What’s one thing you’d want to learn more about?** ...

**Miquel Garcia:**
* **What was the most challenging aspect of this project?** El repte més gran ha estat entendre i aplicar el control de processos i els límits de recursos amb `cgroups` (Week 3). Passar de simplement "matar" un procés problemàtic amb `SIGKILL` a dissenyar un *graceful shutdown* capturant senyals amb `trap` ens ha obligat a canviar la mentalitat i a pensar en com es comporten les aplicacions a baix nivell quan interactuen amb el kernel de Linux.
* **What would you do differently if you started over?** Si hagués de tornar a començar, hauria establert les guies d'estil estrictes (com les funcions genèriques de `log_info`, `check_root` i el bloqueig per `set -euo pipefail`) des de la línia 1 del primer script. Com que vam anar aprenent sobre la marxa, hem hagut de fer una refactorització massiva al final per unificar-ho tot. Tenir una plantilla base des del principi ens hauria estalviat temps i deute tècnic.
* **How has your understanding of system administration changed?** Abans veia l'administració de sistemes com una feina reactiva i manual (connectar-se al servidor per arreglar el que s'ha trencat). Ara entenc que és una disciplina més propera a l'enginyeria de programari: dissenyem "Infraestructura com a Codi" (IaC) completament idempotent perquè el sistema es construeixi sol, s'auto-repari si un servei cau, i quedi tot auditat a través de Git.
* **What’s one thing you’d want to learn more about?** M'agradaria aprofundir en la Integració i Desplegament Continu (CI/CD) aplicat a sistemes. Ara que tenim scripts de validació (com el `03-verify.sh` o el `17-verify-backup.sh`), m'interessa aprendre com connectar el nostre repositori de GitHub amb eines com GitHub Actions o Jenkins perquè, cada vegada que fem un *push*, s'aixequi una màquina virtual efímera, s'executin tots els scripts i ens avisi automàticament si hem trencat alguna cosa abans d'arribar a producció.