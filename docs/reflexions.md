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