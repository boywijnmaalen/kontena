#!/usr/bin/env bash

# create a directory
function create_dir () {

    # create directory if it doesn't exist already
    for directory in "${directories[@]}"; do

        if [ ! -d ${directory} ]; then

            mkdir -p ${directory}
        fi
    done
}

# create a file
function create_file () {

    # create file if it doesn't exist already
    for file in "${files[@]}"; do

        if [ ! -f ${file} ]; then

            touch ${file}
        fi
    done
}

function in_array() {

    # example;
    #
    # array=("1" "2" "6")
    # echo $(in_array "2" array && echo 1 || echo 0)
    # echo $(in_array "4" array && echo 1 || echo 0)
    #
    # if in_array "1" array; then
    #     echo '1'
    # else
    #     echo '0'
    # fi

    local haystack=${2}[@]
    local needle=${1}

    for element in ${!haystack}; do

        if [[ ${element} == ${needle} ]]; then

            return 0
        fi
    done

    return 1
}


# output html plain
function html_plain() {

    echo "<span>${1}</span>"
}

# output html info
function html_info() {

    echo "<p style='display : block;' class='margin-reset info'>${1}</p>"
}

# output html ok
function html_ok() {

    echo "<p style='display : block;' class='margin-reset ok'>${1}</p>"
}

# output html warning
function html_warning() {

    echo "<p style='display : block;' class='margin-reset warning'>${1}</p>"
}

# output html error
function html_error() {

    echo "<p style='display : block;' class='margin-reset error'>${1}</p>"
}
