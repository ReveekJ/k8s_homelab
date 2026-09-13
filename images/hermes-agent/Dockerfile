FROM python:3.12-slim

ARG HERMES_INSTALL_URL=https://hermes-agent.nousresearch.com/install.sh
ARG HERMES_INSTALL_BRANCH=main
ARG HERMES_INSTALL_COMMIT=""

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
       git \
       openssh-client \
       procps \
       tini \
    && rm -rf /var/lib/apt/lists/*

ENV HERMES_HOME=/hermes \
    HOME=/hermes \
    PATH="/hermes/hermes-agent/venv/bin:${PATH}"

RUN curl -sfL "${HERMES_INSTALL_URL}" -o /tmp/install.sh \
    && HERMES_HOME=/hermes bash /tmp/install.sh \
       --skip-setup \
       --skip-browser \
       --skip-computer-use \
       --branch "${HERMES_INSTALL_BRANCH}" \
       $( [ -n "${HERMES_INSTALL_COMMIT}" ] && echo --commit "${HERMES_INSTALL_COMMIT}" ) \
    && rm -f /tmp/install.sh \
    && /hermes/hermes-agent/venv/bin/hermes --version

WORKDIR /srv/projects

ENTRYPOINT ["/usr/bin/tini", "--", "hermes"]
