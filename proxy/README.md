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

## Sobre `nginx.conf` y `conf.d/`
`nginx.conf` sigue siendo un **placeholder documentado**, sin uso — SWAG
gestiona su propia config interna, no lo monta.

`conf.d/default.conf` en cambio **ya es real**: es un snapshot versionado
del `default.conf` que corre hoy en el servidor (copiado manualmente por el
usuario), con los `server`/`location` block reales de cada servicio
expuesto. Ver `conf.d/README.md` y `../docs/ARCHITECTURE.md` para el
detalle. Lo que falta todavía: `proxy/docker-compose.yml` **no monta
`conf.d/`** dentro del contenedor — SWAG en el servidor sigue leyendo su
propia copia desde el bind mount (`BASE_DIR`), así que este archivo es hoy
referencia/backup en git, no la fuente que usa el contenedor en vivo.

Cuando se quiera que sí lo sea, el `docker-compose.yml` de este stack
deberá agregar un bind mount adicional montando `proxy/conf.d/` (de este
repo) dentro del contenedor, en la ruta que corresponda según la
convención de SWAG — **como bind mount versionado, no como volumen
anónimo**. Ese cambio no se hizo todavía para evitar adivinar esa ruta
interna sin confirmarla primero.

Ver `scripts/sync-proxy-conf.sh` (en la raíz del repo) para el script que
sincroniza `proxy/conf.d/` contra el bind mount real del host.
