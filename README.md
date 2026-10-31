# 📈 DevOps Monitoring Stack

Stack de monitoreo listo para usar con Docker Compose: métricas del servidor y de los contenedores, dashboard y alertas ya configurados. Se levanta con un solo comando.

![CI](https://github.com/71x7/devops-monitoring-stack/actions/workflows/ci.yml/badge.svg)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?logo=grafana&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue)

## Arquitectura

```
 node-exporter ─┐
                ├──▶ Prometheus ──▶ Grafana (dashboards)
 cAdvisor ──────┘        │
                         └──▶ Alertmanager (alertas)
```

| Servicio | Función | Puerto (solo localhost) |
|---|---|---|
| Prometheus | Recolecta y almacena métricas, evalúa alertas | 9090 |
| Grafana | Dashboards (provisionado automáticamente) | 3000 |
| Alertmanager | Agrupa y enruta alertas | 9093 |
| node-exporter | Métricas del host: CPU, RAM, disco, red | interno |
| cAdvisor | Métricas por contenedor | interno |

## Inicio rápido

Requisitos: Docker con el plugin Compose.

```bash
git clone https://github.com/71x7/devops-monitoring-stack.git
cd devops-monitoring-stack
make setup            # crea .env; edita GRAFANA_PASSWORD
make up
```

Abre Grafana en http://localhost:3000. El dashboard **Servidor y contenedores** ya aparece en la carpeta *Infraestructura*.

## Comandos

```
make up         Levanta el stack
make down       Lo detiene (los datos se conservan en volúmenes)
make logs       Sigue los logs
make ps         Estado de los contenedores
make reload     Recarga la config de Prometheus sin reiniciar
make validate   Valida compose, Prometheus, alertas y Alertmanager
```

## Alertas incluidas

| Alerta | Condición | Severidad |
|---|---|---|
| InstanciaCaida | Un target no responde por 2 min | critical |
| CPUAlta | CPU > 85% durante 10 min | warning |
| MemoriaAlta | RAM > 90% durante 5 min | warning |
| DiscoCasiLleno | Disco > 85% durante 10 min | warning |
| DiscoSeLlenaraEn24h | Predicción lineal: se llena en menos de 24 h | critical |

Alertmanager agrupa por alerta e instancia, y silencia las alertas secundarias de una instancia que ya está caída. Para recibir avisos en Slack, Telegram o un webhook, descomenta la sección correspondiente en `alertmanager/alertmanager.yml`.

## Monitorear más servidores

Instala `node_exporter` en cada servidor y agrégalo en `prometheus/prometheus.yml`:

```yaml
- job_name: servidores
  static_configs:
    - targets: ["10.0.0.11:9100", "10.0.0.12:9100"]
```

Luego `make reload`.

## Seguridad

- Todos los puertos publicados escuchan solo en `127.0.0.1`. Para acceder desde fuera usa un reverse proxy con HTTPS (Nginx, Caddy o Traefik) o un túnel SSH.
- La contraseña de Grafana es obligatoria: el stack no arranca si `GRAFANA_PASSWORD` no está definida.
- `.env` está en `.gitignore`. Nunca subas credenciales al repositorio.
- Las versiones de las imágenes están fijadas para que los despliegues sean reproducibles.

## CI

Cada push valida con GitHub Actions: sintaxis de Docker Compose, `promtool check config` (incluye las reglas de alerta), `amtool check-config`, el JSON del dashboard y `yamllint`.

## Estructura

```
├── docker-compose.yml
├── prometheus/          # config y reglas de alerta
├── alertmanager/        # enrutamiento de alertas
├── grafana/
│   ├── provisioning/    # datasource y proveedor de dashboards
│   └── dashboards/      # dashboards en JSON
├── Makefile
└── .github/workflows/ci.yml
```

## Próximos pasos

- [ ] Blackbox exporter para monitorear URLs y puertos
- [ ] Loki + Promtail para centralizar logs
- [ ] Reverse proxy con HTTPS (Caddy)
- [ ] Playbook de Ansible para desplegar el stack

## Licencia

MIT, consulta [LICENSE](LICENSE).
