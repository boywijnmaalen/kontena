#!/usr/bin/env bash

php_fpm_log_file=/var/log/php-fpm.log
php_opcahce_log_file=/var/log/php-opcache.log

# check if php fpm log exists
if [ ! -e "${php_fpm_log_file}" ]; then \

    touch "${php_fpm_log_file}" \
;fi

# check if php opcache log exists
if [ ! -e "${php_opcahce_log_file}" ]; then \

    touch "${php_opcahce_log_file}" \
;fi

# set log file permission áfter the mount-binding was done
chown www-data: "${php_fpm_log_file}" "${php_opcahce_log_file}"
chmod 644 "${php_fpm_log_file}" "${php_opcahce_log_file}"

# start php-fpm
php-fpm

