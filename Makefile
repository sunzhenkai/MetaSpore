.PHONY: dev training

REPOSITORY := sunzhenkai
VERSION := 0.0.1
RUNTIME := cpu
FIX_ARG := --network host --build-arg RUNTIME=$(RUNTIME) --build-arg http_proxy=${http_proxy} --build-arg https_proxy=${https_proxy}
DOCKER_CMD := DOCKER_BUILDKIT=1 docker build $(FIX_ARG)

DEV_IMAGE := $(REPOSITORY)/metaspore-dev-cpu:$(VERSION)
TRAINING_BUILD_IMAGE := $(REPOSITORY)/metaspore-training-build:$(VERSION)
TRAINING_RELEASE_IMAGE := $(REPOSITORY)/metaspore-training-release:$(VERSION)

dev:
	@$(DOCKER_CMD) $(FIX_ARG) -f docker/ubuntu20.04/Dockerfile_dev -t $(DEV_IMAGE) .

training: dev
	@DOCKER_BUILDKIT=1 docker build $(FIX_ARG) -f docker/ubuntu20.04/Dockerfile_training_build --build-arg DEV_IMAGE=$(DEV_IMAGE) -t $(TRAINING_BUILD_IMAGE) .
	@DOCKER_BUILDKIT=1 docker build $(FIX_ARG) -f docker/ubuntu20.04/Dockerfile_training_release --build-arg METASPORE_RELEASE=build --build-arg METASPORE_BUILD_IMAGE=$(TRAINING_BUILD_IMAGE) -t $(TRAINING_RELEASE_IMAGE) --target release .
