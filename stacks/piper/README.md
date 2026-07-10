# piper

## Qué hace
TTS liviano (Rhasspy Piper, voz `es_MX-claude-high`).

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| piper | 10200 | 10200 |

## Volúmenes
`BASE_DIR` es la carpeta raíz de este stack en el host.

| Ruta | Monta en | Descripción |
|---|---|---|
| `${BASE_DIR}/models` | `/models` | Modelos de voz |

## Depende de
Ninguno.

## Nombre del stack en Portainer
`piper` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`.

## Notas
La red `piper-net` está declarada en el compose pero el servicio no la usa
actualmente (no se corrigió en esta reorganización, fuera de alcance).
