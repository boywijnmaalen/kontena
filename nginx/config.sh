#!/usr/bin/env bash

log_dir=${LOGS_DIR}/nginx

directories=(
    ${log_dir}
);

files=(
    ${log_dir}/access.log
    ${log_dir}/error.log
);
