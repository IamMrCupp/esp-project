###################################################################################################
# Makefile to control building images for docker/k8s use 
#  -  Emotional Support Pizza 
###################################################################################################
###############################################################################
#   Variables and Constants
###############################################################################
# enable the use of buildkit for multiarch builds
export DOCKER_BUILDKIT=1

# git related stuff here
GIT_TAG?=$(shell git rev-parse --short HEAD)
GIT_REPO?=$(shell git rev-parse --show-toplevel | awk -F '/' '{print $$NF}')

# Docker stuff
HUB_USER?=iammrcupp
HUB_REPO?=${GIT_REPO}
HUB_PULL_SECRET?=$(shell docker secret list | grep DockerHub | cut -f1 -d' ')
TAG?=${GIT_TAG}
DEV_IMAGE?=${HUB_REPO}:latest
PROD_IMAGE?=${HUB_USER}/${HUB_REPO}:${TAG}
PROD_IMAGE_LATEST?=${HUB_USER}/${HUB_REPO}:latest
BUILDX_PLATFORMS?=linux/amd64,linux/arm64,linux/arm/v6,linux/arm/v7,linux/riscv64,linux/386

###############################################################################
#   make stuff here
###############################################################################
# build image locally and use it for DEV purposes
.PHONY: dev 
dev: 
	@COMPOSE_DOCKER_CLI_BUILD=1 IMAGE=${DEV_IMAGE} docker-compose -f docker-compose.yaml up --build

# run unit tests
.PHONY: build-test unit-test test
unit-test:
	@docker --context default build --progress plain --target test .

test: unit-test


# build production image
.PHONY: build
build:
	@docker --context default build --target prod --tag ${PROD_IMAGE} .


# push the image to registry
.PHONY: push
push:
	@docker --context default push ${PROD_IMAGE}


# run PRODUCTION locally
.PHONY: deploy run logs down
run:
	@IMAGE=${PROD_IMAGE} docker-compose -f docker-compose.yaml up -d

logs:
	@IMAGE=${PROD_IMAGE} docker-compose -f docker-compose.yaml logs

down:
	@IMAGE=${PROD_IMAGE} docker-compose -f docker-compose.yaml down

deploy: build push check-env
	@HUB_PULL_SECRET=${HUB_PULL_SECRET} IMAGE=${PROD_IMAGE} docker compose up


# remove and cleanup DEV environment
.PHONY: clean
clean:
	@docker-compose -f docker-compose.yaml down
	@docker rmi ${DEV_IMAGE} || true
	@docker builder prune --force --filter type=exec.cachemount --filter unused-for=24h


.PHONY: check-env
check-env:
ifndef HUB_PULL_SECRET
	$(error HUB_PULL_SECRET is undefined. Ensure this has the proper API access token)
endif


# build multi-arch containers
.PHONY: cross-build cross-build-dev
cross-build:
	@docker buildx create --name mutiarchbuilder --use
	@docker buildx build --platform ${BUILDX_PLATFORMS} -t ${PROD_IMAGE} -t ${PROD_IMAGE_LATEST} --push .

cross-build-latest:
	@docker buildx create --name mutiarchbuilder --use
	@docker buildx build --platform ${BUILDX_PLATFORMS} -t ${PROD_IMAGE_LATEST} --push .

cross-build-dev: 
	@docker buildx create --name mutiarchbuilder --use
	@docker buildx build --platform ${BUILDX_PLATFORMS} -t ${DEV_IMAGE} .