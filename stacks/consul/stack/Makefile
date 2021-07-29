SHELL := /bin/bash -e

export PROJECT_NAME="vault-stack"

ifndef BRANCH_NAME
	BRANCH_NAME = $(shell git rev-parse --abbrev-ref HEAD)
endif

export BRANCH_NAME

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

create-network: ## Creates core external network
	docker network create -d overlay --attachable core

deploy:
	docker stack deploy --with-registry-auth -c=deploy-stack.yml ${PROJECT_NAME}-${BRANCH_NAME}

teardown:
	docker stack rm ${PROJECT_NAME}-${BRANCH_NAME}