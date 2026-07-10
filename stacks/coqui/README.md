# coqui

## Qué hace
Servidor TTS Coqui (modelo en español, `tts_models/es/css10/vits`).

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| coqui-tts | 5002 | 5002 |

## Volúmenes
Ninguno.

## Depende de
Ninguno.

## Nombre del stack en Portainer
`coqui` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Este stack no requiere variables de entorno. Ver `.env.example` en esta
carpeta.

## Notas
La red `coqui-net` está declarada en el compose pero ningún servicio la usa
actualmente (no se corrigió en esta reorganización, fuera de alcance).
