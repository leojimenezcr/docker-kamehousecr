# proxy/conf.d

Acá van los server blocks de nginx, uno por dominio/servicio (ej.
`nextcloud.subdomain.conf`, `jellyfin.subdomain.conf`, etc.), una vez que se
migre la configuración real de SWAG a este repo.

Hoy esta carpeta está **vacía** (solo este README) porque la configuración
real vive únicamente en el bind mount del host (`PROXY_CONFIG_DIR`,
actualmente `/home/leojimenezcr/proxy`), fuera de git. No se inventaron
server blocks acá — ver `../README.md` para el detalle completo de por qué
y cómo migrar esa configuración.

Cuando se traiga la config real por SSH, `proxy/docker-compose.yml` deberá
montar esta carpeta como bind mount versionado (no volumen anónimo) para
que quede en git.
