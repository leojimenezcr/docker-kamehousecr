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
`BASE_DIR` es la carpeta raíz de este stack en el host.

| Ruta | Monta en | Descripción |
|---|---|---|
| `${BASE_DIR}/models` | `/app/models` | Modelos de voz |
| `${BASE_DIR}/outputs` | `/app/outputs` | Salidas generadas |

## Depende de
Ninguno.

## Nombre del stack en Portainer
`applio` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`.
