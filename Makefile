
ifneq ($(shell which docker-compose 2>/dev/null),)
    DOCKER_COMPOSE := docker-compose
else
    DOCKER_COMPOSE := docker compose
endif

help: 
	@echo "================================================"
	@echo "Sage.Education/AI by Startr.Cloud and Open WebUI"
	@echo "================================================"
	@echo ""
	@echo 'This is the default make command.' 
	@echo "This command lists available make commands."
	@echo ""
	@echo "Usage example:"
	@echo "    make it_run"
	@echo ""
	@echo "Available make commands:"
	@echo ""
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'
	@echo ""	

it_run:
	docker run --rm -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name ai-web-openwebui ai-web-openwebui

it_build:
	docker build -t ai-web-openwebui .

it_build_n_run:
	docker build -t ai-web-openwebui . && docker run --rm -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name ai-web-openwebui ai-web-openwebui

it_build_no_cache:
	docker build --no-cache -t ai-web-openwebui .

it_build_n_run_no_cache:
	docker build --no-cache -t ai-web-openwebui . && docker run --rm -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name ai-web-openwebui ai-web-openwebui

it_install:
	$(DOCKER_COMPOSE) up -d

minor_release:
	# Start a minor release with incremented minor version
	git flow release start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1"."$$2+1".0"}')

patch_release:
	# Start a patch release with incremented patch version
	git flow release start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1"."$$2"."$$3+1}')

major_release:
	# Start a major release with incremented major version
	git flow release start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1+1".0.0"}')

hotfix:
	# Start a hotfix with incremented patch version
	git flow hotfix start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1"."$$2"."$$3+1}')

release_finish:
	git flow release finish "$$(git branch --show-current | sed 's/release\///')" && git push origin develop && git push origin master && git push --tags && git checkout develop

hotfix_finish:
	git flow hotfix finish "$$(git branch --show-current | sed 's/hotfix\///')" && git push origin develop && git push origin master && git push --tags && git checkout develop

things_clean:
	git clean --exclude=!.env -Xdf


remove:
	@chmod +x confirm_remove.sh
	@./confirm_remove.sh

start:
	$(DOCKER_COMPOSE) start
startAndBuild: 
	$(DOCKER_COMPOSE) up -d --build

stop:
	$(DOCKER_COMPOSE) stop

update:
	# Calls the LLM update script
	chmod +x update_ollama_models.sh
	@./update_ollama_models.sh
	@git pull
	$(DOCKER_COMPOSE) down
	# Make sure the ollama-webui container is stopped before rebuilding
	@docker stop open-webui || true
	$(DOCKER_COMPOSE) up --build -d
	$(DOCKER_COMPOSE) start

