#!/usr/bin/env bash
#
# trigger-portainer-redeploy.sh — dispara el webhook de redespliegue de un
# stack de Portainer, sin tener que entrar a la UI.
#
# Requiere scripts/webhooks.env con una variable WEBHOOK_<STACK> por stack
# (ver scripts/webhooks.env.example). Ese archivo NO se commitea (está en
# .gitignore) porque las URLs de webhook de Portainer incluyen un UUID que
# actúa como token de disparo.
#
# Uso:
#   scripts/trigger-portainer-redeploy.sh <nombre-stack>
#
# Ejemplo:
#   scripts/trigger-portainer-redeploy.sh jellyfin

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
WEBHOOKS_FILE="${SCRIPT_DIR}/webhooks.env"

if [[ $# -ne 1 ]]; then
  echo "Uso: $0 <nombre-stack>" >&2
  exit 1
fi

STACK_NAME="$1"

if [[ ! -f "$WEBHOOKS_FILE" ]]; then
  echo "ERROR: no existe ${WEBHOOKS_FILE}." >&2
  echo "Copiar scripts/webhooks.env.example a scripts/webhooks.env y completar las URLs reales (Portainer > Stack > Redeploy from git repository > Mechanism: Webhook > Copy link)." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$WEBHOOKS_FILE"

# Normaliza "jellyfin" -> "WEBHOOK_JELLYFIN", "immich-app" -> "WEBHOOK_IMMICH_APP"
VAR_NAME="WEBHOOK_$(echo "$STACK_NAME" | tr '[:lower:]-' '[:upper:]_')"
WEBHOOK_URL="${!VAR_NAME:-}"

if [[ -z "$WEBHOOK_URL" ]]; then
  echo "ERROR: no se encontró la variable ${VAR_NAME} en ${WEBHOOKS_FILE}." >&2
  exit 1
fi

echo "Disparando redespliegue de '${STACK_NAME}' via webhook..."
curl -fsS -X POST "$WEBHOOK_URL"
echo
echo "OK."
