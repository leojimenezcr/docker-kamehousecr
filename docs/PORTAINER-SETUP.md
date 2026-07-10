# Configuración de stacks en Portainer (GitOps)

> **CRÍTICO — leer antes de aplicar el merge de `reorg/estructura-stacks`:**
> Los stacks `immich-app`, `jellyfin` y `Nextcloud` usan
> `env_file: ../../stack.env`. Ese `stack.env` es el archivo que Portainer
> genera automáticamente en la **raíz del clon del repositorio** a partir de
> las "Environment variables" cargadas en la UI de cada stack — nunca estuvo
> commiteado en este repo. Antes de esta reorganización, el compose de esos
> 3 stacks vivía en `<servicio>/docker-compose.yml` y usaba
> `env_file: ../stack.env` (un nivel arriba = raíz del repo). Ahora que el
> compose vive en `stacks/<servicio>/docker-compose.yml` (un nivel más
> adentro), la ruta relativa hacia la raíz del repo pasó a
> `../../stack.env` — **ya corregida en este branch**. El archivo
> `stack.env` en sí no se movió (sigue en la raíz del clon, fuera de git).
>
> **Después de repuntar el "Compose path" de cada uno de esos 3 stacks en
> Portainer, verificar explícitamente** que las apps siguen levantando con
> sus credenciales (login a Nextcloud/Immich, biblioteca de Jellyfin
> visible) antes de dar por cerrada la migración de cada stack. Si algo no
> carga, revisar primero esta ruta.

## Cómo actualizar cada stack en Portainer

Para cada stack: Portainer UI → Stacks → `<nombre>` → Editor → cambiar
**Compose path** a la ruta "NUEVO" de la tabla de abajo → agregar las
variables de entorno nuevas si corresponde → Update the stack. Las
"Environment variables" ya existentes en Portainer no se pierden al cambiar
el Compose path, pero hay que **agregar** las variables nuevas listadas
abajo antes del redeploy si todavía no existían.

## Tabla de stacks

