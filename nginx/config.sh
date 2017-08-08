#!/usr/bin/env bash

log_dir=${LOG_DIR}/nginx

directories=(
    ${log_dir}
);

files=(
    ${log_dir}/access.log
    ${log_dir}/error.log
);
