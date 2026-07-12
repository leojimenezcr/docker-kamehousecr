# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Qué es este repo

Configuración de contenedores Docker del homelab de Leo. No es una
aplicación con build/test/lint — es un conjunto de `docker-compose.yml`
consumidos por **Portainer vía GitOps**: Portainer apunta a un branch de
este repo + un "Compose path" relativo por stack, y hace pull/redeploy
desde ahí. No hay CI ni pipeline de build.

## Estructura

```
docker-kamehousecr/
├── docs/                    # ARCHITECTURE.md, PORTAINER-SETUP.md
├── proxy/                   # Reverse proxy (SWAG) — excepción, no vive bajo stacks/
├── stacks/                  # Un subdirectorio por stack de Portainer
│   └── <servicio>/
│       ├── docker-compose.yml
│       ├── .env.example     # Documentación de las variables que espera el compose
│       └── README.md        # Qué hace, puertos, volúmenes, dependencias
└── scripts/                 # Utilidades para operar el homelab
```

Cada carpeta bajo `stacks/` (y `proxy/` como excepción top-level) es
autocontenida: `docker-compose.yml` + `.env.example` + `README.md`. Los
stacks actuales: `duplicati`, `immich-app`, `isp-monitor`, `jellyfin`,
`navidrome`, `nextcloud`, `portainer`, `watchtower`, más `proxy`. Ver
`docs/ARCHITECTURE.md` para el mapa completo de servicios, puertos y
dependencias, y `docs/PORTAINER-SETUP.md` para cómo se configura cada
stack en la UI de Portainer.

## Convenciones al editar un `docker-compose.yml`

- **Variables de entorno nunca en git con valores reales.** Cada carpeta
  tiene un `.env.example` con placeholders documentados
  ("NUNCA completar este archivo con valores reales ni versionarlo en git
  con datos sensibles"). Los valores reales se cargan en la UI de
  Portainer ("Environment variables" de cada stack), no vía `.env`
  versionado.
- **Convención `BASE_DIR`**: la mayoría de los stacks (`nextcloud`,
  `jellyfin`, `navidrome`, `isp-monitor`, `immich-app`, `proxy`) usan una
  sola variable `BASE_DIR` por stack apuntando a la carpeta raíz de datos
  en el host, con los volúmenes expresados como `${BASE_DIR}/subcarpeta`.
  **Excepción explícita: `duplicati`** usa tres variables de ruta completa
  (`DUPLICATI_CONFIG_DIR`, `DUPLICATI_BACKUPS_DIR`, `DUPLICATI_SOURCE_DIR`)
  porque sus tres volúmenes no comparten una carpeta dedicada — no lo
  fuerces a `BASE_DIR` sin consultarlo primero.
- **`env_file: ../../stack.env`**: usado por `immich-app`, `jellyfin` y
  `nextcloud`. Ese `stack.env` **no existe en este repo ni debe crearse a
  mano** — Portainer lo autogenera en la raíz del clon de cada stack a
  partir de las "Environment variables" cargadas en su UI. La ruta
  relativa depende de la profundidad del `docker-compose.yml`; si se mueve
  de carpeta hay que ajustar el número de `../` y volver a verificar
  login/funcionalidad (ver detalle en `docs/PORTAINER-SETUP.md`).
- Todos los servicios llevan el label
  `com.centurylinklabs.watchtower.enable=true` para que el stack
  `watchtower` los mantenga actualizados — agregalo a cualquier servicio
  nuevo salvo razón explícita para excluirlo.
- Nombres de carpeta/rutas en minúscula (normalizado en todo el repo). Los
  nombres de producto en prosa (Nextcloud, Portainer, Transmission, etc.)
  sí van capitalizados como se escriben normalmente.
- `duplicati` está versionado pero **no tiene stack creado en Portainer
  actualmente** — mantené el código si se toca, pero no asumas que está
  desplegado.

## El proxy (`proxy/`)

`proxy/` es SWAG (`linuxserver/swag`), no nginx plano — gestiona su propia
config interna de Let's Encrypt/nginx. Es el único servicio con salida a
internet; todos los demás stacks pasan por acá.

- `proxy/conf.d/default.conf` es un **snapshot real versionado** de la
  config que corre en el servidor (subfolder method sobre el dominio único
  `kamehousecr.ddns.net`). **No se monta automáticamente en el
  contenedor** — el `docker-compose.yml` del proxy solo monta
  `${BASE_DIR}:/config` completo. La ubicación real y viva del archivo en
  el host es `${BASE_DIR}/nginx/site-confs/default.conf`.
- Para llevar un cambio de `proxy/conf.d/default.conf` al servidor real:
  `scripts/sync-proxy-conf.sh --to-host --apply` (sincroniza ese único
  archivo por SSH y reinicia el contenedor de proxy — esta imagen de SWAG
  no soporta `nginx -s reload`, hay que reiniciarlo completo). El script
  nunca toca el resto del árbol de `${BASE_DIR}` (certificados, claves,
  fail2ban, etc. — todo gestionado por SWAG, fuera de alcance de este
  repo). Correlo con `--to-repo` (sin `--apply` primero, es dry-run por
  defecto) para traer el estado real del servidor de vuelta al repo.
- Portainer se proxea vía `/portainer/` usando el **puerto HTTP plano de
  Portainer (9000)**, no el 9443 (TLS con cert autofirmado) — evita lidiar
  con certificados para tráfico que es interno a la red docker. El webhook
  de redespliegue (`/api/stacks/webhooks/<uuid>`) tiene su propio location
  block en la **raíz** del dominio (no bajo `/portainer/`), porque el
  frontend de Portainer arma esa URL con el origin del navegador sin saber
  que corre detrás de un subpath — ver el detalle completo en
  `docs/PORTAINER-SETUP.md`.

## Redespliegue vía webhook

Portainer CE sí soporta webhooks de GitOps updates por stack (no requiere
Business Edition). Uso desde este repo:
1. Copiar `scripts/webhooks.env.example` a `scripts/webhooks.env`
   (gitignorado, nunca se commitea — las URLs llevan un UUID que actúa
   como token) y pegar ahí la URL real de cada stack.
2. `scripts/trigger-portainer-redeploy.sh <nombre-stack>` — dispara el
   `POST` al webhook correspondiente.

Ver `docs/PORTAINER-SETUP.md` para cómo habilitar el webhook en un stack y
troubleshooting de URLs/certificados.

## Idioma y estilo de la documentación

Toda la documentación de este repo está en español. Se evitan
anglicismos/spanglish de verbos comunes en flujos git (usar "subir" en vez
de "pushear", "versionar"/"confirmar" en vez de "comitear", etc.), salvo
nombres literales de elementos de UI en inglés (ej. botones como
"Pull and redeploy" o "Copy link") y sustantivos técnicos estándar de git.