| Stack en Portainer (asumido = nombre de carpeta, VERIFICAR contra la UI) | Compose path VIEJO | Compose path NUEVO | Variables a cargar/agregar en la UI (valor actual a preservar, cuando se conoce) | Webhook auto-redeploy |
|---|---|---|---|---|
| applio | `applio/docker-compose.yml` | `stacks/applio/docker-compose.yml` | `APPLIO_MODELS_DIR` = `/home/leojimenezcr/applio/models`; `APPLIO_OUTPUTS_DIR` = `/home/leojimenezcr/applio/outputs` | PENDIENTE — preguntar al usuario |
| coqui | `coqui/docker-compose.yml` | `stacks/coqui/docker-compose.yml` | (ninguna) | PENDIENTE |
| duplicati | `duplicati/docker-compose.yml` | `stacks/duplicati/docker-compose.yml` | `DUPLICATI_CONFIG_DIR` = `/home/leojimenezcr/duplicati`; `DUPLICATI_BACKUPS_DIR` = `/home/leojimenezcr/respaldos`; `DUPLICATI_SOURCE_DIR` = `/home/leojimenezcr` (⚠ home completo) | PENDIENTE |
| immich-app | `immich-app/docker-compose.yml` | `stacks/immich-app/docker-compose.yml` | Sin variables nuevas — verificar que `IMMICH_VERSION`, `UPLOAD_LOCATION`, `BASE_DIR`, `DB_USERNAME`, `DB_PASSWORD`, `DB_DATABASE_NAME` ya cargadas sigan intactas. **Ver aviso de `env_file` arriba.** | PENDIENTE |
| isp-monitor | `isp-monitor/docker-compose.yml` | `stacks/isp-monitor/docker-compose.yml` | Sin variables nuevas — verificar `BASE_DIR`, `GF_SECURITY_ADMIN_USER`, `GF_SECURITY_ADMIN_PASSWORD` | PENDIENTE |
| jellyfin | `jellyfin/docker-compose.yml` | `stacks/jellyfin/docker-compose.yml` | Sin variables nuevas — verificar `BASE_DIR`, `MEDIA_DIR`, `TRANSMISSION_USER`, `TRANSMISSION_PASS`, `TINYMEDIAMANAGER_PASSWORD`. **Ver aviso de `env_file` arriba.** | PENDIENTE |
| navidrome | `navidrome/docker-compose.yml` | `stacks/navidrome/docker-compose.yml` | Sin variables nuevas — verificar `BASE_DIR`, `MEDIA_DIR`, `ND_LASTFM_APIKEY`, `ND_LASTFM_SECRET` | PENDIENTE |
| Nextcloud | `Nextcloud/docker-compose.yml` | `stacks/Nextcloud/docker-compose.yml` | `NEXTCLOUD_DATA_DIR` = `/home/leojimenezcr/nextcloud/nextclouddata`; `NEXTCLOUD_DB_DIR` = `/home/leojimenezcr/nextcloud/nextclouddb`; verificar `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_ROOT_PASSWORD`. **Ver aviso de `env_file` arriba.** | PENDIENTE |
| ollama | `ollama/docker-compose.yml` | `stacks/ollama/docker-compose.yml` | `OLLAMA_DATA_DIR` = `/home/leojimenezcr/ollama/ollama`; `OLLAMA_WEBUI_DATA_DIR` = `/home/leojimenezcr/ollama/ollama-webui` | PENDIENTE |
| piper | `piper/docker-compose.yml` | `stacks/piper/docker-compose.yml` | `PIPER_MODELS_DIR` = `/home/leojimenezcr/piper/models` | PENDIENTE |
| Portainer | `Portainer/docker-compose.yml` | `stacks/Portainer/docker-compose.yml` | (ninguna) | PENDIENTE |
| Proxy | `Proxy/docker-compose.yml` | `proxy/docker-compose.yml` | `PROXY_CONFIG_DIR` = `/home/leojimenezcr/proxy`; verificar `URL`, `EMAIL`, `EXTRA_DOMAINS` | PENDIENTE |
| rasa-faq-demo | `rasa-faq-demo/docker-compose.yml` | `stacks/rasa-faq-demo/docker-compose.yml` | `RASA_FAQ_APP_DIR` = `/home/leojimenezcr/rasa-faq-demo`; `RASA_FAQ_WEBCHAT_INDEX_FILE` = `/home/leojimenezcr/rasa-faq-demo/index.html` | PENDIENTE |
| Transmission | `Transmission/docker-compose.yml` | `stacks/Transmission/docker-compose.yml` | `TRANSMISSION_CONFIG_DIR` = `/home/leojimenezcr/transmission/config`; `TRANSMISSION_DOWNLOADS_DIR` = `/home/leojimenezcr/transmission/downloads`; `TRANSMISSION_WATCH_DIR` = `/home/leojimenezcr/transmission/watch`; verificar `USER`, `PASS` | PENDIENTE |
| watchtower | `watchtower/docker-compose.yml` | `stacks/watchtower/docker-compose.yml` | (ninguna) | PENDIENTE |

## Orden sugerido de repunte en Portainer

1. Stacks sin `env_file` y sin variables nuevas (coqui, isp-monitor,
   navidrome, Portainer, watchtower) — riesgo mínimo, sirven de prueba del
   patrón.
2. Stacks con variables nuevas pero sin `env_file` (applio, duplicati,
   ollama, piper, Proxy, rasa-faq-demo, Transmission) — agregar las
   variables nuevas en la UI antes de aplicar el nuevo Compose path.
3. Stacks con `env_file` (immich-app, jellyfin, Nextcloud) — mayor riesgo,
   hacerlos al final y verificar login/funcionalidad inmediatamente después
   de cada uno.

## Nombres de stack en Portainer

No hay forma de derivar del código los nombres exactos que hoy tienen los
stacks en la UI de Portainer. Se asume que coinciden con el nombre de
carpeta original (antes de esta reorganización). **Verificar y corregir
esta tabla contra la UI real antes de ejecutar los cambios.**

## Webhooks de auto-redeploy

Ninguna columna de "Webhook auto-redeploy" pudo confirmarse desde el código
— depende de si cada stack tiene el webhook habilitado en su UI de
Portainer. Completar esa columna a mano, y si aplica, cargar la URL real en
`scripts/webhooks.env` (ver `scripts/webhooks.env.example` y
`scripts/trigger-portainer-redeploy.sh`).
