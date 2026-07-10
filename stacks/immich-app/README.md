# immich-app

## Qué hace
Gestor de fotos/videos self-hosted (Immich). Compose oficial del proyecto:
`immich-server`, `immich-machine-learning`, `redis` y `database` (Postgres).

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| immich-server | 2283 | 2283 |
| immich-machine-learning | — | — (sin puerto de host) |
| redis | — | — |
| database | — | — |

## Volúmenes
| Variable | Monta en | Descripción |
|---|---|---|
| `UPLOAD_LOCATION` | `/usr/src/app/upload` (immich-server) | Fotos/videos subidos |
| `BASE_DIR` | `/cache` (ML), `/var/lib/postgresql/data` (database) | Cache de ML y datos de Postgres |

## Depende de
`immich-server` depende internamente de `redis` y `database` (mismo stack,
no cross-stack).

## Nombre del stack en Portainer
`immich-app` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Este stack usa `env_file: ../../stack.env` — ver aviso crítico en
`../../docs/PORTAINER-SETUP.md` sobre la ruta relativa de ese archivo tras la
reorganización. Ver también `.env.example` en esta carpeta.
