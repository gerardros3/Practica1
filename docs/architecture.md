# System Architecture & Design Documentation

## 1. Design Rationale (Decisions de Disseny)

* **Why did you choose SSH over other options?** Hem triat SSH (Secure Shell) perquè és l'estàndard actual de la indústria per a l'administració remota. Proporciona una connexió xifrada d'extrem a extrem (evitant que algú pugui capturar trànsit en text pla com passaria amb Telnet) i permet una autenticació robusta.

* **Why this directory structure?**
  Hem preparat l'estructura a `/home/greendevcorp` dissenyada per al treball en equip. Hem creat subcarpetes estàndard com `bin/` (per als executables i scripts compartits), `shared/` (per a treball en equip amb setgid), a més de `backups/`, `logs/` i `data/`. Això centralitza l'administració respectant l'estàndard de Linux i facilitant la gestió de privilegis mínims.

* **How to prevent accidental simultaneous setups?**
  Als nostres scripts d'instal·lació hem implementat un **Mecanisme de Bloqueig (Lockfile)**. A l'inici de l'script es crea un fitxer a `/tmp/install-packages.lock`. Si un altre usuari executa l'script simultàniament, detectarà que el fitxer ja existeix i s'aturarà per evitar condicions de carrera.

* **What information should be in Git, and what should only live on the server?**
  * **Al Git:** La "Infraestructura com a codi" (els scripts `.sh`), documentació (Markdown) i fitxers de configuració genèrics.
  * **Al Servidor (Local):** Bases de dades, fitxers de registre (`logs/`), còpies de seguretat xifrades (`backups/`), i **secrets** (claus privades SSH, passwords, fitxers `.env`). Això evita bretxes de seguretat; i per garantir-ho fem servir un fitxer `.gitignore`.

## 2. Trade-offs i Limitacions actuals

* **Passwords vs. Keys for SSH:** Actualment el sistema permet l'accés per contrasenya, la qual cosa és vulnerable a atacs de força bruta o diccionari. El nostre objectiu és transicionar a claus SSH (Public/Private Key pair) per a tots els usuaris, la qual cosa ens permetrà desactivar el *password login* al fitxer `sshd_config`, eliminant un vector d'atac massiu.

* **Disaster Recovery i Reinstal·lació:**
  Si s'hagués de reinstal·lar el sistema, els nostres scripts (sent idempotents) poden restaurar tota l'estructura i configuració base (carpetes, permisos, paquets i, fins i tot, els ajustos de compatibilitat de l'arxiu `sshd_config`). **El que faltaria:**
  * Les dades pròpiament dites dels usuaris i de l'empresa. Aquestes s'haurien de restaurar extraient i desxifrant manualment l'última còpia de seguretat generada pel nostre script de backup (`04-backup.sh`). Tota la resta de la infraestructura s'aixeca des de zero sense intervenció manual, complint amb el paradigma d'Infraestructura com a Codi (IaC).

  ## 3. Observability & Automation (Week 2)

* **Resiliència de Serveis:** Hem configurat Nginx amb un *drop-in override* de systemd (`Restart=always`, `RestartSec=5`). Aquest disseny garanteix que el servei s'aixequi sol davant d'una fallada inesperada, millorant l'uptime del sistema.
* **Automatització de Tasques:** Hem substituït l'execució manual de backups per *systemd timers*. Això ens proporciona observabilitat integrada i un registre d'auditoria centralitzat, que és superior al cron clàssic. L'script ara llegeix els secrets d'un directori segur (`/root/secrets`) per permetre l'execució no interactiva sense exposar la contrasenya a Git.

<<<<<<< HEAD
## 4. Users, Groups & Access Control (Week 4)
=======
* ## 4. Users, Groups & Access Control (Week 4)
>>>>>>> 7bb80fb9921d36c9f6b7ddb2411bc9352add75b5

* **Organització d'Usuaris i Grups:** Hem creat el grup primari `greendevcorp` per representar l'equip. Els usuaris `dev1`, `dev2`, `dev3` i `dev4` comparteixen aquest grup. El disseny de grups UNIX permet organitzar els permisos basats en el principi de menor privilegi (*Least Privilege*), on cada treballador té el seu espai privat al `~` però tots convergeixen cap a un punt unificat on el sistema pot donar drets.
* **Control d'Accés i Carpetes Compartides:** 
  * A la carpeta `shared/` utilitzem l'especificador **setgid (`chmod 2770`)** perquè tots els documents nous creats per qualsevol `dev` estiguin directament sota el paraigua del grup col·laboratiu en comptes del seu propi.
  * També hem introduït el **Sticky Bit (`chmod +t`)**. Aquest flag addicional en un directori prevé que l'usuari `dev2` esborri de manera accidental (o maliciosa) un fitxer propietat del `dev1` en el medi compartit.
* **Limitació de Recursos via PAM:** Per evitar que un codi escrit per un `dev` (per exemple, un loop infinit de processos) col·lapsi el sistema dels seus companys, utilitzem `limits.conf` (del mòdul de seguretat `PAM`). Així garantim un `hard limit` en el nombre màxim de processos i fitxers oberts (nproc, nofile) de manera transversal a tothom que sigui del grup `@greendevcorp`.
<<<<<<< HEAD

## 5. Storage & Backup Architecture (Week 5)

* **Disk Setup & FSTAB:** Hem introduït un segon disc virtual (`/dev/sdb`) exclusivament per dades i backups. Això aïlla el sistema operatiu de les dades d'usuari. L'hem particionat amb `parted` usant el format `ext4` per ser un *journaling file system* robust. El muntatge a `/mnt/storage` es fa persistent via `/etc/fstab` (`defaults 0 2`).
* **Backup Strategy:** Utilitzem una política "Daily Incremental, Weekly Full" optimitzada per *hard-links*.
  * **RPO (Recovery Point Objective):** 24 hores (fem backup cada dia, pel que màxim perdem la feina d'un dia).
  * **RTO (Recovery Time Objective):** Menys de 15 minuts. Com que guardem els arxius crus usant `rsync` sense compressió `tar.gz`, el temps de restauració es limita només a la velocitat d'escriptura del disc.
* **Network Storage (NFS):** Hem instal·lat `nfs-kernel-server` per compartir `/mnt/storage/nfs_shared` a tota la xarxa local. Això ens permet tenir aplicacions (Nginx) en una màquina diferent de les dades.
=======
>>>>>>> 7bb80fb9921d36c9f6b7ddb2411bc9352add75b5
