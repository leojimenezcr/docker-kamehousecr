# duplicati

## Qué hace
Backups programados con Duplicati.

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| duplicati | 8200 | 8200 |

## Volúmenes
| Variable | Monta en | Descripción |
|---|---|---|
| `DUPLICATI_CONFIG_DIR` | `/config` | Configuración de Duplicati |
| `DUPLICATI_BACKUPS_DIR` | `/backups` | Destino de los respaldos |
| `DUPLICATI_SOURCE_DIR` | `/source` | ⚠ Origen a respaldar — hoy apunta al `$HOME` completo del host, ver `docs/ARCHITECTURE.md` |

## Depende de
Ninguno.

## Nombre del stack en Portainer
`duplicati` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`.
