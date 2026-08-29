# juegos

## Qué hace
Sirve el arcade de minijuegos educativos de ciberseguridad ("Reto de
Ciberseguridad", proyecto **juegoscyberseguridad** — repo aparte, no
versionado en este). Es un sitio 100% estático (HTML/CSS/JS con ES
modules nativos, sin backend ni build step), así que el contenedor es
nginx plano sirviendo la carpeta del sitio como raíz. Se expone vía
`proxy` bajo `/juegos`.

## Contenido del sitio no vive en este repo
Este stack **solo versiona la definición del contenedor**, no el
contenido (HTML/CSS/JS). El sitio vive en el proyecto
`juegoscyberseguridad` (repo aparte, local en
`~/Nextcloud/Proyectos/juegoscyberseguridad`) y hay que sincronizarlo a
mano al `BASE_DIR` en el host cada vez que se publica contenido nuevo
(ej. `git clone`/`git pull` de ese repo directo en `BASE_DIR`, o un
`rsync` desde donde corresponda) — no hay redeploy automático de
contenido como con los stacks basados en GitOps de Portainer, porque el
GitOps de este stack apunta a este repo (`docker-kamehousecr`), no al
del juego.

Todas las rutas internas del sitio (`href`/`src`/`import`) son
relativas, así que sirve sin cambios bajo el subpath `/juegos/` — no
hace falta ninguna variable de "base URL" como en `navidrome`
(`ND_BASEURL`).

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| juegos | sin puerto host | 80 |

## Volúmenes
| Variable | Monta en | Descripción |
|---|---|---|
| `BASE_DIR` | `/usr/share/nginx/html` (read-only) | Raíz del sitio estático (`index.html`, `shared/`, `games/`, etc., sincronizados a mano desde el proyecto `juegoscyberseguridad`) |

## Depende de
Ninguno.

## Nombre del stack en Portainer
`juegos` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`.
