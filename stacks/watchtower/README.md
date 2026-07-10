# watchtower

## Qué hace
Auto-actualización de contenedores (Watchtower). Actualiza cualquier
contenedor del homelab que tenga la label
`com.centurylinklabs.watchtower.enable=true` (prácticamente todos los
stacks de este repo la tienen).

## Puertos
Ninguno.

## Volúmenes
| Monta en | Descripción |
|---|---|
| `/var/run/docker.sock` | Socket de Docker (esperado, no se extrajo a variable) |
| `/etc/localtime:ro` | Hora del host (esperado, no se extrajo a variable) |

## Depende de
Ninguno (pero afecta a todos los stacks con la label de watchtower
habilitada).

## Nombre del stack en Portainer
`watchtower` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Este stack no requiere variables de entorno sensibles (poll interval y
flags de configuración quedan literales en el compose, no son secretos).
Ver `.env.example` en esta carpeta.
