# applio

## Qué hace
Voz/TTS custom (Applio 3.2.9). El compose usa una imagen ya construida
localmente (`applio:3.2.9`); el `dockerfile` en esta carpeta documenta cómo
se construyó, pero no está referenciado por `build:` en el compose.

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| applio | 6969 | 6969 |

## Volúmenes
| Variable | Monta en | Descripción |
|---|---|---|
| `APPLIO_MODELS_DIR` | `/app/models` | Modelos de voz |
| `APPLIO_OUTPUTS_DIR` | `/app/outputs` | Salidas generadas |

## Depende de
Ninguno.

## Nombre del stack en Portainer
`applio` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`.
