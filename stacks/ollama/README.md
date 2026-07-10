# ollama

## Qué hace
LLM local (Ollama) + interfaz web (Open WebUI).

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| ollama | 11434 | 11434 |
| open-webui | 8080 | 8080 |

## Volúmenes
`BASE_DIR` es la carpeta raíz de este stack en el host.

| Ruta | Monta en | Descripción |
|---|---|---|
| `${BASE_DIR}/ollama` | `/root/.ollama` | Modelos descargados |
| `${BASE_DIR}/ollama-webui` | `/app/backend/data` | Datos de Open WebUI |

## Depende de
`open-webui` depende de `ollama` (mismo stack).

## Nombre del stack en Portainer
`ollama` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`.

## ⚠ Conflicto conocido (no resuelto aquí)
`open-webui` publica el puerto de host `8080`, igual que `webchat` del stack
`stacks/rasa-faq-demo`. No pueden correr simultáneamente sin colisión de
puerto. Ver `../../docs/ARCHITECTURE.md`.
