#!/usr/bin/env bash

data_dir=${DATA_DIR}/mariadb
log_dir=${LOG_DIR}/mariadb

directories=(
    ${data_dir}
    ${log_dir}/mysql
);

files=(
    ${log_dir}/mysql/mariadb-slow.log
    ${log_dir}/mysql.log
    ${log_dir}/error.log
);
