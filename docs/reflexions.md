# Reflection: Infrastructure Automation (Week 1)

## Què hem après sobre l'automatització d'infraestructura?

Durant aquesta primera setmana hem passat de veure l'administració de sistemes com un procés manual basat en teclejar comandes, a entendre-la com a **Infraestructura com a Codi (IaC)**. 

El concepte més important ha estat la **idempotència**. Fins ara, pensàvem en els scripts com a simples eines d'instal·lació ("fes això i després allò"). Ara hem après a dissenyar-los perquè defineixin l'estat desitjat del sistema. Ens hem adonat de la tranquil·litat que dona saber que podem executar el mateix script (`02-directories.sh` o `03-verify.sh`) desenes de vegades consecutives sense duplicar carpetes, sense trencar dependències i deixant que l'script s'auto-repari si detecta anomalies.

També hem après a ser proactius amb els riscos de l'automatització. L'ús de mecanismes de bloqueig (com els *lockfiles* al nostre script inicial) ens ha ensenyat que a la vida real, els servidors són entorns multi-usuari on la concurrència no planificada pot corrompre dades crítiques.

En resum, hem après que automatitzar no és només anar més ràpid, sinó fer que la infraestructura sigui **predictible, segura, escalable i documentable** a través d'un repositori de control de versions.