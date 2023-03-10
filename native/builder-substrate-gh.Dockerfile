## Build Args - Metavariant
ARG BASE_IMAGE_NAME

FROM ${BASE_IMAGE_NAME}

## Bases
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-transport-https \
    jq \
    libicu-dev \
    libkrb5-dev \
    liblttng-ust-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## Local argument from Metavariant args
ARG CPU_ARCH
ARG CPU_ARCH_ALT
ARG CPU_NAME
ARG RUNNER_VER
ENV RUNNER_ALLOW_RUNASROOT="1"
RUN test -n "${CPU_ARCH:?}" && \
    test -n "${CPU_ARCH_ALT:?}" && \
    test -n "${CPU_NAME:?}" && \
    test -n "${RUNNER_VER:?}"

## Github Action Runner
WORKDIR /builder/ghrunner
RUN wget \
    -c "https://github.com/actions/runner/releases/download/v${RUNNER_VER}/actions-runner-linux-${CPU_ARCH_ALT}-${RUNNER_VER}.tar.gz" \
    -O - | tar -xzf - -C /builder/ghrunner

COPY builder-substrate-gh.bash runner-start.bash
RUN chmod +x runner-start.bash

LABEL maintainer "Aditya Kresna <kresna@gemtek.id>"
LABEL org.opencontainers.image.source "https://github.com/gemtek-indonesia/gi-docker-images"
LABEL org.opencontainers.image.description "This is a Github Action version of Parity's Substrate Builder for `${CPU_ARCH}-${CPU_NAME}`"

ENTRYPOINT [ "./runner-start.bash" ]
