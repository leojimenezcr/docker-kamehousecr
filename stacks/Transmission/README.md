# Transmission

## Qué hace
Cliente BitTorrent standalone (Transmission).

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| transmission | — (9091, 51413(+udp) comentados/deshabilitados) | 9091, 51413(+udp) |

## Volúmenes
| Variable | Monta en | Descripción |
|---|---|---|
| `TRANSMISSION_CONFIG_DIR` | `/config` | Configuración |
| `TRANSMISSION_DOWNLOADS_DIR` | `/downloads` | Descargas completas |
| `TRANSMISSION_WATCH_DIR` | `/watch` | Carpeta vigilada para agregar torrents |

## Depende de
Ninguno.

## Nombre del stack en Portainer
`Transmission` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`. Nota: `USER`/`PASS` son nombres genéricos
heredados del compose original, con riesgo de colisión con variables de
entorno del shell/sistema — no se renombraron (fuera de alcance funcional).

## ⚠ Conflicto conocido (no resuelto aquí)
Este stack duplica funcionalmente al servicio `transmission` embebido en
`stacks/jellyfin` (mismo `container_name: transmission`). Ver
`../../docs/ARCHITECTURE.md`.
