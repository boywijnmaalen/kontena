# FROM can appear multiple times within a single Dockerfile in order to create multiple images.
FROM php:$MAJOR_VERSION.$MINOR_VERSION-fpm

ARG DEV_ENVIRONMENT=${DEV_ENVIRONMENT}
ARG PHP_FPM_VERSION=$MAJOR_VERSION$MINOR_VERSION
ARG PHP_FPM_INSTALL_PDO_SQLSRV=false
ARG PHP_FPM_INSTALL_XDEBUG=false
ARG PHP_FPM_INSTALL_MEMCACHED=false
ARG PHP_FPM_LOG=/var/log/php-fpm.log
ARG PHP_OPCACHE_LOG=/var/log/php-opcache.log

# prevent error like 'debconf: unable to initialize frontend: Dialog' because not all packages support 'interactive' mode
# change the way debconf (Debian Package Configuration System) configures packages
# 'noninteractive' is needed for the build steps as all packages must work in noninteractive mode as well
ENV DEBIAN_FRONTEND noninteractive

# install required dependencies for PHP modules
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        curl \
        libcurl3-dev \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng12-dev \
        libpq-dev \
        libssl-dev \
        libxml2-dev \
        libz-dev

# if DEV_ENVIRONMENT = true, install dev tools
RUN if [ ${DEV_ENVIRONMENT} = true ]; then \

    apt-get install -y --no-install-recommends \
        apt-utils \
        bash \
        mlocate \
        net-tools \
        vim \
        sudo \
        wget \
        tcpdump \
        telnet \
        inetutils-ping \
    && update-alternatives --set editor /usr/bin/vim.basic \
;fi

# install PHP modules
# possible values for ext-name:
# bcmath bz2 calendar ctype curl dba dom enchant exif fileinfo filter ftp gd gettext gmp hash iconv imap interbase intl json ldap mbstring mcrypt mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell readline recode reflection session shmop simplexml snmp soap sockets spl standard sysvmsg sysvsem sysvshm tidy tokenizer wddx xml xmlreader xmlrpc xmlwriter xsl zip
RUN docker-php-ext-install -j$(nproc) bcmath curl iconv intl mbstring mcrypt mysqli opcache pdo pdo_mysql simplexml xml \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# sqlsrv & pdo_sqlsrv
# https://pecl.php.net/package/sqlsrv
# https://pecl.php.net/package/pdo_sqlsrv
RUN if [ ${PHP_FPM_INSTALL_PDO_SQLSRV} = true ]; then \

        # for now no MSSQL support for PHP 5.6
        # untested; apt-get install php5-mssql, apparentely allows you to use pdo_sqlsrv
        # https://kogentadono.com/2011/11/01/installing-the-mssql-libraries-for-php-on-linux/
        # http://php.net/manual/en/ref.pdo-sqlsrv.php
        # https://github.com/Microsoft/msphpsql/wiki/Dockerfile-for-getting-pdo_sqlsrv-for-PHP-7.0-on-Debian-in-3-ways
        # https://www.microsoft.com/en-us/download/details.aspx?id=28160
        # >= PHP 7.0
        if [ ${PHP_FPM_VERSION} -lt 70 ]; then \

            apt-get install -y --no-install-recommends \
                    apt-transport-https \
            && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
            && curl https://packages.microsoft.com/config/debian/8/prod.list > /etc/apt/sources.list.d/mssql-release.list \
            && apt-get update \

            # install dependencies
            && ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
                unixodbc \
                unixodbc-dev \
                libgss3 \
                odbcinst \
                msodbcsql \
                locales \
            && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen \

            # apt-get install freetds-common freetds-bin unixodbc php5-mssql

            # && docker-php-ext-install mssql pdo_dblib \
#            cd /tmp
#            wget https://github.com/Microsoft/msphpsql/archive/v3.2.0.0.tar.gz
#            tar -zxvf v3.2.0.0.tar.gz
#
#            cd msphpsql-3.2.0.0/sqlsrv
#
#mv config.w32 config.m4
#phpize --clean
#phpize
#./configure
#make clean && make && make install
#
#download the file, uncompress and cd to the folder, then do pecl build
#pecl build

        ;else \

            # add Microsoft repo for Microsoft ODBC Driver 13 for Linux
            apt-get install -y --no-install-recommends \
                    apt-transport-https \
            && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
            && curl https://packages.microsoft.com/config/debian/8/prod.list > /etc/apt/sources.list.d/mssql-release.list \
            && apt-get update \

            # install dependencies
            && ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
                unixodbc \
                unixodbc-dev \
                libgss3 \
                odbcinst \
                msodbcsql \
                locales \
            && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen \

            # install sqlsrv & pdo_sqlsrv
            pecl channel-update pecl.php.net \
            && pecl install pdo_sqlsrv-4.1.6.1 sqlsrv-4.1.6.1 \
            && docker-php-ext-enable pdo_sqlsrv sqlsrv \

        ;fi \

        # MSSQL-TOOLS IS NOT YET AVAILABLE FOR DEBIAN (CAN'T USE UBUNTU VERSION BECAUSE OF DEPENDENCY ISSUE)
        # https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools
        # https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-connect-and-query-sqlcmd
        # if DEV_ENVIRONMENT = true, install mssql dev tools
#        && if [ ${DEV_ENVIRONMENT} = true ]; then \
#
#            apt-get install -y --no-install-recommends \
#               mssql-tools \
#        ;fi \

# issues:
# https://github.com/Microsoft/msphpsql/issues/400

;fi

# xDebug:
RUN if [ ${PHP_FPM_INSTALL_XDEBUG} = true ]; then \

    pecl install xdebug \
    && docker-php-ext-enable xdebug \
;fi

# Memcached:
RUN if [ ${PHP_FPM_INSTALL_MEMCACHED} = true ]; then \

    # < PHP 7.0
    if [ ${PHP_FPM_VERSION} -lt 70 ]; then \

        apt-get install -y --no-install-recommends \
            git \
        && git clone https://github.com/php-memcached-dev/php-memcached.git /usr/src/php/ext/memcached \
        && cd /usr/src/php/ext/memcached \
        && git checkout REL2_0 \
        && docker-php-ext-configure memcached \
        && docker-php-ext-install memcached \

    # >= PHP 7.0
    ;else \

        pecl install memcached \
        && docker-php-ext-enable memcached \

    ;fi \
;fi

# create and set permissions for log files
RUN touch ${PHP_OPCACHE_LOG} \
    && touch ${PHP_FPM_LOG} \
    && chown www-data: ${PHP_OPCACHE_LOG} \
    && chown www-data: ${PHP_FPM_LOG} \

    # clean up
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc /usr/share/locale /var/log/apt/* /var/log/*.log \
    && dpkg -la | awk '{print $2}' | grep '\-dev' | xargs apt-get remove -y \
    && rm /usr/local/etc/php-fpm.d/zz-docker.conf \
    && rm -rvf /usr/src/php

# fallback to the 'teletype' for  debconf
# this way both interactive and non-interactive modes get set
# 'teletype' is needed for interactive configuration steps the user might want to do inside a running container
ENV DEBIAN_FRONTEND teletype

# set work directory
WORKDIR /var/www/sites
