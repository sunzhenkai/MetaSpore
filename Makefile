.PHONY: build 

REPOSITORY := sunzhenkai
VERSION := 0.0.1
RUNTIME := cpu

dev:
	DOCKER_BUILDKIT=1 docker build --network host --build-arg http_proxy=${http_proxy} --build-arg https_proxy=${https_proxy} --build-arg RUNTIME=$(RUNTIME) -f docker/ubuntu20.04/Dockerfile_dev -t $(REPOSITORY)/metaspore-dev-cpu:$(VERSION) .
