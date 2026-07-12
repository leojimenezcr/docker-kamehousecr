# Configuración de stacks en Portainer (GitOps)

Referencia para configurar y mantener cada stack de este repo en Portainer:
qué "Compose path" usar, qué variables cargar en la UI de cada stack, y
cómo funciona el redespliegue. No es un log de migración — se actualiza
cada vez que se agrega, quita o mueve un stack.

## Cómo crear o revisar un stack en Portainer

Portainer UI → Stacks → `<nombre>` (o "Add stack" si es nuevo) → tipo
"Repository":
1. **Repository URL** y **Reference** (branch, normalmente `main`).
2. **Compose path**: la ruta de la tabla de abajo, relativa a la raíz del
   repo (ej. `stacks/nextcloud/docker-compose.yml`, o `proxy/docker-compose.yml`
   para el proxy).
3. **Environment variables**: cargar las de la tabla de abajo (y las que
   liste el `.env.example` de esa carpeta). No se pierden al editar el
   Compose path de un stack ya creado.
4. Deploy the stack / Update the stack.

## Sobre `stack.env` y `env_file`

Los stacks `immich-app`, `jellyfin` y `nextcloud` usan
`env_file: ../../stack.env` en su `docker-compose.yml`. Ese `stack.env`
**no es un archivo que haya que crear a mano ni versionar en git**:
Portainer lo genera automáticamente cada vez que se guardan variables en la
sección "Environment variables" de la UI de un stack con repositorio Git,
escribiéndolas en un archivo `stack.env` en la raíz del clon local de
**ese stack en particular**. Cada stack tiene su propio clon independiente
del repositorio en el filesystem de Portainer, así que este `stack.env` es
privado de cada stack (no es un archivo compartido entre stacks, aunque el
nombre sea igual en todos) — por eso nunca existió ni va a existir en este
repo git.

La ruta relativa (`../../stack.env`) depende de la profundidad del Compose
path: apunta a la raíz del clon del stack. **Si en el futuro se vuelve a
mover el `docker-compose.yml` de alguno de estos 3 stacks a otra carpeta,
hay que ajustar esa ruta relativa en consecuencia** (un `../` por cada
nivel de anidamiento) y verificar login/funcionalidad después del cambio —
es el punto más fácil de romper silenciosamente en este repo.

## Redespliegue

**Portainer Community Edition sí soporta webhooks de redespliegue por
stack** (GitOps updates). Lo que queda detrás de "Business Feature" en esa
misma pantalla son dos opciones auxiliares — "Re-pull image" y "Force
redeployment" —, no el webhook en sí.

### Habilitar GitOps updates en un stack

Portainer UI → Stacks → `<nombre>` → sección **"Redeploy from git
repository"**:
1. Activar el toggle **GitOps updates**.
2. Elegir **Mechanism**: `Polling` o `Webhook`.
   - **Polling**: Portainer chequea el repo por intervalo y redespliega
     solo si detectó cambios — no requiere disparar nada manualmente.
   - **Webhook**: Portainer da una URL única
     (`.../api/stacks/webhooks/<uuid>`) — un `POST` a esa URL fuerza el
     redespliegue inmediatamente. Copiarla con el botón "Copy link".
3. Save settings.

### ⚠ Sobre la URL que da "Copy link"

Portainer arma esa URL usando el origin del navegador en el momento de
copiarla — **no** sabe que corre detrás de un proxy con subpath. En este
homelab (Portainer accedido vía `https://kamehousecr.ddns.net/portainer/`)
la URL que da el botón aterriza en la **raíz del dominio**, sin puerto ni
prefijo `/portainer/`:
```
https://kamehousecr.ddns.net/api/stacks/webhooks/<uuid>
```
Esa URL se puede copiar y usar **tal cual**, no hace falta reescribirla a
mano — el proxy tiene un location block dedicado (`^~ /api/stacks/webhooks/`
en `proxy/conf.d/default.conf`, ya versionado) que la reenvía directo al
puerto HTTP plano de Portainer (9000, sin TLS — es tráfico interno de la
red docker, no hace falta certificado).

