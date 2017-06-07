FROM mariadb:latest

ARG DEV_ENVIRONMENT=${DEV_ENVIRONMENT}

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

# copy setup_gitlab_user to the mariadb init directory
COPY setup_gitlab_user.sql /docker-entrypoint-initdb.d

EXPOSE 3306
