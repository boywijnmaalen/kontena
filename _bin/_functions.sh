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
