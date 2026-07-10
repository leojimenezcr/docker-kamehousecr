#!/usr/bin/env bash
#
# sync-proxy-conf.sh — sincroniza el único archivo de config de SWAG que
# está versionado en este repo (proxy/conf.d/default.conf) contra su
# ubicación real dentro del bind mount del host
# (<PROXY_HOST_CONFIG_DIR>/nginx/site-confs/default.conf). Pensado para
# correr en el propio host del homelab, donde este repo está clonado.
#
# El bind mount real de SWAG en el host (${PROXY_HOST_CONFIG_DIR}) tiene
# mucho más contenido que este archivo: crontabs/, dns-conf/,
# etc/letsencrypt/ (certificados), keys/ (claves privadas), fail2ban/,
# log/, php/, www/, etc. — todo generado/gestionado por SWAG, nada de eso
# se versiona ni se sincroniza. Este script solo toca el archivo puntual
# nginx/site-confs/default.conf, nunca el resto del árbol.
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
#   PROXY_HOST_CONFIG_DIR   Raíz real del bind mount en el host.
#                            <<< PONER ACÁ LA RUTA REAL DEL SERVIDOR >>>
#                            (default abajo: /home/leojimenezcr/proxy)
#   PROXY_CONTAINER_NAME    Nombre del contenedor de proxy para el reload
#                            (default: proxy)

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"

# <<< AJUSTAR ACÁ la ruta real del servidor si difiere del default >>>
PROXY_HOST_CONFIG_DIR="${PROXY_HOST_CONFIG_DIR:-/home/leojimenezcr/proxy}"
PROXY_CONTAINER_NAME="${PROXY_CONTAINER_NAME:-proxy}"

HOST_FILE="${PROXY_HOST_CONFIG_DIR}/nginx/site-confs/default.conf"
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
  echo "Sincronizando HOST -> REPO"
else
  SRC="$REPO_FILE"
  DST="$HOST_FILE"
  echo "Sincronizando REPO -> HOST"
fi

echo "Origen:  ${SRC}"
echo "Destino: ${DST}"

if [[ ! -f "$SRC" ]]; then
  echo "ERROR: el archivo origen no existe: ${SRC}" >&2
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
