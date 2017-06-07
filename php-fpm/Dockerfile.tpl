# FROM can appear multiple times within a single Dockerfile in order to create multiple images.
FROM php:$MAJOR_VERSION.$MINOR_VERSION-fpm-$OS_RELEASE

ARG DEV_ENVIRONMENT=${DEV_ENVIRONMENT}
ARG PHP_FPM_VERSION=$MAJOR_VERSION$MINOR_VERSION
ARG PHP_FPM_INSTALL_PDO_SQLSRV=false
ARG PHP_FPM_INSTALL_XDEBUG=false
ARG PHP_FPM_INSTALL_MEMCACHED=false
ARG PHP_FPM_LOG=/var/log/php-fpm.log
ARG PHP_XDEBUG_LOG=/var/log/php-xdebug.log
ARG PHP_OPCACHE_LOG=/var/log/php-opcache.log
ARG PHP72_MCRYPT_VERSION=1.0.2
ARG PHP73_MCRYPT_VERSION=1.0.3
ARG PHP74_MCRYPT_VERSION=1.0.4
ARG PHP_LATEST_MCRYPT_VERSION=1.0.4
# https://pecl.php.net/package/pdo_sqlsrv
ARG PHP_PDO_SQL_VERSION=5.9.0
# https://pecl.php.net/package/xdebug
ARG PHP_XDEBUG_VERSION=3.0.2
# https://pecl.php.net/package/memcached
ARG PHP_MEMCACHED_VERSION=3.1.5

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
        # mcrypt dependency
        libmcrypt-dev \
        libmemcached-dev \
        libpq-dev \
        libssl-dev \
        libxml2-dev \
        libz-dev \
        git \
        software-properties-common

# if DEV_ENVIRONMENT = true, install dev tools
RUN if [ ${DEV_ENVIRONMENT} = true ]; then \
    \
    apt-get install -y --no-install-recommends \
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

# install PHP modules
RUN if [ ${PHP_FPM_VERSION} -ge 73 ]; then \
    \
    apt-get install -y --no-install-recommends \
        libzip-dev \
;fi

# possible values for ext-name:
# bcmath bz2 calendar ctype curl dba dom enchant exif fileinfo filter ftp gd gettext gmp hash iconv imap interbase intl json ldap mbstring mcrypt mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell readline recode reflection session shmop simplexml snmp soap sockets spl standard sysvmsg sysvsem sysvshm tidy tokenizer wddx xml xmlreader xmlrpc xmlwriter xsl zip
RUN docker-php-ext-install -j$(nproc) bcmath curl iconv intl mysqli opcache pdo pdo_mysql simplexml xml zip \
    # per PHP 7.4 the GD library configure options have changed slightly
    && if [ ${PHP_FPM_VERSION} -ge 74 ]; then \
        docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    ;else \
        docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    ;fi \
    \
    && docker-php-ext-install -j$(nproc) gd \
    \
    # install libmcrypt dependency for < PHP7.2
    # this extension has been moved to the PECL repository and is no longer bundled with PHP as of PHP 7.2.0
    # (per PHP 7.2 mcrypt extension is no longer supported in favor of the libsodium cryptography library)
    && if [ ${PHP_FPM_VERSION} -lt 72 ]; then \
        docker-php-ext-install mcrypt \
    ; else \
        pecl channel-update pecl.php.net \
        && if [ ${PHP_FPM_VERSION} -eq 72 ]; then \
            echo "autodetect" | pecl install --nodeps mcrypt-${PHP72_MCRYPT_VERSION} \
        ;elif [ ${PHP_FPM_VERSION} -eq 73 ]; then \
            echo "autodetect" | pecl install --nodeps mcrypt-${PHP73_MCRYPT_VERSION} \
        ;elif [ ${PHP_FPM_VERSION} -eq 74 ]; then \
            echo "autodetect" | pecl install --nodeps mcrypt-${PHP74_MCRYPT_VERSION} \
        # only PHP 8.0 remains
        ;else \
            echo "autodetect" | pecl install --nodeps mcrypt-${PHP_LATEST_MCRYPT_VERSION} \
        ;fi \
        && docker-php-ext-enable mcrypt \
    ;fi

# uninstall superfluous packages - don't need them anymore
#RUN apt-get remove -y --purge git software-properties-common \
#    && apt-get autoremove -y

