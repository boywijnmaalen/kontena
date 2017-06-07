#!/usr/bin/env bash

log_dir=${LOG_DIR}/dns

directories=(
    ${log_dir}
);

files=(
    ${log_dir}/default.log
    ${log_dir}/error.log
    ${log_dir}/query.log
    ${DNS_DIR}/etc/bind/named.conf.custom.local
);
