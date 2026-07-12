# Arquitectura del homelab — docker-kamehousecr

Cada carpeta bajo `stacks/` (y `proxy/` como excepción, top-level) es un
`docker-compose.yml` desplegado por Portainer vía GitOps: Portainer apunta a
un branch de este repo + un "Compose path" relativo. Las variables de
entorno de cada stack se cargan normalmente en la UI de Portainer, no vía
`.env` versionado en git. Los `.env.example` de cada stack son documentación de
referencia — no los lee Portainer automáticamente.

## Mapa de servicios

| Servicio | Puerto host:contenedor | Dominio/subdominio | Depende de (otro stack) | Notas |
|---|---|---|---|---|
| duplicati | 8200:8200 | PENDIENTE | — | ⚠ monta `$HOME` completo del host como `/source`; versionado en el repo pero **no desplegado actualmente** (no existe como stack en Portainer) |
| immich-server | sin puerto host | `photoskamehousecr.ddns.net` (dominio propio) | database, redis (internos al stack) | Expuesto vía `proxy` (red `immichapp-net`, versionada como `external: true`); dominio propio en vez de subcarpeta porque Immich no soporta bien reverse proxy con subpath |
| immich-machine-learning | sin puerto host | — | database, redis | — |
| isp-monitor / blackbox-exporter | 9115:9115 | PENDIENTE | — | `prometheus.yml` con IPs de ISP hardcodeadas, fuera de alcance de esta reorg |
| isp-monitor / prometheus | 9090:9090 | PENDIENTE | blackbox-exporter (scrape) | — |
| isp-monitor / grafana | 3000:3000 | PENDIENTE | prometheus (datasource) | — |
| jellyfin | 8096:8096 | `kamehousecr.ddns.net/jellyfin/` | — | — |
| jellyfin / sonarr | 8989:8989 | PENDIENTE | transmission (embebido) | — |
| jellyfin / radarr | 7878:7878 | PENDIENTE | transmission (embebido) | — |
| jellyfin / bazarr | 6767:6767 | PENDIENTE | sonarr, radarr | — |
| jellyfin / jellyseerr | 5055:5055 | PENDIENTE | radarr, sonarr | — |
| jellyfin / jackett | 9117:9117 | PENDIENTE | — | — |
| jellyfin / transmission (embebido) | 9091:9091, 51413:51413(+udp) | `kamehousecr.ddns.net/transmission` | — | — |
| jellyfin / tinymediamanager | 4000:4000 | PENDIENTE | — | — |
| navidrome | 4533:4533 | `kamehousecr.ddns.net/navidrome/` | — | — |
| nextcloud | sin puerto host | `kamehousecr.ddns.net/` (location raíz) | nextclouddb, nextcloudredis | Expuesto vía `proxy` (red `nextcloud-net`, versionada como `external: true` en `proxy/docker-compose.yml`) |
| nextcloud / nextclouddb (mariadb) | sin puerto host | — | — | — |
| nextcloud / nextcloudredis | sin puerto host | — | — | — |
| portainer | 8000:8000, 9443:9443 | `kamehousecr.ddns.net/portainer/` | — | Dueño de la red externa `portainer_portainer-net` que consume `proxy` |
| proxy (swag) | 80:80, 443:443 | `kamehousecr.ddns.net` + `photoskamehousecr.ddns.net` (`EXTRA_DOMAINS`, mismo cert) | portainer, nextcloud, navidrome, jellyfin, immich-app (consume la red externa de cada uno) | Único servicio con `networks.external: true`, hacia 5 redes versionadas (ver sección de redes abajo) |
| watchtower | sin puertos | — | — | Monitorea todos los contenedores con label `com.centurylinklabs.watchtower.enable=true` |

## Dominios / subdominios

`proxy/conf.d/default.conf` es ahora un snapshot versionado real del
`default.conf` que corre en el servidor — de ahí salen los dominios
confirmados de la tabla de arriba: el dominio base `kamehousecr.ddns.net`
(método de subcarpeta vía `location` blocks: portainer, jellyfin,
navidrome, nextcloud, transmission) y `photoskamehousecr.ddns.net` (server
block propio en el mismo archivo, para `immich-app`). El resto de
servicios sigue `PENDIENTE` porque no aparecen en ese archivo (no se
exponen públicamente vía este proxy, o su exposición vive en otro lado no
versionado todavía). Ver `../proxy/README.md` para el detalle de qué tan
al día está ese snapshot respecto al contenedor real.

`photoskamehousecr.ddns.net` es un dominio DDNS separado (no un subdominio
real de `kamehousecr.ddns.net` — el plan gratuito de noip.com no permite
subdominios), apuntando a la misma IP pública. Se eligió dominio propio en
vez de subcarpeta (`/immich`) porque Immich no soporta bien reverse proxy
bajo un subpath: rutas de API/websocket asumen que corren en la raíz (ver
`immich-app/immich#23688`). Comparte el mismo certificado Let's Encrypt
que el dominio base vía `EXTRA_DOMAINS` en `proxy/docker-compose.yml`.

## Redes Docker relevantes

- `proxy` consume 5 redes externas, cada una creada por su stack dueño y
  declarada como `external: true` en `proxy/docker-compose.yml`:
  `portainer_portainer-net` (dueño: `portainer`), `nextcloud_nextcloud-net`
  (dueño: `nextcloud`), `navidrome_navidrome-net` (dueño: `navidrome`),
  `jellyfin_jellyfin-net` (dueño: `jellyfin`) e `immich_immichapp-net`
  (dueño: `immich-app`). Al ser `external`, Compose reconecta el
  contenedor `proxy` a las 5 automáticamente en cada redeploy del stack
  `proxy` — ya no hace falta unirlas a mano vía la UI de Portainer (así
  era antes; ver historial de este archivo).
- **Orden de despliegue inicial**: `immich_immichapp-net` solo existe
  después de que `immich-app` se despliega con `immich-server` unido a
  `immichapp-net`. Si se redespliega `proxy` antes de eso, el deploy falla
  porque Compose no encuentra la red externa — desplegar siempre
  `immich-app` primero.

## Conflictos y pendientes conocidos

Los conflictos de duplicación de `transmission` (stack standalone vs.
embebido en `jellyfin`) y de choque de puerto 8080 (`ollama`/`rasa-faq-demo`)
documentados antes acá quedaron resueltos al eliminarse esos stacks
(`applio`, `coqui`, `ollama`, `piper`, `rasa-faq-demo`, `transmission`
standalone) por no usarse más. Queda un solo punto pendiente:

1. **`duplicati` monta el `$HOME` completo** del usuario como `/source` —
   superficie de respaldo amplia. Se preserva la funcionalidad tal cual,
   solo se documenta. Además, `duplicati` está versionado en el repo pero
   **no desplegado actualmente** (no existe como stack en Portainer) — se
   mantiene el código por si se vuelve a necesitar.

## Sobre `stack.env`

`immich-app`, `jellyfin` y `nextcloud` usan `env_file` apuntando a un
`stack.env` que Portainer genera en la raíz del clon del repositorio (nunca
versionado en git). Ver `docs/PORTAINER-SETUP.md` para el detalle de cómo
funciona ese mecanismo y qué hacer si se vuelve a mover alguno de esos
`docker-compose.yml`.