Si en algún momento la URL copiada viene con el puerto 9443 directo
(`https://kamehousecr.ddns.net:9443/...`) es porque el navegador estaba
accediendo a Portainer directo por ese puerto en vez de vía `/portainer/`
— ese puerto expone el certificado **autofirmado** de Portainer (no el de
Let's Encrypt de SWAG) y un `curl`/`POST` directo falla con
`SSL: no alternative certificate subject name matches target hostname`.
Se deja abierto únicamente para entrar directo a Portainer si el proxy
está caído, no para webhooks — en ese caso, volver a copiar el link desde
`/portainer/` en vez de usar el puerto directo.

Si se edita `proxy/conf.d/default.conf`, hay que sincronizarlo al servidor
con `scripts/sync-proxy-conf.sh --to-host --apply` (reinicia el proxy) para
que el cambio quede activo — ver `proxy/conf.d/README.md`.

### Disparar el webhook desde este repo

1. Copiar `scripts/webhooks.env.example` a `scripts/webhooks.env`
   (gitignorado — nunca se commitea, tiene URLs con UUID que actúan como
   token).
2. Pegar ahí la URL real de cada stack que tenga el webhook habilitado, tal
   como la da "Copy link" (ver arriba).
3. Después de pushear un cambio:
   ```bash
   scripts/trigger-portainer-redeploy.sh <nombre-stack>
   ```
   (o `curl -X POST <url>` directo, sin el script).

Si un stack no tiene GitOps updates habilitado, redesplegar manualmente
desde la UI (Stacks → `<nombre>` → "Pull and redeploy" / volver a guardar
el stack).

## Tabla de stacks

| Stack en Portainer (asumido = nombre de carpeta, VERIFICAR contra la UI) | Compose path | Variables a cargar en la UI |
|---|---|---|
| duplicati ⚠ NO creado en Portainer | `stacks/duplicati/docker-compose.yml` | `DUPLICATI_CONFIG_DIR`, `DUPLICATI_BACKUPS_DIR`, `DUPLICATI_SOURCE_DIR` (⚠ home completo) — info conservada para si se vuelve a desplegar, no aplica hoy |
| immich-app | `stacks/immich-app/docker-compose.yml` | `IMMICH_VERSION`, `UPLOAD_LOCATION`, `BASE_DIR`, `DB_USERNAME`, `DB_PASSWORD`, `DB_DATABASE_NAME`. **Ver `env_file` arriba.** |
| isp-monitor | `stacks/isp-monitor/docker-compose.yml` | `BASE_DIR`, `GF_SECURITY_ADMIN_USER`, `GF_SECURITY_ADMIN_PASSWORD` |
| jellyfin | `stacks/jellyfin/docker-compose.yml` | `BASE_DIR`, `MEDIA_DIR`, `TRANSMISSION_USER`, `TRANSMISSION_PASS`, `TINYMEDIAMANAGER_PASSWORD`. **Ver `env_file` arriba.** |
| navidrome | `stacks/navidrome/docker-compose.yml` | `BASE_DIR`, `MEDIA_DIR`, `ND_LASTFM_APIKEY`, `ND_LASTFM_SECRET` |
| nextcloud | `stacks/nextcloud/docker-compose.yml` | `BASE_DIR` (contiene `nextclouddata/` y `nextclouddb/`), `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_ROOT_PASSWORD`. **Ver `env_file` arriba.** |
| portainer | `stacks/portainer/docker-compose.yml` | (ninguna) |
| proxy | `proxy/docker-compose.yml` | `BASE_DIR` (se monta completa, sin subcarpeta), `URL`, `EMAIL`, `EXTRA_DOMAINS` (hoy: `photoskamehousecr.ddns.net`, para immich-app) |
| watchtower | `stacks/watchtower/docker-compose.yml` | (ninguna) |

Cada carpeta tiene además su propio `.env.example` con el detalle y
placeholders de estas variables.

## Nombres de stack en Portainer

No hay forma de derivar del código los nombres exactos que tienen los
stacks en la UI de Portainer — la columna "Stack en Portainer" de la tabla
de arriba asume que coinciden con el nombre de carpeta bajo `stacks/`.
**Verificar contra la UI real** si hay dudas.
