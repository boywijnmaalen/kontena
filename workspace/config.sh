#!/usr/bin/env bash

log_dir=${LOG_DIR}/workspace

directories=(
    ${log_dir}
);

php_log_files=(
    ${log_dir}/php\$MAJOR_VERSION\$MINOR_VERSION-fpm.log
    ${log_dir}/php\$MAJOR_VERSION\$MINOR_VERSION-opcache.log
);
