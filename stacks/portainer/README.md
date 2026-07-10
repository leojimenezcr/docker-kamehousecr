# portainer

## Qué hace
Gestor de contenedores vía interfaz web (Portainer CE). Este es el propio
Portainer que administra todos los demás stacks del repo vía GitOps.

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| portainer | 8000 | 8000 |
| portainer | 9443 | 9443 |

## Volúmenes
| Monta en | Descripción |
|---|---|
| `/var/run/docker.sock` | Socket de Docker (esperado, no se extrajo a variable) |
| `./data` | Datos de Portainer (volumen relativo, único caso así en el repo) |

## Depende de
Ninguno. Es dueño de la red externa `portainer_portainer-net`, consumida por
el stack `proxy`.

## Nombre del stack en Portainer
`portainer` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Este stack no requiere variables de entorno. Ver `.env.example` en esta
carpeta.
