# https://hub.docker.com/_/bind9/plans/3af94cc6-b9c6-43c2-8658-e617ef977949?tab=instructions
FROM store/internetsystemsconsortium/bind9:9.16

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
        traceroute \
        dnsutils \
        procps \
        inetutils-ping \
    && update-alternatives --set editor /usr/bin/vim.basic \
;fi

RUN apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc /usr/share/locale /var/log/apt/* \
    && dpkg -la | awk '{print $2}' | grep '\-dev' | xargs apt-get remove -y \
    \
    && rm /etc/bind/named.conf.options \
    && rm /etc/bind/named.conf.local \
    && rm /etc/bind/named.conf
