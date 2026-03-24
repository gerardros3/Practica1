# System Architecture & Design Documentation

## System Architecture Diagram
A continuació es mostra l'esquema lògic dels components del servidor:
```text
[ External Clients / Dev Team ] 
       │
       ▼ (SSH Port Forwarding: 2222 -> 22) / (HTTP: 8080 -> 80)
┌──────────────────────────────────────────────────────────────┐
│                       DEBIAN SERVER (VM)                     │
│                                                              │
│  [ Services & Process Control (Systemd & cgroups) ]          │
│   ├─ nginx.service    (Web Server - Auto-recovery enabled)   │
│   ├─ workload.service (Background Jobs - CPUQuota=20%)       │
│   └─ backup.timer     (Automated Daily rsync Backups)        │
│                                                              │
│  [ Security & Access Control (PAM) ]                         │
│   └─ @greendevcorp limits (nproc=100, nofile=1024)           │
│                                                              │
│  [ Primary Disk: /dev/sda1 (ext4) ]                          │
│   └─ /home/greendevcorp/                                     │
│       ├─ bin/       (Admin scripts - chmod 750)              │
│       ├─ shared/    (Workspace - setgid & sticky bit 3770)   │
│       └─ done.log   (Audit log - chown dev1:greendevcorp)    │
│                                                              │
│  [ Secondary Persistent Disk: /dev/sdb1 (ext4) ]             │
│   └─ /mnt/storage/                                           │
│       ├─ backups/   (rsync incremental hard-link snapshots)  │
│       └─ nfs_shared/(NFS Export: rw,sync,no_root_squash) ────┼──► [ Local Network ]
└──────────────────────────────────────────────────────────────┘
```

## 1. Design Rationale (Decisions de Disseny)

* **Why did you choose SSH over other options?** Hem triat SSH (Secure Shell) perquè és l'estàndard actual de la indústria per a l'administració remota. Proporciona una connexió xifrada d'extrem a extrem i permet una autenticació robusta.
* **Why this directory structure?** Hem preparat l'estructura a `/home/greendevcorp` dissenyada per al treball en equip. Centralitza l'administració respectant l'estàndard de Linux i facilitant la gestió de privilegis mínims (Least Privilege).
* **How to prevent accidental simultaneous setups?** Als nostres scripts d'instal·lació hem implementat un **Mecanisme de Bloqueig (Lockfile)** a `/tmp/install-packages.lock` per evitar condicions de carrera.
* **What information should be in Git, and what should only live on the server?** * **Al Git:** La "Infraestructura com a codi" (scripts `.sh`), documentació i fitxers genèrics.
  * **Al Servidor:** Bases de dades, logs, backups i **secrets** (claus privades, passwords). Això s'assegura amb un fitxer `.gitignore`.

## 2. Trade-offs i Limitacions actuals

* **Passwords vs. Keys for SSH:** Actualment permetem l'accés per contrasenya, vulnerable a atacs de força bruta. L'objectiu és transicionar exclusivament a claus SSH per desactivar el *password login* a l'arxiu `sshd_config`.
* **Disaster Recovery i Reinstal·lació:** Si s'hagués de reinstal·lar el sistema, els nostres scripts idempotents poden restaurar tota la configuració base. El que faltaria serien les dades d'usuari, que s'haurien d'extreure manualment de l'últim backup generat per `15-advanced-backup.sh`.

## 3. Observability & Automation (Week 2)

* **Resiliència de Serveis:** Hem configurat Nginx amb un *drop-in override* de systemd (`Restart=always`, `RestartSec=5`) garantint que el servei s'aixequi sol davant d'una fallada.
* **Automatització de Tasques:** Hem substituït l'execució manual de backups per *systemd timers*, proporcionant observabilitat integrada i un registre d'auditoria centralitzat al `journald`.

## 4. Users, Groups & Access Control (Week 4)

* **Organització d'Usuaris i Grups:** Hem creat el grup primari `greendevcorp`. Aquest disseny permet organitzar els permisos basats en el principi de menor privilegi (*Least Privilege*).
* **Control d'Accés i Carpetes Compartides:** * A `shared/` utilitzem **setgid (`chmod 2770`)** perquè els documents heretin el grup col·laboratiu.
  * Hem introduït el **Sticky Bit (`chmod +t`)** per prevenir que usuaris esborrin de manera accidental fitxers de companys.
* **Limitació de Recursos via PAM:** Utilitzem `limits.conf` per garantir un `hard limit` en el nombre màxim de processos i fitxers oberts (nproc, nofile) de manera transversal a l'equip.

## 5. Storage & Backup Architecture (Week 5)

* **Disk Setup & FSTAB:** Hem introduït un segon disc virtual (`/dev/sdb`) particionat amb `ext4`. El muntatge a `/mnt/storage` es fa persistent via `/etc/fstab`.
* **Backup Strategy:** Utilitzem "Daily Incremental, Weekly Full" optimitzada per *hard-links* via `rsync`.
  * **RPO (Recovery Point Objective):** 24 hores.
  * **RTO (Recovery Time Objective):** Menys de 15 minuts.
* **Network Storage (NFS):** Hem instal·lat `nfs-kernel-server` per compartir `/mnt/storage/nfs_shared` a tota la xarxa local.

## 6. Future Planning (Scaling the System)

* **Scaling to 20 people:** L'arquitectura actual suporta 20 usuaris, però la creació manual de comptes (script `11-setup-team.sh`) es tornaria feixuga. Introduiríem eines de gestió de configuració com **Ansible** per automatitzar l'aprovisionament d'usuaris.
* **Scaling to 100 people:** El servidor local es col·lapsaria. Caldria migrar l'emmagatzematge a un NAS dedicat o al núvol (AWS S3), separar Nginx a servidors de balanceig de càrrega, i centralitzar l'autenticació utilitzant un servidor **LDAP** o **Active Directory** perquè els usuaris tinguin *Single Sign-On*.