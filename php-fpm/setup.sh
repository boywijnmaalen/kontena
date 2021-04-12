#!/usr/bin/env bash

PHP_DIR=${ROOT_DIR}/php-fpm
WORKSPACE_DIR=${ROOT_DIR}/workspace

# load php config
source ${PHP_DIR}/config.sh

# directory check
create_dir

# loop through PHP versions
for php_version in ${PHP_VERSIONS[*]}; do

    # generate PHP-FPM Dockerfiles from a template
    exp=(${php_version//./ });

    php_cli_file="${PHP_DIR}/${php_version}/php-cli.ini"

    # copy workspace php.ini to php-cli.ini
    cp "${WORKSPACE_DIR}/php/php${exp[0]}${exp[1]}-cli.ini" "${php_cli_file}"

    # remove the php version number from the FPM CLI version of the xdebug lof file definition
    sed -i '' -e "s|\/var\/log\/php${exp[0]}${exp[1]}-xdebug.log|\/var\/log\/php-xdebug.log|g" "${php_cli_file}"

    # start building PHP-FPM Dockerfile
    os_release=buster
    microsoft_debian_release=10
    if [ ${exp[0]}${exp[1]} -lt 71 ]; then \
      os_release=stretch
      microsoft_debian_release=9
    fi

    cat ${PHP_DIR}/Dockerfile.tpl \
        | sed -e "s|\$OS_RELEASE|${os_release}|" \
        | sed -e "s|\$MICROSOFT_DEBIAN_RELEASE|${microsoft_debian_release}|" \
        | sed -e "s|\$MAJOR_VERSION|${exp[0]}|" \
        | sed -e "s|\$MINOR_VERSION|${exp[1]}|" \
       > ${PHP_DIR}/${php_version}/Dockerfile

    # create php log files
    files=("${php_log_files[@]}")
    files=("${files[@]/\$MAJOR_VERSION/${exp[0]}}")
    files=("${files[@]/\$MINOR_VERSION/${exp[1]}}")

    # file check
    create_file

done

# start building entrypoint.sh
entrypoint_filename=${PHP_DIR}/entrypoint.sh
php_fpm_log_file=/var/log/php-fpm.log
php_xdebug_log_file=/var/log/php-xdebug.log
php_opcache_log_file=/var/log/php-opcache.log

################################
# start building entrypoint.sh #
################################
entrypoint="#!/usr/bin/env bash

# check if php fpm log exists
if [ ! -e \"${php_fpm_log_file}\" ]; then \\

    touch \"${php_fpm_log_file}\" \\
;fi

# check if php xdebug log exists
if [ ! -e \"${php_xdebug_log_file}\" ]; then \\

    touch \"${php_xdebug_log_file}\" \\
;fi

# check if php opcache log exists
if [ ! -e \"${php_opcache_log_file}\" ]; then \\

    touch \"${php_opcache_log_file}\" \\
;fi

# set log file permission áfter the mount-binding is done
chown www-data: \"${php_fpm_log_file}\" \"${php_opcache_log_file}\" \"${php_xdebug_log_file}\"
chmod 644 \"${php_fpm_log_file}\" \"${php_opcache_log_file}\" \"${php_xdebug_log_file}\"

# check for new ca certificates
update-ca-certificates > /dev/null 2>&1

# start php-fpm via the main entrypoint file
php-fpm"

echo "${entrypoint}" > "${entrypoint_filename}"

chmod 755 "${entrypoint_filename}"

