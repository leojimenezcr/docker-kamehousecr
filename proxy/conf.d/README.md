# proxy/conf.d

Acá van los server blocks de nginx, uno por dominio/servicio.

`default.conf` es un **snapshot versionado real** de la config de SWAG que
corre hoy en el servidor (copiado manualmente desde el host) — define el
dominio base (`kamehousecr.ddns.net`) y los `location` block por servicio
(portainer, jellyfin, navidrome, nextcloud, transmission vía el subfolder
method). Ver `../../docs/ARCHITECTURE.md` para el mapeo de dominios que se
extrajo de este archivo.

**Importante**: `proxy/docker-compose.yml` todavía **no monta este archivo**
dentro del contenedor — SWAG en el servidor sigue leyendo su propia copia
real desde `${BASE_DIR}/nginx/site-confs/default.conf` (dentro del
contenedor: `/config/nginx/site-confs/default.conf`). `default.conf` está
en git como referencia y backup versionado, no es (todavía) la fuente de
verdad que usa el contenedor en vivo. Cuando se quiera que sí lo sea,
`proxy/docker-compose.yml` deberá agregar un bind mount adicional de este
archivo puntual sobre esa ruta — no de toda la carpeta `nginx/` del host,
que tiene mucho más contenido gestionado por SWAG (certificados, claves,
fail2ban, etc.) ajeno a este repo.

Ver `scripts/sync-proxy-conf.sh` (raíz del repo) para sincronizar este
archivo puntual contra el host real.
