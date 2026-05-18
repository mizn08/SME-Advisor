.PHONY: up down build logs restart init-db health tools clean

COMPOSE := docker compose
ENV_FILE := --env-file .env

up:
	$(COMPOSE) $(ENV_FILE) up -d --build

down:
	$(COMPOSE) $(ENV_FILE) down

build:
	$(COMPOSE) $(ENV_FILE) build --no-cache

logs:
	$(COMPOSE) $(ENV_FILE) logs -f backend db

restart:
	$(COMPOSE) $(ENV_FILE) restart backend

init-db:
	$(COMPOSE) $(ENV_FILE) exec backend python /app/scripts/init_db.py

health:
	curl -fsS http://localhost:8000/health && echo

tools:
	$(COMPOSE) $(ENV_FILE) --profile tools up -d pgadmin

clean:
	$(COMPOSE) $(ENV_FILE) down -v
