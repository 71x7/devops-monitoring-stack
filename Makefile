.PHONY: help setup up down restart logs ps validate reload

help: ## Muestra esta ayuda
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-10s %s\n", $$1, $$2}'

setup: ## Crea el archivo .env a partir de .env.example
	@test -f .env || (cp .env.example .env && echo ".env creado: edita GRAFANA_PASSWORD antes de levantar el stack")

up: ## Levanta todo el stack
	docker compose up -d

down: ## Detiene el stack (los datos se conservan)
	docker compose down

restart: ## Reinicia el stack
	docker compose restart

logs: ## Sigue los logs de todos los servicios
	docker compose logs -f --tail=100

ps: ## Estado de los contenedores
	docker compose ps

reload: ## Recarga la config de Prometheus sin reiniciar
	curl -fsS -X POST http://localhost:9090/-/reload && echo "Prometheus recargado"

validate: ## Valida compose, Prometheus, alertas y Alertmanager
	docker compose --env-file .env.example config -q
	docker run --rm --entrypoint promtool -v "$(CURDIR)/prometheus:/etc/prometheus:ro" prom/prometheus:v2.55.1 check config /etc/prometheus/prometheus.yml
	docker run --rm --entrypoint amtool -v "$(CURDIR)/alertmanager:/etc/alertmanager:ro" prom/alertmanager:v0.27.0 check-config /etc/alertmanager/alertmanager.yml
	python3 -m json.tool grafana/dashboards/overview.json > /dev/null && echo "Dashboard JSON OK"
