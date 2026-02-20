# Operations Runbook

Aquest document detalla les tasques comunes i els procediments d'administració per a l'equip d'operacions de Greendevcorp.

## 1. Common Tasks

### How to access the system (Accés Remot)
Per accedir al servidor (Debian VM) de forma remota des de l'ordinador host, cal utilitzar SSH. Prèviament, s'ha de configurar una regla de *Port Forwarding* a VirtualBox que redirigeixi el port 2222 del host al port 22 (SSH) del convidat.
* **Comanda de connexió per defecte:** `ssh -p 2222 gsx@127.0.0.1`

*(Nota: En les properes setmanes s'afegiran aquí procediments de creació d'usuaris, gestió de serveis i resolució de problemes de rendiment).*