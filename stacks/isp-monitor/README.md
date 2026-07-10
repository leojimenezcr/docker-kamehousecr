# isp-monitor

## Qué hace
Monitoreo de conectividad ISP: `blackbox-exporter` (sondas de red),
`prometheus` (scraping/almacenamiento de métricas) y `grafana` (dashboards).

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| blackbox-exporter | 9115 | 9115 |
| prometheus | 9090 | 9090 |
| grafana | 3000 | 3000 |

## Volúmenes
| Variable | Monta en | Descripción |
|---|---|---|
| `BASE_DIR` | `blackbox.yml`, `prometheus.yml`, `prometheus-data`, `grafana-data` | Configs y datos persistentes, todos bajo `${BASE_DIR}` |

`blackbox/blackbox.yml` y `prometheus/prometheus.yml` viven en esta misma
carpeta como referencia versionada; `prometheus.yml` tiene IPs del ISP
(gateway/DNS) hardcodeadas — fuera de alcance de esta reorganización (no es
parte del `docker-compose.yml`).

## Depende de
`grafana` usa `prometheus` como datasource; `prometheus` scrapea
`blackbox-exporter`. Todo interno al mismo stack.

## Nombre del stack en Portainer
`isp-monitor` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`.
