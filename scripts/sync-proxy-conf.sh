#!/usr/bin/env bash
#
# sync-proxy-conf.sh — sincroniza la config de nginx/SWAG entre este repo
# (proxy/conf.d, proxy/nginx.conf) y el bind mount real del host donde
# corre el contenedor de proxy. Pensado para correr en el propio host del
# homelab, donde este repo está clonado.
#
# Hoy proxy/conf.d y proxy/nginx.conf son PLACEHOLDERS (ver proxy/README.md)
# porque la config real de SWAG solo existe en el volumen del host, no en
# git. Este script queda listo para cuando se migre esa config real al
# repo — no la migra por sí solo.
#
# Modo seguro por defecto: dry-run (rsync -n). Requiere --apply para
# ejecutar de verdad. Tras un --to-host --apply exitoso, recarga nginx
# dentro del contenedor de proxy.
#
# Uso:
#   scripts/sync-proxy-conf.sh --to-repo   [--apply]   # host -> repo
#   scripts/sync-proxy-conf.sh --to-host   [--apply]   # repo -> host
#
# Variables de entorno (opcionales, con default):
#   PROXY_HOST_CONFIG_DIR   Ruta real del bind mount en el host.
#                            <<< PONER ACÁ LA RUTA REAL DEL SERVIDOR >>>
#                            (default abajo: /home/leojimenezcr/proxy)
#   PROXY_REPO_CONF_DIR     Ruta de proxy/ dentro de este repo (default:
#                            se calcula sola a partir de este script)
#   PROXY_CONTAINER_NAME    Nombre del contenedor de proxy para el reload
#                            (default: proxy)

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"

# <<< AJUSTAR ACÁ la ruta real del servidor si difiere del default >>>
PROXY_HOST_CONFIG_DIR="${PROXY_HOST_CONFIG_DIR:-/home/leojimenezcr/proxy}"
PROXY_REPO_CONF_DIR="${PROXY_REPO_CONF_DIR:-${REPO_ROOT}/proxy}"
PROXY_CONTAINER_NAME="${PROXY_CONTAINER_NAME:-proxy}"

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
  SRC="${PROXY_HOST_CONFIG_DIR}/"
  DST="${PROXY_REPO_CONF_DIR}/"
  echo "Sincronizando HOST -> REPO"
else
  SRC="${PROXY_REPO_CONF_DIR}/"
  DST="${PROXY_HOST_CONFIG_DIR}/"
  echo "Sincronizando REPO -> HOST"
fi

echo "Origen:  ${SRC}"
echo "Destino: ${DST}"

if [[ ! -d "$SRC" ]]; then
  echo "ERROR: el directorio origen no existe: ${SRC}" >&2
  exit 1
fi

rsync "${RSYNC_FLAGS[@]}" "${SRC}" "${DST}"

if [[ "$APPLY" != "true" ]]; then
  echo "== Nada fue copiado (dry-run). Revisar la salida de arriba y volver a correr con --apply. =="
  exit 0
fi

if [[ "$DIRECTION" == "to-host" ]]; then
  echo "Recargando nginx dentro del contenedor '${PROXY_CONTAINER_NAME}'..."
  docker exec "${PROXY_CONTAINER_NAME}" nginx -s reload
  echo "OK."
fi
