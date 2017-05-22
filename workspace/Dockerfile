FROM jedisct1/phusion-baseimage-latest

# imported! because the terminal does not support odd characters coming from the repository name ppa:ondrej/php
ENV LC_ALL C.UTF-8

ARG PUID=1000
ARG PGID=1000
ARG LOCAL_USER=admin
ARG GIT_NAME="Firstname Lastname"
ARG GIT_EMAIL=firstname.lastname@company.org
ARG BIN_PATH=/usr/local/bin/

# add a non-root user
RUN groupadd -g ${PGID} ${LOCAL_USER} && \
    useradd -u ${PUID} -g ${LOCAL_USER} -m ${LOCAL_USER}

# add PHP 7.1, NodeJS & Yarn repositories
RUN add-apt-repository -y ppa:ondrej/php \
    && curl -sL https://deb.nodesource.com/setup_7.x | bash \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# install basic software
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        bash \
        mlocate \
        net-tools \
        vim \
        curl \
        git \
        sudo \
        wget \
        nodejs \
        yarn

# install PHP versions
RUN for i in 5.6 7.0 7.1; do \

    apt-get install -y --no-install-recommends \
        php-common \
        php${i}-bcmath \
        php${i}-cli \
        php${i}-curl \
        php${i}-common \
        php${i}-gd \
        php${i}-json \
        php${i}-mbstring \
        php${i}-mcrypt \
        php${i}-memcached \
        php${i}-mysql \
        php${i}-pgsql \
        php${i}-readline \
        php${i}-sqlite \
        php${i}-sqlite3 \
        php${i}-xdebug \
        php${i}-xml \
        php-zip \
;done

# install globally popular PHP dev tools
RUN \
    # install Composer globally
    curl -LsS https://getcomposer.org/composer.phar -o ${BIN_PATH}composer \
    && chmod a+x ${BIN_PATH}composer \

    # install CodeCeption globally
    && curl -LsS http://codeception.com/codecept.phar -o ${BIN_PATH}codeception \
    && chmod a+x ${BIN_PATH}codeception \

    # install Deployer globally
    && curl -LsS http://deployer.org/deployer.phar -o ${BIN_PATH}deployer \
    && chmod a+x ${BIN_PATH}deployer \

    # install PHPmd globally
    && curl -LsS http://static.phpmd.org/php/latest/phpmd.phar -o ${BIN_PATH}phpmd \
    && chmod a+x ${BIN_PATH}phpmd \

    # install PHPcpd globally
    && curl -LsS https://phar.phpunit.de/phpcpd.phar -o ${BIN_PATH}phpcpd \
    && chmod a+x ${BIN_PATH}phpcpd \

    # install PHPcs globally
    && curl -LsS https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar -o ${BIN_PATH}phpcs \
    && chmod a+x ${BIN_PATH}phpcs \

    # install PHPcbf globally
    && curl -LsS https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar -o ${BIN_PATH}phpcbf \
    && chmod a+x ${BIN_PATH}phpcbf \

    # install PHPUnit globally (only works for > PHP 7.0) and make it the default
    && curl -LsS https://phar.phpunit.de/phpunit.phar -o ${BIN_PATH}phpunit6 \
    && chmod a+x ${BIN_PATH}phpunit6 \
    && ln -sf /usr/local/bin/phpunit6 /usr/local/bin/phpunit \

    # install PHPUnit globally (works for < PHP 7.0)
    && curl -LsS https://phar.phpunit.de/phpunit-5.7.phar -o ${BIN_PATH}phpunit5 \
    && chmod a+x ${BIN_PATH}phpunit5 \

    # install splitsh-lite
    && curl -LsS https://github.com/splitsh/lite/releases/download/v1.0.1/lite_linux_amd64.tar.gz -o ${BIN_PATH}splitsh-lite.tgz \
    && tar -zxvf ${BIN_PATH}splitsh-lite.tgz -C ${BIN_PATH} \
    && rm ${BIN_PATH}splitsh-lite.tgz \
    && chown root: ${BIN_PATH}splitsh-lite \
    && chmod a+x ${BIN_PATH}splitsh-lite

# install npm packages, bower, gulp, node-sass (Fast SASS compiler written in C)
RUN npm install -g \
        bower \
        gulp \
        node-sass

# allow the local user to execute sudo without requiring a password
RUN sed -i "s|${LOCAL_USER} ALL=(ALL) ALL|${LOCAL_USER} ALL=(ALL) NOPASSWD: ALL|" "/etc/sudoers"

# clean up
RUN chown -R ${LOCAL_USER} /home/admin \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc /usr/share/locale /var/log/apt/* /var/log/*.log \
    && dpkg -la | awk '{print $2}' | grep '\-dev' | xargs apt-get remove -y \
    && rm -rvf /etc/php/*
