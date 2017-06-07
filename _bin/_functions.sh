#!/usr/bin/env bash

# create a directory
function create_dir () {

    # create directory if it doesn't exist already
    for directory in "${directories[@]}"; do \

        if [ ! -d ${directory} ]; then \

            mkdir -p ${directory} \
        ;fi \
    ;done
}

# create a file
function create_file () {

    # create file if it doesn't exist already
    for file in "${files[@]}"; do \

        if [ ! -f ${file} ]; then \

            touch ${file} \
        ;fi \
    ;done
}

# check if value exists in an array
function in_array() {
    local haystack=${1}[@]
    local needle=${2}
    for i in ${!haystack}; do
        if [[ ${i} == ${needle} ]]; then
            return 0
        fi
    done
    return 1
}

function usage() {
    echo "[$(basename $BASH_SOURCE)] Usage: $0 [-s <string>] [-m <nfs|default>]" 1>&2;
    exit 1;
}
