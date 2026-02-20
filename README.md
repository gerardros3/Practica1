# GSX - Pràctica: Foundational Server Administration
**Equip:** Miquel Garcia i Gerard Ros

Aquest repositori conté la infraestructura com a codi (IaC) i la documentació per a la configuració, administració i manteniment del servidor de la startup Greendevcorp.

## Estructura del Repositori
* `scripts/`: Scripts bash automatitzats i idempotents per a l'aprovisionament de la màquina (paquets, directoris, verificació i backups).
* `docs/`: Documentació completa del sistema:
  * [Operations Runbook](docs/runbook.md): Manual de procediments, operacions comunes i troubleshooting.
  * [System Architecture](docs/architecture.md): Decisions de disseny, seguretat i justificació de l'arquitectura.
  * [Reflexions](docs/reflections.md): Reflexions sobre el treball realitzat.

## Com utilitzar aquest repositori per primer cop
1. Connecteu-vos a la màquina virtual Debian fresca.
2. Cloneu aquest repositori.
3. Navegueu a la carpeta `scripts/`.
4. Doneu permisos d'execució als arxius (`chmod +x *.sh`).
5. Executeu els scripts d'instal·lació de forma seqüencial amb privilegis d'administrador (`sudo`).