# mssql, sqlsrv & pdo_sqlsrv
# https://pecl.php.net/package/sqlsrv
# https://pecl.php.net/package/pdo_sqlsrv
RUN if [ ${PHP_FPM_INSTALL_PDO_SQLSRV} = true ]; then \
    \
    # for now no MSSQL support for PHP 5.6
    # untested; apt-get install php5-mssql, apparently allows you to use pdo_sqlsrv
    # https://kogentadono.com/2011/11/01/installing-the-mssql-libraries-for-php-on-linux/
    # http://php.net/manual/en/ref.pdo-sqlsrv.php
    # https://github.com/Microsoft/msphpsql/wiki/Dockerfile-for-getting-pdo_sqlsrv-for-PHP-7.0-on-Debian-in-3-ways
    # https://www.microsoft.com/en-us/download/details.aspx?id=28160
    # < PHP 7.0
    if [ ${PHP_FPM_VERSION} -lt 70 ]; then \
        \
        # for now no MSSQL support for PHP 5.6
        # maybe I'll implement dblib if need be
        echo "Currently no MSSQL support for PHP 5.6" \
    ;else \
        \
        # add Microsoft repo for Microsoft ODBC Driver for Linux
        apt-get install -y --no-install-recommends \
                apt-transport-https \
                gnupg \
        && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
        && curl https://packages.microsoft.com/config/debian/$MICROSOFT_DEBIAN_RELEASE/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list \
        && apt-get update \
        \
        # install dependencies
        && ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
            unixodbc \
            unixodbc-dev \
            mssql-tools \
            libgss3 \
            odbcinst \
            locales \
        && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen \
        \
        # install sqlsrv & pdo_sqlsrv
        && pecl channel-update pecl.php.net \
        && if [ ${PHP_FPM_VERSION} -eq 70 ]; then \
            pecl install pdo_sqlsrv-5.3.0 sqlsrv-5.3.0 \
        ;elif [ ${PHP_FPM_VERSION} -eq 71 ]; then \
            pecl install pdo_sqlsrv-5.6.1 sqlsrv-5.6.1 \
        ;elif [ ${PHP_FPM_VERSION} -eq 72 ]; then \
            pecl install pdo_sqlsrv-5.8.1 sqlsrv-5.8.1 \
        ;else \
            # PHP 7.3, PHP 7.4, PHP 8.0
            pecl install pdo_sqlsrv-${PHP_PDO_SQL_VERSION} sqlsrv-${PHP_PDO_SQL_VERSION} \
        ;fi \
        \
        && docker-php-ext-enable pdo_sqlsrv sqlsrv \
    ;fi \
;fi

# xDebug:
# https://xdebug.org/docs/compat
RUN if [ ${PHP_FPM_INSTALL_XDEBUG} = true ]; then \
    \
    # < PHP 7.0
    # XDebug 2.6.0 and up no longer support PHP5
    if [ ${PHP_FPM_VERSION} -lt 70 ]; then \
    \
        pecl install xdebug-2.5.5 \
    ;elif [ ${PHP_FPM_VERSION} -eq 70 ]; then \
        \
        pecl install xdebug-2.7.2 \
    ;elif [ ${PHP_FPM_VERSION} -eq 71 ]; then \
        \
        pecl install xdebug-2.9.8 \
    ;else \
        \
        pecl install xdebug-${PHP_XDEBUG_VERSION} \
    ;fi \
    \
    && docker-php-ext-enable xdebug \
;fi

# Memcached:
RUN if [ ${PHP_FPM_INSTALL_MEMCACHED} = true ]; then \
    \
    # < PHP 7.0
    # Memcached 3.0 and up no longer support PHP5
    if [ ${PHP_FPM_VERSION} -lt 70 ]; then \
        \
        pecl install memcached-2.2.0 \
    ;else \
        \
        pecl install memcached-${PHP_MEMCACHED_VERSION} \
    ;fi \
    \
    && docker-php-ext-enable memcached \
;fi

# create and set permissions for log files
RUN touch ${PHP_OPCACHE_LOG} \
    && touch ${PHP_FPM_LOG} \
    && touch ${PHP_XDEBUG_LOG} \
    && chown www-data: ${PHP_FPM_LOG} \
    && chown www-data: ${PHP_XDEBUG_LOG} \
    && chown www-data: ${PHP_OPCACHE_LOG} \
    \
    # clean up
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc /usr/share/locale /var/log/apt/* /var/log/*.log \
    && rm -rvf /usr/src/php

# fallback to the 'teletype' for  debconf
# this way both interactive and non-interactive modes get set
# 'teletype' is needed for interactive configuration steps the user might want to do inside a running container
ENV DEBIAN_FRONTEND teletype

# set work directory
WORKDIR /var/www/sites
