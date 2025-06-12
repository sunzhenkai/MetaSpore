.PHONY: dev training serving jupyter code-server all

REPOSITORY := sunzhenkai
VERSION := latest
RUNTIME := cpu
FIX_ARG := --network host --build-arg RUNTIME=$(RUNTIME) --build-arg http_proxy=${http_proxy} --build-arg https_proxy=${https_proxy}
DOCKER_CMD := DOCKER_BUILDKIT=1 docker build $(FIX_ARG)

DEV_IMAGE := $(REPOSITORY)/metaspore-dev-$(RUNTIME):$(VERSION)
TRAINING_BUILD_IMAGE := $(REPOSITORY)/metaspore-training-build:$(VERSION)
TRAINING_RELEASE_IMAGE := $(REPOSITORY)/metaspore-training-release:$(VERSION)
SERVING_BUILD_IMAGE := $(REPOSITORY)/metaspore-serving-build:$(VERSION)
SERVING_RELEASE_IMAGE := $(REPOSITORY)/metaspore-serving-release:$(VERSION)
JUPYTER_IMAGE := $(REPOSITORY)/metaspore-training-jupyter:$(VERSION)
CODESERVER_IMAGE := $(REPOSITORY)/metaspore-codeserver:$(VERSION)

dev:
	@$(DOCKER_CMD) $(FIX_ARG) -f docker/ubuntu20.04/Dockerfile_dev -t $(DEV_IMAGE) .

training: dev
	@DOCKER_BUILDKIT=1 docker build $(FIX_ARG) -f docker/ubuntu20.04/Dockerfile_training_build --build-arg DEV_IMAGE=$(DEV_IMAGE) -t $(TRAINING_BUILD_IMAGE) .
	@DOCKER_BUILDKIT=1 docker build $(FIX_ARG) -f docker/ubuntu20.04/Dockerfile_training_release --build-arg METASPORE_RELEASE=build --build-arg METASPORE_BUILD_IMAGE=$(TRAINING_BUILD_IMAGE) -t $(TRAINING_RELEASE_IMAGE) --target release .

serving: dev
	@DOCKER_BUILDKIT=1 docker build $(FIX_ARG) -f docker/ubuntu20.04/Dockerfile_serving_build --build-arg DEV_IMAGE=$(DEV_IMAGE) -t $(SERVING_BUILD_IMAGE) .
	@DOCKER_BUILDKIT=1 docker build $(FIX_ARG) -f docker/ubuntu20.04/Dockerfile_serving_release --build-arg BUILD_IMAGE=$(SERVING_BUILD_IMAGE) -t $(SERVING_RELEASE_IMAGE) --target serving_release .

jupyter:
	@DOCKER_BUILDKIT=1 docker build $(FIX_ARG) -f docker/ubuntu20.04/Dockerfile_jupyter --build-arg RELEASE_IMAGE=$(TRAINING_RELEASE_IMAGE) -t $(JUPYTER_IMAGE) docker/ubuntu20.04

code-server:
	@DOCKER_BUILDKIT=1 docker build $(FIX_ARG) -f docker/ubuntu20.04/Dockerfile_codeserver --build-arg RELEASE_IMAGE=$(TRAINING_RELEASE_IMAGE) -t $(CODESERVER_IMAGE) docker/ubuntu20.04

all: dev training serving jupyter code-server
