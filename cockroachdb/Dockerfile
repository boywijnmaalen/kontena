# https://hub.docker.com/r/phusion/baseimage/tags?name=bionic&page=1&ordering=last_updated
# 18.04 = bionic beaver
# 20.04 = focal fossa (not yet released by phusion
FROM phusion/baseimage:bionic-1.0.0

ARG BIN_PATH=/usr/local/bin/
ARG DEV_ENVIRONMENT=${DEV_ENVIRONMENT}
ARG COCKROACH_EXTERNAL_LIBS=/usr/local/lib/
ARG COCKROACH_LOG_DIR=${COCKROACH_LOG_DIR}
ARG COCKROACH_DATA_DIR=${COCKROACH_DATA_DIR}
ARG COCKROACH_PORT=${COCKROACH_PORT}
ARG COCKROACH_HTTP_PORT=${COCKROACH_HTTP_PORT}
ARG COCKROACH_LOCAL_USER=${COCKROACH_LOCAL_USER}
ARG COCKROACH_LOCAL_USER_PGUID=${COCKROACH_LOCAL_USER_PGUID}
ARG COCKROACH_LOCAL_USER_PUID=${COCKROACH_LOCAL_USER_PUID}
# https://www.cockroachlabs.com/docs/releases
ARG COCKROACH_VERSION=v20.2.4

# prevent error like 'debconf: unable to initialize frontend: Dialog' because not all packages support 'interactive' mode
# change the way debconf (Debian Package Configuration System) configures packages
# 'noninteractive' is needed for the build steps as all packages must work in noninteractive mode as well
ENV DEBIAN_FRONTEND noninteractive

# add a non-root user
RUN groupadd -g ${COCKROACH_LOCAL_USER_PGUID} ${COCKROACH_LOCAL_USER} \
    && useradd -m -u ${COCKROACH_LOCAL_USER_PUID} -g ${COCKROACH_LOCAL_USER_PGUID} ${COCKROACH_LOCAL_USER}

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

# install tzdata (GO requirement)
# https://go.crdb.dev/issue-v/36864/v20.2
# https://www.cockroachlabs.com/docs/stable/known-limitations.html#location-based-time-zone-names
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        tzdata

# install cockroach
RUN wget -qO- https://binaries.cockroachdb.com/cockroach-${COCKROACH_VERSION}.linux-amd64.tgz | tar xvz \
    && cp -i cockroach-${COCKROACH_VERSION}.linux-amd64/cockroach ${BIN_PATH} \
    && mkdir -p ${COCKROACH_EXTERNAL_LIBS}cockroach \
    && cp -i cockroach-${COCKROACH_VERSION}.linux-amd64/lib/libgeos.so ${COCKROACH_EXTERNAL_LIBS}cockroach/ \
    && cp -i cockroach-${COCKROACH_VERSION}.linux-amd64/lib/libgeos_c.so ${COCKROACH_EXTERNAL_LIBS}cockroach/

# !! ONCE-OFF !!
# generate cockroach certificates
#RUN mkdir /certs \
#    # create the CA (Certificate Authority) certificate and key pair:
#    && cockroach cert create-ca \
#        --certs-dir=/certs \
#        --ca-key=/certs/ca.key \
#    # create the certificate and key pair for your nodes
#    && cockroach cert create-node localhost cockroachdb.dev.local \
#        --certs-dir=/certs \
#        --ca-key=/certs/ca.key \
#    # create a client certificate and key pair for the root user
#    && cockroach cert create-client root \
#        --certs-dir=/certs \
#        --ca-key=/certs/ca.key

# !imporant!
# fall back to the 'teletype' for  debconf
# this way both interactive and non-interactive modes get set
# 'teletype' is needed for interactive configuration steps the user might want to do inside a running container
ENV DEBIAN_FRONTEND teletype

# cockroach
EXPOSE ${COCKROACH_PORT}
EXPOSE ${COCKROACH_HTTP_PORT}
