# nginx setup one vhost per website with multiple PHP versions
# - http://serverfault.com/questions/598202/make-nginx-to-pass-hostname-of-the-upstream-when-reverseproxying
# - http://stackoverflow.com/questions/37025966/nginx-setting-up-variable-upstream-per-virtual-host
FROM nginx:latest

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
        wget \
        sudo \
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

EXPOSE 80 443

# set work directory
WORKDIR /var/www/sites
