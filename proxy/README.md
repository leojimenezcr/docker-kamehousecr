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
Único servicio del repo con `networks.external: true` — consume 4 redes
creadas por sus stacks dueños: `portainer_portainer-net` (`stacks/portainer`),
`nextcloud_nextcloud-net` (`stacks/nextcloud`), `navidrome_navidrome-net`
(`stacks/navidrome`) y `jellyfin_jellyfin-net` (`stacks/jellyfin`). Al
declararlas como `external: true` en vez de unirlas a mano vía la UI de
Portainer, Compose las reconecta solas en cada redeploy del stack `proxy`
— no hace falta ningún paso manual después de recrearlo.

`immich-app` queda afuera de este mecanismo por ahora: su red
`immichapp-net` está declarada en su compose pero ningún servicio la usa,
por lo que nunca se creó en el host, y `immich-app` tampoco se expone hoy
vía este proxy (sigue `PENDIENTE`, ver `../docs/ARCHITECTURE.md`).

## Depende de
`stacks/portainer`, `stacks/nextcloud`, `stacks/navidrome` y
`stacks/jellyfin` (consume la red externa de cada uno).

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
deberá agregar un bind mount adicional montando `proxy/conf.d/default.conf`
(de este repo) sobre `/config/nginx/site-confs/default.conf` dentro del
contenedor — ruta confirmada contra el host real (`BASE_DIR` se monta
completo en `/config`, y el archivo real vive en
`${BASE_DIR}/nginx/site-confs/default.conf`) — **como bind mount
versionado de ese único archivo, no como volumen anónimo ni montando toda
la carpeta `nginx/`** (esa carpeta tiene mucho más contenido gestionado
por SWAG que no debe versionarse ni sobrescribirse).

Ver `scripts/sync-proxy-conf.sh` (en la raíz del repo) para el script que
sincroniza puntualmente `proxy/conf.d/default.conf` contra
`${BASE_DIR}/nginx/site-confs/default.conf` en el host — nunca el resto
del árbol de `${BASE_DIR}` (que incluye `dns-conf/`, `etc/letsencrypt/`,
`keys/` con certificados y claves privadas, `fail2ban/`, etc., todo
gestionado por SWAG y fuera del alcance de este repo).
