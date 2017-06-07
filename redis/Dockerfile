# https://hub.docker.com/_/redis?tab=tags
FROM redis:latest

ARG DEV_ENVIRONMENT=${DEV_ENVIRONMENT}
ARG REDIS_PORT=${REDIS_PORT}

# prevent error like 'debconf: unable to initialize frontend: Dialog' because not all packages support 'interactive' mode
# change the way debconf (Debian Package Configuration System) configures packages
# 'noninteractive' is needed for the build steps as all packages must work in noninteractive mode as well
ENV DEBIAN_FRONTEND noninteractive

# if DEV_ENVIRONMENT = true, install dev tools
RUN if [ ${DEV_ENVIRONMENT} = true ]; then \
    \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        bash \
        mlocate \
        net-tools \
        vim \
        curl \
        sudo \
        wget \
        tcpdump \
        telnet \
        procps \
        inetutils-ping \
    && update-alternatives --set editor /usr/bin/vim.basic \
;fi

# !imporant!
# fall back to the 'teletype' for  debconf
# this way both interactive and non-interactive modes get set
# 'teletype' is needed for interactive configuration steps the user might want to do inside a running container
ENV DEBIAN_FRONTEND teletype

# redis
EXPOSE ${REDIS_PORT}
