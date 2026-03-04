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