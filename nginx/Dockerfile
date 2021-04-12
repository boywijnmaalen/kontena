# nginx setup one vhost per website with multiple PHP versions
# - http://serverfault.com/questions/598202/make-nginx-to-pass-hostname-of-the-upstream-when-reverseproxying
# - http://stackoverflow.com/questions/37025966/nginx-setting-up-variable-upstream-per-virtual-host
FROM nginx:latest

ARG DEV_ENVIRONMENT=${DEV_ENVIRONMENT}

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
        traceroute \
        dnsutils \
        procps \
        inetutils-ping \
    && update-alternatives --set editor /usr/bin/vim.basic \
;fi

# create www-data user
RUN adduser www-data www-data --uid 1000 --shell /bin/bash

# create custom ssl certificate directory
RUN mkdir -p /etc/ssl/certs/custom/

# create nginx snippets directory
RUN mkdir -p /etc/nginx/snippets/

# cleanup
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc /usr/share/man /usr/share/locale \
    && apt-get autoremove -y \
    && dpkg -la | awk '{print $2}' | grep '\-dev' | xargs apt-get remove -y \
    && rm /etc/nginx/conf.d/default.conf

# expose http, https
EXPOSE 80 443

# set work directory
WORKDIR /var/www/sites
