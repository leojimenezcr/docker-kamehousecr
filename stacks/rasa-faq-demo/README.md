# rasa-faq-demo

## Qué hace
Demo de chatbot FAQ: `rasa` (motor NLU/bot) + `webchat` (widget estático
servido con `nginx:alpine`).

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| rasa | — (5005 comentado/deshabilitado) | 5005 |
| webchat | 8080 | 80 |

## Volúmenes
| Variable | Monta en | Descripción |
|---|---|---|
| `RASA_FAQ_APP_DIR` | `/app` (rasa) | Modelos y config de Rasa |
| `RASA_FAQ_WEBCHAT_INDEX_FILE` | `/usr/share/nginx/html/index.html` (webchat) | HTML estático del widget |

## Depende de
`webchat` depende de `rasa` (mismo stack).

## Nombre del stack en Portainer
`rasa-faq-demo` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`.

## ⚠ Conflicto conocido (no resuelto aquí)
`webchat` publica el puerto de host `8080`, igual que `open-webui` del stack
`stacks/ollama`. No pueden correr simultáneamente sin colisión de puerto.
Ver `../../docs/ARCHITECTURE.md`.
