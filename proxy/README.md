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
Único servicio del repo con `networks.external: true` — consume 8 redes
creadas por sus stacks dueños: `portainer_portainer-net` (`stacks/portainer`),
`nextcloud_nextcloud-net` (`stacks/nextcloud`), `navidrome_navidrome-net`
(`stacks/navidrome`), `jellyfin_jellyfin-net` (`stacks/jellyfin`),
`immich_immichapp-net` (`stacks/immich-app`),
`isp-monitor_isp-monitor-net` (`stacks/isp-monitor`, solo la usan
`grafana` y `prometheus`), `n8n_n8n-net` (`stacks/n8n`) y
`juegos_juegos-net` (`stacks/juegos`). Al declararlas como
`external: true` en vez de unirlas a mano vía la UI de Portainer, Compose
las reconecta solas en cada redeploy del stack `proxy` — no hace falta
ningún paso manual después de recrearlo.

**Orden importante al desplegar por primera vez**: `immich_immichapp-net`,
`isp-monitor_isp-monitor-net`, `n8n_n8n-net` y `juegos_juegos-net` no
existen hasta que `immich-app`, `isp-monitor`, `n8n` y `juegos`
respectivamente se despliegan con sus servicios unidos a esas redes — si
se redespliega `proxy` antes de eso, el deploy falla porque Compose no
encuentra la red externa. Desplegar siempre el stack dueño primero.

## Depende de
`stacks/portainer`, `stacks/nextcloud`, `stacks/navidrome`,
`stacks/jellyfin`, `stacks/immich-app`, `stacks/isp-monitor`, `stacks/n8n`
y `stacks/juegos` (consume la red externa de cada uno).

## Dominios servidos
- `kamehousecr.ddns.net` (dominio base, `URL`): portainer, jellyfin,
  navidrome, nextcloud, transmission, grafana, prometheus, juegos — método
  de subcarpeta, ver `conf.d/default.conf`.
- `photoskamehousecr.ddns.net` (`EXTRA_DOMAINS`, mismo certificado, SAN
  adicional): immich-app, dominio propio en vez de subcarpeta porque
  Immich no soporta bien exponerse bajo un subpath (rutas de API/websocket
  asumen raíz — ver discusión `immich-app/immich#23688`) y el plan
  gratuito de noip.com no permite subdominios reales. Server block
  correspondiente en el mismo `conf.d/default.conf`.
- `n8nkamehousecr.ddns.net` (`EXTRA_DOMAINS`, mismo certificado, SAN
  adicional): stack `n8n`, mismo motivo que immich-app — la doc oficial de
  n8n no confirma soporte de subpath/subcarpeta. Server block
  correspondiente en el mismo `conf.d/default.conf`.

`blackbox-exporter` (parte de `isp-monitor`) no se expone vía proxy: su
página web usa links absolutos y no soporta bien un subpath, y no tiene
caso de uso público — solo lo consume `prometheus` internamente.

## Nombre del stack en Portainer
`Proxy` (verificar contra la UI real).

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../docs/PORTAINER-SETUP.md`.

## Sobre `nginx.conf` y `conf.d/`
`nginx.conf` es un **placeholder documentado**, sin uso — SWAG gestiona su
propia config interna, no lo monta.

`conf.d/default.conf` es un snapshot versionado del `default.conf` real del
servidor, con los `server`/`location` block de cada servicio expuesto (ver
`conf.d/README.md` y `../docs/ARCHITECTURE.md`). `proxy/docker-compose.yml`
**no lo monta** dentro del contenedor — SWAG sigue leyendo su propia copia
desde el bind mount de `BASE_DIR`, así que este archivo es referencia/backup
en git, no la fuente que usa el contenedor en vivo.

Para que sí lo sea, agregar un bind mount de `proxy/conf.d/default.conf`
sobre `/config/nginx/site-confs/default.conf` dentro del contenedor — como
archivo puntual, nunca montando toda la carpeta `nginx/` (tiene contenido
gestionado por SWAG que no debe versionarse ni sobrescribirse).

`scripts/sync-proxy-conf.sh` (raíz del repo) sincroniza puntualmente
`proxy/conf.d/default.conf` contra `${BASE_DIR}/nginx/site-confs/default.conf`
en el host — nunca el resto del árbol de `${BASE_DIR}` (`dns-conf/`,
`etc/letsencrypt/`, `keys/`, `fail2ban/`, etc., gestionado por SWAG).
