MAINTAINER=mcgr0g
ASSEMBLY_NAME=zapret-docker
IMG_NAME=$(MAINTAINER)/$(ASSEMBLY_NAME)
# VERSIONS ---------------------------------------------------------------------
ASSEMBLY_VER=0.0.2
ASSEMBLY_DATE:=$(shell date '+%Y-%m-%d')


# BUILD FLAGS -----------------------------------------------------------------
BFLAGS=docker build \
		--build-arg assembly_ver=$(ASSEMBLY_VER) \
		--build-arg assembly_date=$(ASSEMBLY_DATE) \
		--build-arg assembly_name=$(ASSEMBLY_NAME) \
		-t $(IMG_NAME):$(ASSEMBLY_VER)

BUILD_FAST=$(BFLAGS) .
BUILD_FULL=$(BFLAGS) --no-cache --progress=plain .

# IMAGE -----------------------------------------------------------------------

build:
	$(BUILD_FAST)
	
build-full:
	$(BUILD_FULL)

img-get-size-final:
	docker images \
	-f "label=org.opencontainers.image.title=$(ASSEMBLY_NAME)" \
	-f "label=org.opencontainers.image.version=$(ASSEMBLY_VER)" \
	--format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}\t{{.Size}}" \
	$(IMG_NAME):$(ASSEMBLY_VER)

img-get-size-layered:
	docker history -H $(IMG_NAME):$(ASSEMBLY_VER)

login:
	docker login

prepush:
	docker tag $(IMG_NAME):$(ASSEMBLY_VER) $(IMG_NAME):latest

push:
	docker push $(IMG_NAME) --all-tags

pull:
	docker pull $(IMG_NAME)

# RUN FLAGS -------------------------------------------------------------------

CURR_PUID=$(shell id -u)
CURR_PGID=$(shell id -g)

IMITROOTLESS=mkdir ${PWD}/cache && mkdir ${PWD}/config

RUNBASE=docker-compose
RUNFIN=up

RUN=$(RUNBASE) $(RUNFIN)
RUN_TWPS=$(RUNBASE) -f compose-twps.yaml $(RUNFIN)
RUN_ALL=$(RUNBASE) -f compose-all.yaml $(RUNFIN)

# CONTAINER -------------------------------------------------------------------

volumes:
	- mkdir ${PWD}/cache && mkdir ${PWD}/config

run: volumes
	$(RUN_TWPS)

flop:
	docker exec -it $(ASSEMBLY_NAME) /bin/sh

clear:
	rm -rf cache/
	rm -rf config/