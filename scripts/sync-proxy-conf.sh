#!/usr/bin/env bash
#
# sync-proxy-conf.sh — sincroniza el único archivo de config de SWAG que
# está versionado en este repo (proxy/conf.d/default.conf) contra su
# ubicación real dentro del bind mount del servidor
# (<PROXY_HOST_CONFIG_DIR>/nginx/site-confs/default.conf), vía SSH.
# Pensado para correrse desde cualquier máquina donde esté clonado/sincronizado
# este repo (no hace falta estar logueado en el servidor) — usa SSH
# (PROXY_SSH_TARGET) para llegar al servidor real. Requiere acceso SSH por
# llave ya configurado a ese destino (sin prompt de password).
#
# El bind mount real de SWAG en el servidor (${PROXY_HOST_CONFIG_DIR}) tiene
# mucho más contenido que este archivo: crontabs/, dns-conf/,
# etc/letsencrypt/ (certificados), keys/ (claves privadas), fail2ban/,
# log/, php/, www/, etc. — todo generado/gestionado por SWAG, nada de eso
# se versiona ni se sincroniza. Este script solo toca el archivo puntual
# nginx/site-confs/default.conf, nunca el resto del árbol.
#
# Modo seguro por defecto: dry-run (rsync -n). Requiere --apply para
# ejecutar de verdad. Tras un --to-host --apply exitoso, reinicia el
# contenedor de proxy **en el servidor, vía SSH** (esta imagen de SWAG no
# soporta "nginx -s reload" via docker exec; lo que sí funciona es
# reiniciar el contenedor completo).
#
# Uso:
#   scripts/sync-proxy-conf.sh --to-repo   [--apply]   # servidor -> repo
#   scripts/sync-proxy-conf.sh --to-host   [--apply]   # repo -> servidor
#
# Variables de entorno (opcionales, con default):
#   PROXY_SSH_TARGET        Usuario y host SSH del servidor real.
#                            (default abajo: leojimenezcr@kamehousecr.ddns.net)
#   PROXY_HOST_CONFIG_DIR   Ruta del bind mount en el servidor (remota, vía SSH).
#                            (default abajo: /home/leojimenezcr/proxy)
#   PROXY_CONTAINER_NAME    Nombre del contenedor de proxy a reiniciar
#                            (default: proxy)

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"

# <<< AJUSTAR ACÁ si el destino SSH o la ruta real del servidor difieren >>>
PROXY_SSH_TARGET="${PROXY_SSH_TARGET:-leojimenezcr@kamehousecr.ddns.net}"
PROXY_HOST_CONFIG_DIR="${PROXY_HOST_CONFIG_DIR:-/home/leojimenezcr/proxy}"
PROXY_CONTAINER_NAME="${PROXY_CONTAINER_NAME:-proxy}"

HOST_FILE="${PROXY_SSH_TARGET}:${PROXY_HOST_CONFIG_DIR}/nginx/site-confs/default.conf"
REPO_FILE="${REPO_ROOT}/proxy/conf.d/default.conf"

DIRECTION=""
APPLY="false"

usage() {
  echo "Uso: $0 --to-repo|--to-host [--apply]" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --to-repo) DIRECTION="to-repo" ;;
    --to-host) DIRECTION="to-host" ;;
    --apply)   APPLY="true" ;;
    -h|--help) usage ;;
    *) echo "Argumento desconocido: $1" >&2; usage ;;
  esac
  shift
done

[[ -z "$DIRECTION" ]] && usage

RSYNC_FLAGS=(-av)
if [[ "$APPLY" != "true" ]]; then
  RSYNC_FLAGS+=(--dry-run)
  echo "== DRY RUN (no se copia nada). Usar --apply para ejecutar de verdad. =="
fi

if [[ "$DIRECTION" == "to-repo" ]]; then
  SRC="$HOST_FILE"
  DST="$REPO_FILE"
  echo "Sincronizando SERVIDOR (${PROXY_SSH_TARGET}) -> REPO"
else
  SRC="$REPO_FILE"
  DST="$HOST_FILE"
  echo "Sincronizando REPO -> SERVIDOR (${PROXY_SSH_TARGET})"
fi

echo "Origen:  ${SRC}"
echo "Destino: ${DST}"

if [[ "$DIRECTION" == "to-host" && ! -f "$SRC" ]]; then
  echo "ERROR: el archivo origen no existe: ${SRC}" >&2
  exit 1
fi

rsync "${RSYNC_FLAGS[@]}" "${SRC}" "${DST}"

if [[ "$APPLY" != "true" ]]; then
  echo "== Nada fue copiado (dry-run). Revisar la salida de arriba y volver a correr con --apply. =="
  exit 0
fi

if [[ "$DIRECTION" == "to-host" ]]; then
  echo "Reiniciando el contenedor '${PROXY_CONTAINER_NAME}' en ${PROXY_SSH_TARGET} (esta imagen no soporta 'nginx -s reload')..."
  ssh "$PROXY_SSH_TARGET" docker restart "${PROXY_CONTAINER_NAME}"
  echo "OK."
fi
