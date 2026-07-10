# docker-kamehousecr

Configuración de contenedores Docker del homelab de Leo. Cada carpeta bajo
`stacks/` (y `proxy/` como excepción, top-level) contiene un
`docker-compose.yml` autocontenido que representa un "stack" desplegado por
**Portainer vía GitOps**: Portainer apunta a un branch de este repo + un
"Compose path" relativo, y las variables de entorno de cada stack se cargan
normalmente en la UI de Portainer (no vía `.env` versionado en git — ver
[`docs/PORTAINER-SETUP.md`](docs/PORTAINER-SETUP.md)).

## Estructura

```
docker-kamehousecr/
├── docs/                    # Documentación de arquitectura y setup de Portainer
├── proxy/                   # Reverse proxy (SWAG) — excepción, no vive bajo stacks/
├── stacks/                  # Un subdirectorio por stack de Portainer
│   └── <servicio>/
│       ├── docker-compose.yml
│       ├── .env.example     # Documentación de las variables que espera el compose
│       └── README.md        # Qué hace, puertos, volúmenes, dependencias
└── scripts/                 # Utilidades para operar el homelab
```

## Mapa de stacks

Ver la tabla completa en [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

| Stack | Descripción |
|---|---|
| `stacks/duplicati` | Backups — versionado, no desplegado actualmente |
| `stacks/immich-app` | Fotos/videos self-hosted |
| `stacks/isp-monitor` | Monitoreo de conectividad ISP (Prometheus + Grafana) |
| `stacks/jellyfin` | Media server + arr-stack (incluye transmission embebido) |
| `stacks/navidrome` | Streaming de música |
| `stacks/nextcloud` | Nube personal |
| `stacks/portainer` | Gestor de contenedores |
| `stacks/watchtower` | Auto-actualización de contenedores |
| `proxy` | Reverse proxy + HTTPS (SWAG) |

## Cómo desplegar/actualizar un stack

1. Editar el `docker-compose.yml` correspondiente en este repo.
2. Confirmar los cambios (commit) y subirlos al branch que Portainer está siguiendo.
3. Redesplegar el stack manualmente desde la UI de Portainer (Stacks →
   `<nombre>` → "Pull and redeploy"). Portainer Community Edition no
   soporta webhooks de auto-redespliegue para stacks — ver
   [`docs/PORTAINER-SETUP.md`](docs/PORTAINER-SETUP.md) para el detalle.

## Documentación

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — mapa de servicios,
  puertos, dependencias entre stacks, conflictos conocidos.
- [`docs/PORTAINER-SETUP.md`](docs/PORTAINER-SETUP.md) — Compose path y
  variables a cargar en la UI para cada stack, cómo funciona el
  redespliegue.
