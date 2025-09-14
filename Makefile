PROJECT_SOURCE_DIR ?= $(abspath ./)
PROJECT_NAME ?= $(shell basename $(PROJECT_SOURCE_DIR))
BASH_REPL := /bin/bash -c "umask 0000 && exec bash"
BASH_HIST ?= $(PROJECT_SOURCE_DIR)/.bash_history

all:
	@echo nothing special

clean:
	rm -rf build dist *.egg-info __pycache__ *.pyc

DOCKER_TAG_RELEASE := ghcr.io/district10/must3r/base:v2025.09.14
docker_build:
	docker build -t $(DOCKER_TAG_RELEASE) \
        -f Dockerfile .
	docker images $(DOCKER_TAG_RELEASE) --format "{{.Repository}}:{{.Tag}} -> {{.Size}}"
docker_push:
	docker push $(DOCKER_TAG_RELEASE)
docker_pull:
	docker pull $(DOCKER_TAG_RELEASE)
docker_test:
	docker run --rm --privileged -v `pwd`:`pwd` -w `pwd` -it $(DOCKER_TAG_RELEASE) $(BASH_REPL)

DEV_CONTAINER_NAME ?= $(USER)_$(subst /,_,$(PROJECT_NAME)____$(PROJECT_SOURCE_DIR))
DEV_CONTAINER_IMAG ?= $(DOCKER_TAG_RELEASE)
test_in_dev_container:
	umask 0000 && touch $(BASH_HIST)
	docker volume inspect cursor-server >/dev/null 2>&1 || (echo -e "\033[0;32mCreating cursor-server volume...\033[0m" && docker volume create cursor-server)
	docker volume inspect vscode-server >/dev/null 2>&1 || (echo -e "\033[0;32mCreating vscode-server volume...\033[0m" && docker volume create vscode-server)
	docker ps | grep $(DEV_CONTAINER_NAME) \
		&& docker exec -it $(DEV_CONTAINER_NAME) $(BASH_REPL) \
		|| docker run --rm --name $(DEV_CONTAINER_NAME) \
			--network host --security-opt seccomp=unconfined \
			-v $(BASH_HIST):/root/.bash_history \
			-v cursor-server:/root/.cursor-server \
			-v vscode-server:/root/.vscode-server \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v `pwd`:`pwd`:rshared -w `pwd` \
			-it $(DEV_CONTAINER_IMAG) \
			$(BASH_REPL)
