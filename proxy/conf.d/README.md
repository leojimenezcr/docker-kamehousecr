# proxy/conf.d

Server blocks de nginx, uno por dominio/servicio.

`default.conf` es un snapshot versionado de la config real de SWAG en el
servidor: dominio base (`kamehousecr.ddns.net`) con `location` block por
servicio (portainer, jellyfin, navidrome, nextcloud, transmission, grafana,
prometheus vía subfolder method), más un segundo `server` block para
`photoskamehousecr.ddns.net` (dominio propio de `immich-app`). Ver
`../../docs/ARCHITECTURE.md` para el mapeo completo de dominios.

`proxy/docker-compose.yml` **no monta este archivo** dentro del
contenedor — SWAG sigue leyendo su propia copia desde
`${BASE_DIR}/nginx/site-confs/default.conf` en el host
(`/config/nginx/site-confs/default.conf` dentro del contenedor).
`default.conf` es referencia/backup versionado, no la fuente en vivo. Ver
`../README.md` para cómo montarlo si se necesita.

`scripts/sync-proxy-conf.sh` (raíz del repo) sincroniza este archivo
puntual contra el host real.
