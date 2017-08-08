#!/usr/bin/env bash

PHP_DIR=${ROOT_DIR}/php

# load php config
source ${PHP_DIR}/config.sh

# directory check
create_dir

# loop through PHP versions
for php_version in 5.6 7.0 7.1; do

    # change working directory
    cd "${ROOT_DIR}/workspace/etc/php/${php_version}"

    # copy php.ini to the workspace
    cp ${PHP_DIR}/${php_version}/php.ini ./cli

    # generate PHP-FPM Dockerfiles from a template
    exploded_php_version=(${php_version//./ });

    cat ${PHP_DIR}/Dockerfile.tpl \
        | sed -e "s|\$MAJOR_VERSION|${exploded_php_version[0]}|" \
        | sed -e "s|\$MINOR_VERSION|${exploded_php_version[1]}|" \
       > ${PHP_DIR}/${php_version}/Dockerfile

    # create php log files
    files=("${php_log_files[@]}")
    files=("${files[@]/\$MAJOR_VERSION/${exploded_php_version[0]}}")
    files=("${files[@]/\$MINOR_VERSION/${exploded_php_version[1]}}")

    # file check
    create_file

done

# start building entrypoint.sh
entrypoint_filename=${PHP_DIR}/entrypoint.sh
php_fpm_log_file=/var/log/php-fpm.log
php_opcahce_log_file=/var/log/php-opcache.log

################################
# start building entrypoint.sh #
################################
entrypoint="#!/usr/bin/env bash

# check if php fpm log exists
if [ ! -e "${php_fpm_log_file}" ]; then \\

    touch "${php_fpm_log_file}" \\
;fi

# check if php opcache log exists
if [ ! -e "${php_opcahce_log_file}" ]; then \\

    touch "${php_opcahce_log_file}" \\
;fi

# set log file permission áfter the mount-binding was done
chown www-data: "${php_fpm_log_file}" "${php_opcahce_log_file}"
chmod 644 "${php_fpm_log_file}" "${php_opcahce_log_file}"

# start php-fpm
php-fpm"

echo "${entrypoint}" > ${entrypoint_filename}

chmod 755 ${entrypoint_filename}

