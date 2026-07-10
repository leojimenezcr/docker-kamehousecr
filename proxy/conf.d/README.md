# proxy/conf.d

Acá van los server blocks de nginx, uno por dominio/servicio.

`default.conf` es un **snapshot versionado real** de la config de SWAG que
corre hoy en el servidor (copiado manualmente desde el host) — define el
dominio base (`kamehousecr.ddns.net`) y los `location` block por servicio
(portainer, jellyfin, navidrome, nextcloud, transmission vía el subfolder
method). Ver `../../docs/ARCHITECTURE.md` para el mapeo de dominios que se
extrajo de este archivo.

**Importante**: `proxy/docker-compose.yml` todavía **no monta esta carpeta**
dentro del contenedor — SWAG en el servidor sigue leyendo su propia copia
desde el bind mount (`BASE_DIR`). `default.conf` está en git como
referencia y backup versionado, no es (todavía) la fuente de verdad que usa
el contenedor en vivo. Cuando se quiera que sí lo sea, `proxy/docker-compose.yml`
deberá montar esta carpeta como bind mount versionado (no volumen anónimo)
en la ruta que corresponda según la convención de SWAG.
