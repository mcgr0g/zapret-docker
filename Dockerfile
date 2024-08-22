FROM docker.io/alpine AS build

RUN apk add --no-cache build-base zlib-dev bsd-compat-headers libcap-dev libnetfilter_queue-dev nftables
WORKDIR /src/zapret
COPY src .
RUN make

FROM docker.io/alpine AS tpws
ARG assembly_ver
ARG assembly_name
ARG assembly_date=$(date +%Y-%m-%d)

COPY --from=build /src/zapret/tpws/tpws /usr/local/bin/
RUN adduser -SH tpws
USER tpws
EXPOSE 1080

ENTRYPOINT ["tpws"]

LABEL org.opencontainers.image.authors="Ronnie McGrog" \
    org.opencontainers.image.url="https://hub.docker.com/repository/docker/mcgr0g/zapret-docker/general" \
    org.opencontainers.image.documentation="https://github.com/mcgr0g/zapret-docker/readme.md" \
    org.opencontainers.image.source="https://github.com/mcgr0g/zapret-docker" \
    org.opencontainers.image.title="${assembly_name}" \
    org.opencontainers.image.description="tpws assembly from bol-van/zapret" \
    org.opencontainers.image.version="${assembly_ver}" \
    org.opencontainers.image.created="${assembly_date}"
