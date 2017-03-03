#!/bin/bash

usage() {
    echo "[$(basename $BASH_SOURCE)] Usage: $0 [-s <string>] [-m <nfs|default>]" 1>&2;
    exit 1;
}

in_array() {
    local haystack=${1}[@]
    local needle=${2}
    for i in ${!haystack}; do
        if [[ ${i} == ${needle} ]]; then
            return 0
        fi
    done
    return 1
}

services=()
modes=("nfs" "default");

if ! in_array modes $1; then

    echo "[$(basename $BASH_SOURCE)] Docker mode is undefined"
    exit 1
fi

mode=$1
shift

while getopts ":s:m:h" option; do

        case "${option}" in
            s)
                services+=(${OPTARG})
            ;;
            m)
                mode=${OPTARG}
            ;;
            h)
                usage
                exit 0
            ;;
            \?)
                echo "[$(basename $BASH_SOURCE)] An invalid option given: -$OPTARG"
                usage
                exit 1
            ;;
            :)
                echo "[$(basename $BASH_SOURCE)] The value option -$OPTARG was omitted."
                usage
                exit 1
            ;;
        esac
done

# when in nfs mode
if [ ${mode} = "nfs" ]; then

    ~/d4m-nfs/d4m-nfs.sh
    docker-compose -f docker-compose-with-nfs.yml up -d --build ${services[@]}
else

    if ! $(docker info > /dev/null 2>&1); then

        echo "[$(basename $BASH_SOURCE)] Starting Docker as it was not running"
        open -a /Applications/Docker.app
    fi

    echo -ne "\n[$(basename $BASH_SOURCE)]  Wait until D4M is running."
    while ! $(docker run --rm hello-world > /dev/null 2>&1); do
        echo -n "."
        sleep .25
    done

    docker-compose up -d --build ${services[@]}
fi
