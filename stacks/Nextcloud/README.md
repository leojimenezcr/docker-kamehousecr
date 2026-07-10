# Nextcloud

## Qué hace
Nube personal (Nextcloud + MariaDB + Redis).

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| nextcloud | — | — (sin puerto de host, expuesto vía Proxy) |
| nextclouddb (mariadb) | — | — |
| nextcloudredis | — | — |

## Volúmenes
| Variable | Monta en | Descripción |
|---|---|---|
| `NEXTCLOUD_DATA_DIR` | `/var/www/html` (nextcloud) | Datos de la app |
| `NEXTCLOUD_DB_DIR` | `/var/lib/mysql` (nextclouddb) | Datos de MariaDB |

## Depende de
`nextcloud` depende internamente de `nextclouddb` y `nextcloudredis` (mismo
stack). Depende del stack `proxy` para exponerse hacia afuera (la red que
conecta ambos se agrega manualmente vía Portainer UI, no está versionada).

## Nombre del stack en Portainer
`Nextcloud` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Este stack usa `env_file: ../../stack.env` — ver aviso crítico en
`../../docs/PORTAINER-SETUP.md` sobre la ruta relativa de ese archivo tras la
reorganización. Ver también `.env.example` en esta carpeta.

## Notas
`Dockerfile` en esta carpeta no está referenciado por `build:` en el
compose (usa `image: nextcloud:latest` directo) — se preserva tal cual, sin
tocar.
