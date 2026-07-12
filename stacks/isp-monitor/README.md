# isp-monitor

## Qué hace
Monitoreo de conectividad ISP: `blackbox-exporter` (sondas de red),
`prometheus` (scraping/almacenamiento de métricas) y `grafana` (dashboards).

## Puertos
| Servicio (contenedor) | Puerto host | Puerto contenedor |
|---|---|---|
| blackbox-exporter | — (sin puerto de host, solo interno al stack) | 9115 |
| prometheus | — (sin puerto de host, expuesto vía proxy) | 9090 |
| grafana | — (sin puerto de host, expuesto vía proxy) | 3000 |

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
`blackbox-exporter`. Todo interno al mismo stack, vía la red
`isp-monitor-internal-net`.

Depende del stack `proxy` para exponerse hacia afuera vía la red
`isp-monitor-net`, que este stack crea (`grafana` y `prometheus` la
usan, `blackbox-exporter` no) y que `proxy/docker-compose.yml` consume como
`external: true`. Expuestos en `https://kamehousecr.ddns.net/grafana/` y
`https://kamehousecr.ddns.net/prometheus/` (método de subcarpeta, soportado
oficialmente por ambos vía `GF_SERVER_ROOT_URL`/`GF_SERVER_SERVE_FROM_SUB_PATH`
y `--web.external-url`/`--web.route-prefix` respectivamente — ver
`docker-compose.yml`). `blackbox-exporter` queda sin exponer: su página web
no soporta subpath (links absolutos) y no tiene caso de uso público, solo lo
consume `prometheus` internamente.

**Orden de despliegue**: si `isp-monitor-net` todavía no existe en el
host, desplegar este stack primero (crea la red) antes de que `proxy` la
consuma como `external: true`, o el deploy de `proxy` va a fallar.

## Nombre del stack en Portainer
`isp-monitor` (asumido = nombre de carpeta, verificar contra la UI real).

## Variables de entorno
Ver `.env.example` en esta misma carpeta y la tabla correspondiente en
`../../docs/PORTAINER-SETUP.md`.
