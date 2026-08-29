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
| isp-monitor / blackbox-exporter | sin puerto host | — | — | Solo consumido internamente por `prometheus` vía `isp-monitor-internal-net`; `prometheus.yml` con IPs de ISP hardcodeadas, fuera de alcance de esta reorg |
| isp-monitor / prometheus | sin puerto host | `kamehousecr.ddns.net/prometheus/` | blackbox-exporter (scrape) | Expuesto vía `proxy` (red `isp-monitor-net`, `external: true`); subpath vía `--web.external-url`/`--web.route-prefix` |
| isp-monitor / grafana | sin puerto host | `kamehousecr.ddns.net/grafana/` | prometheus (datasource) | Expuesto vía `proxy` (red `isp-monitor-net`, `external: true`); subpath vía `GF_SERVER_ROOT_URL`/`GF_SERVER_SERVE_FROM_SUB_PATH` |
| jellyfin | 8096:8096 | `kamehousecr.ddns.net/jellyfin/` | — | — |
| jellyfin / sonarr | 8989:8989 | PENDIENTE | transmission (embebido) | — |
| jellyfin / radarr | 7878:7878 | PENDIENTE | transmission (embebido) | — |
| jellyfin / bazarr | 6767:6767 | PENDIENTE | sonarr, radarr | — |
| jellyfin / jellyseerr | 5055:5055 | PENDIENTE | radarr, sonarr | — |
| jellyfin / jackett | 9117:9117 | PENDIENTE | — | — |
| jellyfin / transmission (embebido) | 9091:9091, 51413:51413(+udp) | `kamehousecr.ddns.net/transmission` | — | — |
| jellyfin / tinymediamanager | 4000:4000 | PENDIENTE | — | — |
| juegos | sin puerto host | `kamehousecr.ddns.net/juegos/` | — | Sitio estático (arcade "Reto de Ciberseguridad", proyecto `juegoscyberseguridad`, repo aparte no versionado acá); nginx sirve `BASE_DIR` tal cual como raíz. Expuesto vía `proxy` (red `juegos-net`, versionada como `external: true`); método de subcarpeta porque el sitio solo usa rutas relativas |
| n8n / n8n | sin puerto host | `n8nkamehousecr.ddns.net` (dominio propio) | sandbox-api (AI Assistant) | Expuesto vía `proxy` (red `n8n-net`, versionada como `external: true`); dominio propio en vez de subcarpeta porque la doc oficial de n8n no confirma soporte de subpath. AI Assistant apunta al modelo local de `ollama` (red `ollama_ollama-net`, consumida desde este stack) |
| n8n / sandbox-certs | sin puerto host | — | — | Init container, corre una vez y termina; genera certificados mTLS del sandbox |
| n8n / sandbox-api | sin puerto host | — | sandbox-certs | Control plane del sandbox de ejecución de código del AI Assistant; sin watchtower ni `env_file` completo (componente sensible) |
| n8n / sandbox-runner-1 | sin puerto host | — | sandbox-api | `privileged: true` (Docker-in-Docker); sin watchtower, actualización manual |
| n8n / searxng | sin puerto host | — | — | Backend de búsqueda web del AI Assistant |
| navidrome | 4533:4533 | `kamehousecr.ddns.net/navidrome/` | — | — |
| nextcloud | sin puerto host | `kamehousecr.ddns.net/` (location raíz) | nextclouddb, nextcloudredis | Expuesto vía `proxy` (red `nextcloud-net`, versionada como `external: true` en `proxy/docker-compose.yml`) |
| nextcloud / nextclouddb (mariadb) | sin puerto host | — | — | — |
| nextcloud / nextcloudredis | sin puerto host | — | — | — |
| ollama | sin puerto host | — (interno, no expuesto vía proxy) | — | Servidor de modelos LLM locales; solo lo consume `n8n` (AI Assistant) vía `ollama-net`. Inferencia por CPU (host sin GPU dedicada) |
| portainer | 8000:8000, 9443:9443 | `kamehousecr.ddns.net/portainer/` | — | Dueño de la red externa `portainer_portainer-net` que consume `proxy` |
| proxy (swag) | 80:80, 443:443 | `kamehousecr.ddns.net` + `photoskamehousecr.ddns.net` + `n8nkamehousecr.ddns.net` (`EXTRA_DOMAINS`, mismo cert) | portainer, nextcloud, navidrome, jellyfin, immich-app, isp-monitor, n8n, juegos (consume la red externa de cada uno) | Único servicio con `networks.external: true`, hacia 8 redes versionadas (ver sección de redes abajo) |
| watchtower | sin puertos | — | — | Monitorea todos los contenedores con label `com.centurylinklabs.watchtower.enable=true` |

