
#DOCKER_COMPOSE_FILE ?= ./docker-compose.yml
DOCKER_COMPOSE_FILE ?= ./docker-compose.cluster.yml

network-list:
	@docker network ls;

volume-list:
	@docker volume ls;

volume-create-path:
	@mkdir -p "${PWD}/volumes/certificates";
	@mkdir -p "${PWD}/volumes/mssql01/data";
	@mkdir -p "${PWD}/volumes/mssql02/data";
	@mkdir -p "${PWD}/volumes/mssql03/data";
	@mkdir -p "${PWD}/volumes/mssql-single/data";

volume-remove-path:
	@rm -rf "${PWD}/volumes";

volume-remove-mssql01:
	@docker volume rm -f quickstart-mssql_vol_mssql01;

volume-remove-mssql02:
	@docker volume rm -f quickstart-mssql_vol_mssql02;

volume-remove-mssql03:
	@docker volume rm -f quickstart-mssql_vol_mssql03;

volume-remove-mssql-single:
	@docker volume rm -f quickstart-mssql_vol_mssql_single;

volume-remove-certificates:
	@docker volume rm -f quickstart-mssql_vol_certificates;

config:
	@docker-compose --file $(DOCKER_COMPOSE_FILE) config;

images:
	@docker-compose --file $(DOCKER_COMPOSE_FILE) images;

build:
	@docker-compose --file $(DOCKER_COMPOSE_FILE) build;

up: volume-create-path
	@docker-compose --file $(DOCKER_COMPOSE_FILE) up -d;

stop:
	@docker-compose --file $(DOCKER_COMPOSE_FILE) stop;

start:
	@docker-compose --file $(DOCKER_COMPOSE_FILE) start;

restart:
	@docker-compose --file $(DOCKER_COMPOSE_FILE) restart;

destroy:
	@docker-compose --file $(DOCKER_COMPOSE_FILE) down;

list:
	@docker-compose --file $(DOCKER_COMPOSE_FILE) ps;

clear: volume-remove-path
	@docker-compose --file $(DOCKER_COMPOSE_FILE) rm -f;

clear-all: clear volume-remove-mssql01 volume-remove-mssql02 volume-remove-mssql03 volume-remove-certificates
