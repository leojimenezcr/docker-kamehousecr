# n8n

## Qué hace
Editor/motor de automatizaciones n8n (community), con el **AI Assistant**
activado y apuntando a un modelo servido localmente por el stack `ollama`
en vez de un proveedor en la nube (OpenAI/Anthropic/OpenRouter). Incluye el
stack de sandbox oficial que el AI Assistant necesita para ejecutar código
(`sandbox-certs`, `sandbox-api`, `sandbox-runner-1`), el backend de
búsqueda web `searxng` y un contenedor propio de Postgres (`postgres`)
como base de datos de n8n en vez del sqlite por defecto, tal como los arma
la [guía oficial de docker-compose de n8n](https://docs.n8n.io/deploy/host-n8n/install-options/install-using-docker-compose).

## Puertos
Ninguno expuesto al host — a diferencia del compose oficial (que publica
`5678:5678`), acá n8n sale únicamente vía el stack `proxy`, igual que
`nextcloud` o `grafana`/`prometheus` (isp-monitor).

## Volúmenes
| Variable | Monta en | Descripción |
|---|---|---|
| `BASE_DIR` (`/n8n`) | `/home/node/.n8n` | Datos de n8n: workflows, credenciales cifradas, config |
| `BASE_DIR` (`/postgres`) | `/var/lib/postgresql/data` | Datos de la base de datos Postgres de n8n |
| `BASE_DIR` (`/searxng-settings.yml`) | `/etc/searxng/settings.yml` (ro) | Config de SearXNG — copiar a mano el archivo `searxng-settings.yml` de esta carpeta del repo a `${BASE_DIR}/searxng-settings.yml` en el host antes del primer deploy |

`sandbox-tls` es un volumen Docker nombrado (no bind mount) con los
certificados mTLS internos del sandbox — se regenera solo si se recrea
desde cero (no hace falta respaldarlo).

`searxng-settings.yml` se monta desde `BASE_DIR` y no directo desde el
repo (`./searxng-settings.yml`) porque el clon que Portainer hace por
GitOps puede terminar con ese path convertido en un directorio vacío: si
el archivo no estaba ahí en el primer `docker compose up` (por ejemplo,
un deploy que corrió antes de que el commit con el archivo llegara),
Docker crea un directorio en su lugar, y un `git pull` sin commits nuevos
no lo repara solo (git no ve drift si no hay nada nuevo que traer). Si se
edita el contenido del `searxng-settings.yml` de este repo, hay que volver
a copiarlo a mano a `${BASE_DIR}/searxng-settings.yml` en el host — no se
sincroniza solo con el redeploy de Portainer.

## Depende de
- `ollama` (vía la red externa `ollama_ollama-net`) para el modelo del AI
  Assistant — **desplegar `ollama` primero**, y tener el modelo ya
  descargado con `ollama pull` antes de activar el AI Assistant en la UI.
- `proxy` para salir a internet — requiere que `n8nkamehousecr.ddns.net`
  esté en `EXTRA_DOMAINS` del stack `proxy` (ver más abajo).

## Dominio: por qué uno propio y no subcarpeta
`kamehousecr.ddns.net/n8n/` no se usó porque la documentación oficial de
n8n no confirma soporte de subpath/subcarpeta (solo documenta dominio raíz
o subdominio dedicado) — mismo motivo por el que `immich-app` ya usa un
dominio propio en este repo (`photoskamehousecr.ddns.net`). Se sigue el
mismo patrón: **hay que registrar un tercer hostname gratuito en
noip.com**, `n8nkamehousecr.ddns.net`, apuntando a la misma IP pública, y
agregarlo a `EXTRA_DOMAINS` en las variables del stack `proxy` (separado
por coma del resto, ver `../../proxy/.env.example`). Comparte el mismo
certificado Let's Encrypt que el dominio base.

## Primer login y AI Assistant
- n8n ya no usa basic auth: el primer acceso a
  `https://n8nkamehousecr.ddns.net/` pide crear la cuenta *owner* desde la
  propia UI.
- El AI Assistant queda con el módulo habilitado (`N8N_ENABLED_MODULES`) y
  el sandbox conectado, pero **el modelo hay que confirmarlo en la UI**
  después del primer login — el valor de `N8N_INSTANCE_AI_MODEL` en el
  compose (`openai/${OLLAMA_MODEL}`) es la mejor interpretación posible de
  la doc oficial para un endpoint local tipo Ollama; si no conecta, ajustar
  ahí mismo.
- `OLLAMA_MODEL` acá debe ser el mismo valor que el modelo ya descargado en
  el stack `ollama` (variable separada, Portainer no comparte env vars
  entre stacks).
- El compose fija `OPENAI_API_KEY` con un valor dummy hardcodeado (no es
  secreto real): el cliente OpenAI que usa el AI Assistant exige una key
  no vacía aunque el endpoint sea Ollama local — sin esto falla con
  `Error: OpenAI API key is missing`. Ollama no valida el valor.

## Migrar un despliegue existente de sqlite a Postgres
Si este stack ya corría con el sqlite por defecto (sin `DB_TYPE` en el
compose), pasar a Postgres arranca una base nueva y vacía — n8n no migra
datos automáticamente entre motores. Antes de redesplegar con este cambio,
exportar los workflows/credenciales existentes desde la UI (o respaldar
`${BASE_DIR}/n8n/database.sqlite`) y volver a importarlos ya con Postgres
activo.

## Componente sensible: `sandbox-runner-1`
Corre con `privileged: true` (Docker-in-Docker) — equivalente a root en el
host. Por eso, a diferencia del resto de servicios de este repo, **no
lleva el label de watchtower**: se actualiza a mano, revisando el
changelog de `n8n-sandbox-service` antes de subir de versión. `sandbox-api`
tampoco lo lleva por la misma razón (es su control plane). Ninguno de los
dos recibe `env_file` completo — solo las variables puntuales que
necesitan, explícitas en el compose.

## Nombre del stack en Portainer
`n8n` — fijado explícito con `name: n8n` en el compose (no depende del
nombre de carpeta que le dé Portainer), igual que hace `immich-app`.

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`.
