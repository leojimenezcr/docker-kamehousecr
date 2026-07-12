# nextcloud

## Qué hace
Nube personal (Nextcloud + MariaDB + Redis).

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| nextcloud | — | — (sin puerto de host, expuesto vía `proxy`) |
| nextclouddb (mariadb) | — | — |
| nextcloudredis | — | — |

## Volúmenes
`BASE_DIR` es la carpeta raíz de este stack en el host.

| Ruta | Monta en | Descripción |
|---|---|---|
| `${BASE_DIR}/nextclouddata` | `/var/www/html` (nextcloud) | Datos de la app |
| `${BASE_DIR}/nextclouddb` | `/var/lib/mysql` (nextclouddb) | Datos de MariaDB |

## Depende de
`nextcloud` depende internamente de `nextclouddb` y `nextcloudredis` (mismo
stack). Depende del stack `proxy` para exponerse hacia afuera vía la red
`nextcloud-net`, que este stack crea y que `proxy/docker-compose.yml`
consume como `external: true` (versionada, sin pasos manuales en la UI).

## Nombre del stack en Portainer
`nextcloud` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Este stack usa `env_file: ../../stack.env` — ver aviso crítico en
`../../docs/PORTAINER-SETUP.md` sobre la ruta relativa de ese archivo tras la
reorganización. Ver también `.env.example` en esta carpeta.

## Notas
`Dockerfile` en esta carpeta no está referenciado por `build:` en el
compose (usa `image: nextcloud:latest` directo) — se preserva tal cual, sin
tocar.
