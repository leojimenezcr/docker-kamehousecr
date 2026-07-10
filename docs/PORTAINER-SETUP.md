# Configuración de stacks en Portainer (GitOps)

> **CRÍTICO — leer antes de aplicar el merge de `reorg/estructura-stacks`:**
> Los stacks `immich-app`, `jellyfin` y `Nextcloud` usan
> `env_file: ../../stack.env`. Ese `stack.env` **no es un archivo que haya
> que crear a mano ni commitear**: Portainer lo genera automáticamente cada
> vez que se guardan variables en la sección "Environment variables" de la
> UI de un stack con repositorio Git, escribiéndolas en un archivo
> `stack.env` en la raíz del clon local de **ese stack en particular**.
> Cada stack tiene su propio clon independiente del repositorio en el
> filesystem de Portainer, así que este `stack.env` es privado de cada
> stack (no es un archivo compartido entre stacks, aunque el nombre sea
> igual en todos) — por eso nunca existió ni va a existir en este repo git.
>
> Antes de esta reorganización, el compose de esos 3 stacks vivía en
> `<servicio>/docker-compose.yml` y usaba `env_file: ../stack.env` (un
> nivel arriba = raíz del clon de ese stack). Ahora que el compose vive en
> `stacks/<servicio>/docker-compose.yml` (un nivel más adentro), la ruta
> relativa hacia esa raíz pasó a `../../stack.env` — **ya corregida en este
> branch**. Portainer sigue generando el `stack.env` en el mismo lugar de
> siempre (la raíz del clon de ese stack); lo único que cambió es cuántos
> `../` hacen falta para llegar ahí desde el compose.
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

**Portainer Community Edition no soporta webhooks de auto-redeploy para
stacks** (esa función requiere Business Edition). Después de pushear un
cambio a este repo, hay que redesplegar cada stack manualmente desde la UI
(Stacks → `<nombre>` → "Pull and redeploy" / volver a guardar el stack) —
o revisar si ese stack tiene "Automatic updates" con polling por intervalo
configurado (mecanismo distinto al webhook, verificar en tu versión de
Portainer si está disponible y activo).

## Tabla de stacks

| Stack en Portainer (asumido = nombre de carpeta, VERIFICAR contra la UI) | Compose path VIEJO | Compose path NUEVO | Variables a cargar/agregar en la UI (valor actual a preservar, cuando se conoce) |
|---|---|---|---|
| applio | `applio/docker-compose.yml` | `stacks/applio/docker-compose.yml` | `APPLIO_MODELS_DIR` = `/home/leojimenezcr/applio/models`; `APPLIO_OUTPUTS_DIR` = `/home/leojimenezcr/applio/outputs` |
| coqui | `coqui/docker-compose.yml` | `stacks/coqui/docker-compose.yml` | (ninguna) |
| duplicati | `duplicati/docker-compose.yml` | `stacks/duplicati/docker-compose.yml` | `DUPLICATI_CONFIG_DIR` = `/home/leojimenezcr/duplicati`; `DUPLICATI_BACKUPS_DIR` = `/home/leojimenezcr/respaldos`; `DUPLICATI_SOURCE_DIR` = `/home/leojimenezcr` (⚠ home completo) |
| immich-app | `immich-app/docker-compose.yml` | `stacks/immich-app/docker-compose.yml` | Sin variables nuevas — verificar que `IMMICH_VERSION`, `UPLOAD_LOCATION`, `BASE_DIR`, `DB_USERNAME`, `DB_PASSWORD`, `DB_DATABASE_NAME` ya cargadas sigan intactas. **Ver aviso de `env_file` arriba.** |
| isp-monitor | `isp-monitor/docker-compose.yml` | `stacks/isp-monitor/docker-compose.yml` | Sin variables nuevas — verificar `BASE_DIR`, `GF_SECURITY_ADMIN_USER`, `GF_SECURITY_ADMIN_PASSWORD` |
| jellyfin | `jellyfin/docker-compose.yml` | `stacks/jellyfin/docker-compose.yml` | Sin variables nuevas — verificar `BASE_DIR`, `MEDIA_DIR`, `TRANSMISSION_USER`, `TRANSMISSION_PASS`, `TINYMEDIAMANAGER_PASSWORD`. **Ver aviso de `env_file` arriba.** |
| navidrome | `navidrome/docker-compose.yml` | `stacks/navidrome/docker-compose.yml` | Sin variables nuevas — verificar `BASE_DIR`, `MEDIA_DIR`, `ND_LASTFM_APIKEY`, `ND_LASTFM_SECRET` |
| Nextcloud | `Nextcloud/docker-compose.yml` | `stacks/Nextcloud/docker-compose.yml` | `NEXTCLOUD_DATA_DIR` = `/home/leojimenezcr/nextcloud/nextclouddata`; `NEXTCLOUD_DB_DIR` = `/home/leojimenezcr/nextcloud/nextclouddb`; verificar `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_ROOT_PASSWORD`. **Ver aviso de `env_file` arriba.** |
| ollama | `ollama/docker-compose.yml` | `stacks/ollama/docker-compose.yml` | `OLLAMA_DATA_DIR` = `/home/leojimenezcr/ollama/ollama`; `OLLAMA_WEBUI_DATA_DIR` = `/home/leojimenezcr/ollama/ollama-webui` |
| piper | `piper/docker-compose.yml` | `stacks/piper/docker-compose.yml` | `PIPER_MODELS_DIR` = `/home/leojimenezcr/piper/models` |
| Portainer | `Portainer/docker-compose.yml` | `stacks/Portainer/docker-compose.yml` | (ninguna) |
| Proxy | `Proxy/docker-compose.yml` | `proxy/docker-compose.yml` | `PROXY_CONFIG_DIR` = `/home/leojimenezcr/proxy`; verificar `URL`, `EMAIL`, `EXTRA_DOMAINS` |
| rasa-faq-demo | `rasa-faq-demo/docker-compose.yml` | `stacks/rasa-faq-demo/docker-compose.yml` | `RASA_FAQ_APP_DIR` = `/home/leojimenezcr/rasa-faq-demo`; `RASA_FAQ_WEBCHAT_INDEX_FILE` = `/home/leojimenezcr/rasa-faq-demo/index.html` |
| Transmission | `Transmission/docker-compose.yml` | `stacks/Transmission/docker-compose.yml` | `TRANSMISSION_CONFIG_DIR` = `/home/leojimenezcr/transmission/config`; `TRANSMISSION_DOWNLOADS_DIR` = `/home/leojimenezcr/transmission/downloads`; `TRANSMISSION_WATCH_DIR` = `/home/leojimenezcr/transmission/watch`; verificar `USER`, `PASS` |
| watchtower | `watchtower/docker-compose.yml` | `stacks/watchtower/docker-compose.yml` | (ninguna) |

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
