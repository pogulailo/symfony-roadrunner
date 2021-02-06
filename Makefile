#!/usr/bin/make

###> Variables ###
docker_bin := $(shell command -v docker 2> /dev/null)
compose_bin := $(shell command -v docker-compose 2> /dev/null)
app_service_name = app

CURRENT_USER = $(shell id -u):$(shell id -g)
RUN_APP_ARGS = --rm --user "$(CURRENT_USER)" "$(app_service_name)"
###< Variables ###

###> Special targets ###
.PHONY : help \
		 install init shell test test-cover \
		 up down restart logs clean git-hooks pull
.SILENT : help install up down shell
.DEFAULT_GOAL : help
###< Special targets ###

###> Commands ###
help:
	@printf "\033[33m%s:\033[0m\n" 'Available commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install all Application dependencies
	$(compose_bin) run -e STARTUP_WAIT_FOR_SERVICES=false $(RUN_APP_ARGS) \
		composer install --no-interaction --ansi --no-suggest --prefer-dist

clean: ## Clean Composer cache and remove Docker volumes
	-$(compose_bin) run -e STARTUP_WAIT_FOR_SERVICES=false $(RUN_APP_ARGS) composer clear
	$(compose_bin) down -v -t 5

shell: ## Start shell into Application container
	$(compose_bin) run -e STARTUP_WAIT_FOR_SERVICES=false $(RUN_APP_ARGS) sh

up: ## Create and start containers
	CURRENT_USER=$(CURRENT_USER) $(compose_bin) up -d

down: ## Stop and remove containers, networks, images, and volumes
	$(compose_bin) down -t 5

restart: down up ## Restart all containers

logs: ## Show Docker logs
	$(compose_bin) logs --follow
###< Commands ###
