# n8n

## Qué hace
Editor/motor de automatizaciones n8n (community), con un contenedor propio
de Postgres (`postgres`) como base de datos en vez del sqlite por defecto.

## Puertos
Ninguno expuesto al host — a diferencia del compose oficial (que publica
`5678:5678`), acá n8n sale únicamente vía el stack `proxy`, igual que
`nextcloud` o `grafana`/`prometheus` (isp-monitor).

## Volúmenes
| Variable | Monta en | Descripción |
|---|---|---|
| `BASE_DIR` (`/n8n`) | `/home/node/.n8n` | Datos de n8n: workflows, credenciales cifradas, config |
| `BASE_DIR` (`/postgres`) | `/var/lib/postgresql/data` | Datos de la base de datos Postgres de n8n |

## Depende de
- `proxy` para salir a internet — requiere que `n8nkamehousecr.ddns.net`
  esté en `EXTRA_DOMAINS` del stack `proxy` (ver más abajo).

## Dominio
Dominio propio (`n8nkamehousecr.ddns.net`), no subcarpeta: la doc oficial
de n8n no confirma soporte de subpath. Requiere el hostname registrado en
noip.com apuntando a la misma IP pública, agregado a `EXTRA_DOMAINS` en las
variables del stack `proxy` (ver `../../proxy/.env.example`) — comparte el
mismo certificado Let's Encrypt que el dominio base.

## Primer login
n8n ya no usa basic auth: el primer acceso a
`https://n8nkamehousecr.ddns.net/` pide crear la cuenta *owner* desde la
propia UI.

## Migrar un despliegue existente de sqlite a Postgres
Si este stack ya corría con el sqlite por defecto (sin `DB_TYPE` en el
compose), pasar a Postgres arranca una base nueva y vacía — n8n no migra
datos automáticamente entre motores. Antes de redesplegar con este cambio,
exportar los workflows/credenciales existentes desde la UI (o respaldar
`${BASE_DIR}/n8n/database.sqlite`) y volver a importarlos ya con Postgres
activo.

## Nombre del stack en Portainer
`n8n` — fijado explícito con `name: n8n` en el compose (no depende del
nombre de carpeta que le dé Portainer), igual que hace `immich-app`.

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`.
