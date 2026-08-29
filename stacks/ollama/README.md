# ollama

## Qué hace
Sirve modelos LLM localmente (Ollama). Existe únicamente para que el AI
Assistant del stack `n8n` use un modelo propio en vez de un proveedor en
la nube (OpenAI/Anthropic/OpenRouter) — no se expone públicamente ni tiene
UI propia en este setup.

## Hardware del host y elección de modelo
El NUC del homelab (Intel i5-1240P, 12 núcleos/16 hilos, 16 GB RAM, sin GPU
dedicada — solo iGPU Intel, que la imagen oficial de Ollama no acelera) hace
la inferencia **por CPU**. Es viable para automatizaciones puntuales de
n8n, no para uso tipo chat interactivo intensivo.

Modelo recomendado por defecto: **`qwen2.5:7b-instruct`** — soporta tool
calling (lo necesita el AI Assistant), ~4.7 GB de pesos, corre razonable en
este hardware. Si resulta muy lento, alternativas más livianas:
`qwen2.5:3b-instruct` o `llama3.2:3b` (tool calling más limitado).

**El nombre del modelo elegido acá debe coincidir exacto con la variable
`OLLAMA_MODEL` del stack `n8n`** (ver `../n8n/.env.example` y
`../n8n/README.md`) — Portainer no comparte variables entre stacks, hay que
cargar el mismo valor en ambos.

## Paso manual tras el primer deploy
La imagen no descarga ningún modelo por sí sola. Después de desplegar el
stack, en el host:
```bash
docker exec -it ollama ollama pull qwen2.5:7b-instruct
```
(sustituir por el modelo elegido). Para probarlo suelto:
```bash
docker exec -it ollama ollama run qwen2.5:7b-instruct "hola"
```

## Puertos
Ninguno expuesto al host — solo accesible dentro de la red docker
`ollama-net`.

## Volúmenes
| Variable | Monta en | Descripción |
|---|---|---|
| `BASE_DIR` (`/models`) | `/root/.ollama` | Modelos descargados y config de Ollama |

## Depende de
Ninguno. Consumido por: `n8n` (AI Assistant), vía la red externa
`ollama_ollama-net`.

## Nombre del stack en Portainer
`ollama` — fijado explícito con `name: ollama` en el compose (no depende
del nombre de carpeta que le dé Portainer), igual que hace `immich-app`
para su propio proyecto.

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`.
