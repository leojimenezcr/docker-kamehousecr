# Arquitectura del homelab — docker-kamehousecr

Cada carpeta bajo `stacks/` (y `proxy/` como excepción, top-level) es un
`docker-compose.yml` desplegado por Portainer vía GitOps: Portainer apunta a
un branch de este repo + un "Compose path" relativo. Las variables de
entorno de cada stack se cargan normalmente en la UI de Portainer, no vía
`.env` commiteado. Los `.env.example` de cada stack son documentación de
referencia — no los lee Portainer automáticamente.

## Mapa de servicios

| Servicio | Puerto host:contenedor | Dominio/subdominio | Depende de (otro stack) | Notas |
|---|---|---|---|---|
| applio | 6969:6969 | PENDIENTE | — | Build local sin usar (`dockerfile` no referenciado por el compose) |
| coqui (coqui-tts) | 5002:5002 | PENDIENTE | — | Red `coqui-net` declarada, no usada |
| duplicati | 8200:8200 | PENDIENTE | — | ⚠ monta `$HOME` completo del host como `/source` |
| immich-server | 2283:2283 | PENDIENTE | database, redis (internos al stack) | — |
| immich-machine-learning | sin puerto host | — | database, redis | — |
| isp-monitor / blackbox-exporter | 9115:9115 | PENDIENTE | — | `prometheus.yml` con IPs de ISP hardcodeadas, fuera de alcance de esta reorg |
| isp-monitor / prometheus | 9090:9090 | PENDIENTE | blackbox-exporter (scrape) | — |
| isp-monitor / grafana | 3000:3000 | PENDIENTE | prometheus (datasource) | — |
| jellyfin | 8096:8096 | PENDIENTE | — | — |
| jellyfin / sonarr | 8989:8989 | PENDIENTE | transmission (embebido) | — |
| jellyfin / radarr | 7878:7878 | PENDIENTE | transmission (embebido) | — |
| jellyfin / bazarr | 6767:6767 | PENDIENTE | sonarr, radarr | — |
| jellyfin / jellyseerr | 5055:5055 | PENDIENTE | radarr, sonarr | — |
| jellyfin / jackett | 9117:9117 | PENDIENTE | — | — |
| jellyfin / transmission (embebido) | 9091:9091, 51413:51413(+udp) | PENDIENTE | — | ⚠ CONFLICTO: duplica el stack standalone `Transmission` |
| jellyfin / tinymediamanager | 4000:4000 | PENDIENTE | — | — |
| navidrome | 4533:4533 | PENDIENTE | — | — |
| Nextcloud / nextcloud | sin puerto host | PENDIENTE | nextclouddb, nextcloudredis | Expuesto vía `proxy` (red no versionada) |
| Nextcloud / nextclouddb (mariadb) | sin puerto host | — | — | — |
| Nextcloud / nextcloudredis | sin puerto host | — | — | — |
| ollama | 11434:11434 | PENDIENTE | — | — |
| ollama / open-webui | 8080:8080 | PENDIENTE | ollama | ⚠ CONFLICTO: mismo puerto host que `rasa-faq-demo / webchat` |
| piper | 10200:10200 | PENDIENTE | — | Red `piper-net` declarada, no usada |
| Portainer | 8000:8000, 9443:9443 | PENDIENTE | — | Dueño de la red externa `portainer_portainer-net` que consume `proxy` |
| proxy (swag) | 80:80, 443:443 | PENDIENTE | Portainer (consume su red externa) | Único servicio con `networks.external: true`; redes de otros stacks se agregan manualmente vía Portainer UI (no versionado) |
| rasa-faq-demo / rasa | sin puerto host (5005 comentado) | — | — | — |
| rasa-faq-demo / webchat | 8080:80 | PENDIENTE | rasa | ⚠ CONFLICTO: mismo puerto host que `ollama / open-webui` |
| Transmission (standalone) | sin puertos activos (comentados) | — | — | ⚠ CONFLICTO: duplica el `transmission` embebido en `jellyfin` (mismo `container_name`) |
| watchtower | sin puertos | — | — | Monitorea todos los contenedores con label `com.centurylinklabs.watchtower.enable=true` |

## Dominios / subdominios

Marcado `PENDIENTE` para todos los servicios: no hay ningún
`nginx.conf`/`conf.d` versionado en el repo del que inferir dominios. La
configuración real de SWAG vive en un bind mount fuera de git
(`/home/leojimenezcr/proxy`, ver `../proxy/README.md`). Completar esta
columna a mano una vez migrada esa configuración al repo.

## Redes Docker relevantes

- `portainer_portainer-net`: red externa creada por el stack `Portainer`,
  consumida explícitamente solo por `proxy`. Las demás redes que `proxy`
  necesita para llegar a cada app se agregan manualmente en la UI de
  Portainer — no están versionadas en ningún compose de este repo.
- Redes declaradas pero no usadas por ningún servicio (dejadas tal cual, no
  tocadas en esta reorganización): `coqui-net`, `immichapp-net`, `piper-net`.

## Conflictos y pendientes conocidos (NO resueltos en esta reorganización)

Confirmado explícitamente con el usuario que estos dos puntos quedan fuera
de alcance — solo se documentan:

1. **Duplicación de Transmission**: el stack standalone `stacks/Transmission`
   (`container_name: transmission`, PGID=1001, puertos deshabilitados)
   coexiste con el servicio `transmission` embebido en `stacks/jellyfin`
   (`container_name: transmission`, PGID=1000, puertos 9091/51413 activos).
   Mismo `container_name` → riesgo de colisión si ambos stacks corren a la
   vez. Requiere decisión del usuario sobre cuál es el "real".
2. **Choque de puerto de host 8080**: `ollama/open-webui` (8080:8080) y
   `rasa-faq-demo/webchat` (8080:80) publican el mismo puerto de host. Si
   ambos stacks están activos simultáneamente en el mismo host, uno de los
   dos fallará al bindear el puerto. Requiere decisión del usuario.
3. **`duplicati` monta el `$HOME` completo** del usuario como `/source` —
   superficie de respaldo amplia. Se preserva la funcionalidad actual tal
   cual, solo se documenta.
4. **Nombres de variable genéricos `USER`/`PASS`** en `Transmission` —
   riesgo de colisión con variables de entorno del shell/sistema. No se
   renombran (fuera de alcance funcional).

## Sobre `stack.env`

`immich-app`, `jellyfin` y `Nextcloud` usan `env_file` apuntando a un
`stack.env` que Portainer genera en la raíz del clon del repositorio (nunca
commiteado). Ver `docs/PORTAINER-SETUP.md` para el detalle de la corrección
de ruta relativa que requirió esta reorganización.