## Dominios / subdominios

`proxy/conf.d/default.conf` es ahora un snapshot versionado real del
`default.conf` que corre en el servidor — de ahí salen los dominios
confirmados de la tabla de arriba: el dominio base `kamehousecr.ddns.net`
(método de subcarpeta vía `location` blocks: portainer, jellyfin,
navidrome, nextcloud, transmission, grafana, prometheus, juegos),
`photoskamehousecr.ddns.net` (server block propio en el mismo archivo, para
`immich-app`) y `n8nkamehousecr.ddns.net` (server block propio, para
`n8n`). El resto de servicios sigue `PENDIENTE` porque no aparecen en ese
archivo (no se exponen públicamente vía este proxy, o su exposición vive
en otro lado no versionado todavía). Ver `../proxy/README.md` para el
detalle de qué tan al día está ese snapshot respecto al contenedor real.

`photoskamehousecr.ddns.net` y `n8nkamehousecr.ddns.net` son dominios DDNS
separados (no subdominios reales de `kamehousecr.ddns.net` — el plan
gratuito de noip.com no permite subdominios), apuntando a la misma IP
pública. Se eligió dominio propio en vez de subcarpeta en ambos casos
porque ninguno de los dos servicios soporta bien reverse proxy bajo un
subpath: Immich asume rutas de API/websocket en la raíz (ver
`immich-app/immich#23688`), y la doc oficial de n8n no confirma soporte de
subpath/subcarpeta. Ambos comparten el mismo certificado Let's Encrypt que
el dominio base vía `EXTRA_DOMAINS` en `proxy/docker-compose.yml`.

## Redes Docker relevantes

- `proxy` consume 8 redes externas, cada una creada por su stack dueño y
  declarada como `external: true` en `proxy/docker-compose.yml`:
  `portainer_portainer-net` (dueño: `portainer`), `nextcloud_nextcloud-net`
  (dueño: `nextcloud`), `navidrome_navidrome-net` (dueño: `navidrome`),
  `jellyfin_jellyfin-net` (dueño: `jellyfin`), `immich_immichapp-net`
  (dueño: `immich-app`), `isp-monitor_isp-monitor-net` (dueño:
  `isp-monitor`, solo la usan `grafana` y `prometheus` — `blackbox-exporter`
  queda fuera), `n8n_n8n-net` (dueño: `n8n`) y `juegos_juegos-net` (dueño:
  `juegos`). Al ser `external`, Compose reconecta el contenedor `proxy` a
  las 8 automáticamente en cada redeploy del stack `proxy` — ya no hace
  falta unirlas a mano vía la UI de Portainer (así era antes; ver historial
  de este archivo).
- Aparte, `n8n` consume a su vez `ollama_ollama-net` (dueño: `ollama`) para
  llegar al AI Assistant al modelo local — esa red **no** la toca `proxy`,
  es privada entre esos dos stacks (`ollama` nunca se expone públicamente).
- **Orden de despliegue inicial**: `immich_immichapp-net`,
  `isp-monitor_isp-monitor-net`, `n8n_n8n-net` y `juegos_juegos-net` solo
  existen después de que `immich-app`, `isp-monitor`, `n8n` y `juegos`
  respectivamente se despliegan con sus servicios unidos a esas redes. Si
  se redespliega `proxy` antes de eso, el deploy falla porque Compose no
  encuentra la red externa — desplegar siempre el stack dueño primero. A su
  vez, `n8n` necesita que `ollama` ya esté desplegado (para
  `ollama_ollama-net`) antes de desplegarse él mismo.

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

`immich-app`, `jellyfin`, `nextcloud` y `n8n` (solo su servicio `n8n`) usan
`env_file` apuntando a un
`stack.env` que Portainer genera en la raíz del clon del repositorio (nunca
versionado en git). Ver `docs/PORTAINER-SETUP.md` para el detalle de cómo
funciona ese mecanismo y qué hacer si se vuelve a mover alguno de esos
`docker-compose.yml`.
