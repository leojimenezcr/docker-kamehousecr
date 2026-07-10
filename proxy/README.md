# proxy

## Qué hace
Reverse proxy + HTTPS con Let's Encrypt (imagen `linuxserver/swag`, no es
nginx plano — SWAG gestiona su propia configuración interna de nginx).
Único servicio del repo hacia afuera: todos los demás stacks salen a
internet a través de este proxy.

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| proxy | 80 | 80 |
| proxy | 443 | 443 |

## Volúmenes
| Ruta | Monta en | Descripción |
|---|---|---|
| `${BASE_DIR}` | `/config` | Config completa de SWAG (certificados, nginx interno, etc.) — se monta la carpeta raíz completa, sin subcarpeta, porque todo vive plano ahí |

## Redes
Único servicio del repo con `networks.external: true`, hacia
`portainer_portainer-net` (red creada por el stack `stacks/portainer`). Las
redes de los demás stacks (nextcloud, jellyfin, etc.) se agregan
manualmente a este contenedor vía la UI de Portainer — no están
versionadas en ningún `docker-compose.yml` de este repo.

## Depende de
`stacks/portainer` (consume su red externa `portainer_portainer-net`).

## Nombre del stack en Portainer
`Proxy` (asumido = nombre de carpeta original antes de esta reorganización,
verificar contra la UI real).

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../docs/PORTAINER-SETUP.md`.

## Sobre `nginx.conf` y `conf.d/` (placeholders, no conectados todavía)
`nginx.conf` y `conf.d/` en esta carpeta son **placeholders documentados**,
no contienen configuración real. La configuración real de SWAG (certificados,
site-confs, etc.) vive hoy en el bind mount del host (`BASE_DIR`,
actualmente `/home/leojimenezcr/proxy`), **fuera de este repo git**.

Migrar esa configuración real al repo es un paso posterior manual (por SSH
al servidor), fuera del alcance de esta reorganización — no se inventó
ningún server block ni se adivinó la ruta interna exacta que usa SWAG para
sus site-confs.

Cuando esa migración se haga, el `docker-compose.yml` de este stack deberá
agregar un bind mount adicional montando `proxy/conf.d/` (de este repo)
dentro del contenedor, en la ruta que corresponda según la convención de
SWAG — **como bind mount versionado, no como volumen anónimo**, para que la
configuración de nginx quede en git. Ese cambio no se hizo en esta
reorganización para evitar adivinar esa ruta interna.

Ver `scripts/sync-proxy-conf.sh` (en la raíz del repo) para el script que
sincroniza `proxy/conf.d/` contra el bind mount real del host una vez que
la migración esté hecha.
