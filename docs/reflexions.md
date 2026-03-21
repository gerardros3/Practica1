# Reflection: Infrastructure Automation (Week 1)

## Què hem après sobre l'automatització d'infraestructura?

Durant aquesta primera setmana hem passat de veure l'administració de sistemes com un procés manual basat en teclejar comandes, a entendre-la com a **Infraestructura com a Codi (IaC)**. 

El concepte més important ha estat la **idempotència**. Fins ara, pensàvem en els scripts com a simples eines d'instal·lació ("fes això i després allò"). Ara hem après a dissenyar-los perquè defineixin l'estat desitjat del sistema. Ens hem adonat de la tranquil·litat que dona saber que podem executar el mateix script (`02-directories.sh` o `03-verify.sh`) desenes de vegades consecutives sense duplicar carpetes, sense trencar dependències i deixant que l'script s'auto-repari si detecta anomalies.

També hem après a ser proactius amb els riscos de l'automatització. L'ús de mecanismes de bloqueig (com els *lockfiles* al nostre script inicial) ens ha ensenyat que a la vida real, els servidors són entorns multi-usuari on la concurrència no planificada pot corrompre dades crítiques.

En resum, hem après que automatitzar no és només anar més ràpid, sinó fer que la infraestructura sigui **predictible, segura, escalable i documentable** a través d'un repositori de control de versions.

# Reflection: Services & Observability (Week 2)

Aquesta setmana hem convertit scripts aïllats en una infraestructura gestionada de veritat gràcies a Linux i systemd.

**Com expliquem una fallada a l'equip utilitzant només logs?**
La clau de l'observabilitat és que elimina les "suposicions". Si algú diu "ahir a la nit no anava la web", podem fer `journalctl -u nginx --since "yesterday"`. Allà veurem la marca de temps exacta on el procés va morir (ex: rebent un senyal `SIGKILL`) i, tot seguit, la línia on `systemd` el va tornar a aixecar gràcies a la nostra configuració. Mostrant aquestes dues línies a l'equip, es demostra no només per què va fallar, sinó com l'automatització ens va salvar d'una incidència greu.

**Com provem que un servei es reinicia sol?**
No podem esperar que falli. Com a Sysadmins, simulem el caos: executem un `sudo pkill -9 nginx` i comprovem immediatament amb `systemctl status nginx` si l'estat indica que ha estat reiniciat recentment. Aquesta prova empírica és l'única manera de validar la infraestructura com a codi.

**I si els backups fallen silenciosament? Com ens n'adonem?**
Amb la nostra nova arquitectura, els errors "silenciosos" deixen d'existir. Si el script de backup falla (per falta d'espai al disc o error amb el xifratge GPG), el servei de `systemd` capturarà el codi de sortida d'error (Exit Code != 0) i ho registrarà automàticament al `journald`. Les mètriques clau que ens importen per auditar l'èxit són el propi Exit Code de l'execució i la mida de l'arxiu `.gpg` resultant. Ho podem monitoritzar ràpidament de forma proactiva amb `journalctl -u backup.service`.

# Reflection: Process Management & Resource Control (Week 3)

**SIGTERM vs SIGKILL: When to use each?**
`SIGTERM` (15) is a polite request to terminate. It can be caught by the application (using a `trap` in bash) allowing it to finish saving data, close database connections, and delete temporary files before exiting. `SIGKILL` (9) is a brutal forced stop executed directly by the kernel. The application cannot intercept it. We only use `SIGKILL` as a last resort if a process is completely frozen and ignoring `SIGTERM`, because it can lead to data corruption.

**How should a service respond to a signal?**
If a service receives `SIGINT` (Ctrl+C) or `SIGTERM`, it should trigger a cleanup function. Yes, it must save its current state, close file descriptors, and cleanly terminate its child processes (like our workload script does with the `yes` background jobs) to prevent creating "orphan" processes.

**How do you verify a resource limit is working?**
By applying the Scientific Method: Create a workload that intentionally consumes 100% of a resource (like running `yes > /dev/null &` loops). First, run it without limits and verify via `top` that it consumes 100% CPU. Then, place it in a systemd service with `CPUQuota=20%` (cgroups). Check `top` again; if the process is hard-capped at 20.0%, the limit is mathematically proven to work.

**If a developer's job uses 90% CPU, is that a problem?**
It depends on the *context*. If the server is a dedicated Batch-Processing node rendering a 3D video, 90% CPU means it's working efficiently. However, if it's a shared Web Server or a Database node, 90% CPU is a massive problem because it will cause latency and timeouts for incoming user requests. To prevent this, we use `cgroups` or the `nice`/`renice` commands to lower the job's priority so it only uses "leftover" CPU cycles.

# Reflection: Team Collaboration & Security (Week 4)

**If a file is in a shared directory and owned by 'dev1', but needs to be readable by all team members, what permissions would you set? Why?**
Hem d'establir permisos de lectura i escriptura (o només lectura, depenent de l'ús) al grup associat a la carpeta, i assegurar-nos que el grup propietari del fitxer sigui `greendevcorp`. Això s'aconsegueix amb `chmod 640` o `644`. Per què? Perquè amb el primer dígit controlem al propietari i amb el segon als companys de l'equip. Evitem `777` per tal de no exposar les dades a usuaris externs.

**What's the difference between setgid on a directory vs. a file? Why would you use each?**
Quan apliques el **setgid a un directori**, qualsevol fitxer o subdirectori que es creï a dins heretarà el grup del directori pare en comptes del grup principal de l'usuari que el crea. És vital per a carpetes compartides (`/home/greendevcorp/shared`) per assegurar la col·laboració.
Quan s'aplica a un **fitxer executable**, el programa s'executarà amb els privilegis del grup propietari del fitxer, no amb el grup de l'usuari que l'invoca (útil per a programes que necessiten accés a fitxers determinats, però amb menys risc que *setuid*).

**How would you verify that your permission model actually enforces the security policy you intended?**
De la mateixa manera que testejàvem els límits de recursos: **Simulant accessos**. Creant un *Security Verification Script* on fem crides simulades via `sudo -u dev2 touch ...` o `sudo -u dev3 rm ...`. Si el comportament d'escriptura o d'esborrat (restringit per l'Sticky Bit) llança un codi d'error a bash (Exit Code != 0), confirmem empíricament que el model està funcionant de manera correcta.
