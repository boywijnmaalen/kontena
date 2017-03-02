FROM mariadb:latest

ARG DEV_ENVIRONMENT=${DEV_ENVIRONMENT}

# if DEV_ENVIRONMENT = true, install dev tools
RUN if [ ${DEV_ENVIRONMENT} = true ]; then \

    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        bash \
        mlocate \
        net-tools \
        vim \
;fi

EXPOSE 3306
