# jellyfin

## Qué hace
Media server (Jellyfin) + arr-stack: sonarr, radarr, bazarr, jellyseerr,
jackett, transmission (embebido), tinymediamanager.

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| jellyfin | 8096 | 8096 |
| sonarr | 8989 | 8989 |
| radarr | 7878 | 7878 |
| bazarr | 6767 | 6767 |
| jellyseerr | 5055 | 5055 |
| jackett | 9117 | 9117 |
| transmission (embebido) | 9091, 51413(+udp) | 9091, 51413(+udp) |
| tinymediamanager | 4000 | 4000 |

## Volúmenes
Todos los bind mounts usan `${BASE_DIR}` (config por servicio) y
`${MEDIA_DIR}` (bibliotecas: tvshows, anime, movies, erotic, musicvideos,
music). `jellyfin` también monta `/dev/dri` (passthrough de GPU Intel,
device path genérico, no se parametrizó).

## Depende de
`jellyseerr` depende de `radarr`/`sonarr`. Todo interno al mismo stack.

## Nombre del stack en Portainer
`jellyfin` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Este stack usa `env_file: ../../stack.env` — ver aviso crítico en
`../../docs/PORTAINER-SETUP.md` sobre la ruta relativa de ese archivo tras la
reorganización. Ver también `.env.example` en esta carpeta.

## ⚠ Conflicto conocido (no resuelto aquí)
El servicio `transmission` embebido en este stack (`container_name:
transmission`, puertos 9091/51413 activos, PGID=1000) duplica funcionalmente
al stack standalone `stacks/Transmission` (mismo `container_name`,
PGID=1001, puertos deshabilitados). No pueden correr simultáneamente sin
colisión de nombre. Ver `../../docs/ARCHITECTURE.md`.
