# navidrome

## Qué hace
Servidor de streaming de música (Navidrome), con integración opcional a
Last.fm.

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| navidrome | 4533 | 4533 |

## Volúmenes
| Variable | Monta en | Descripción |
|---|---|---|
| `BASE_DIR` (`/navidromedata`) | `/data` | Base de datos e índices de Navidrome |
| `MEDIA_DIR` (`/music`) | `/music` (read-only) | Biblioteca de música |

## Depende de
Ninguno.

## Nombre del stack en Portainer
`navidrome` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`.
