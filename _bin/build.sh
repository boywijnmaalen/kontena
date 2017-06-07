#!/bin/bash

# load functions
source ${ROOT_DIR}/_bin/_functions.sh

# get project root directory
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"

# get use home directory
HOME_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ~/ && pwd )"

mode=${1}
services=()
modes=("default");

if ! in_array modes ${mode}; then

    mode=default
else
    shift
fi

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

echo

# check if Docker is running, if not start d4m and halt script execution until it d4m is ready
if ! $(docker info > /dev/null 2>&1); then

    echo "[$(basename $BASH_SOURCE)] Starting D4M as it was not running"
    open -a /Applications/Docker.app
fi

echo "[$(basename $BASH_SOURCE)] Wait until D4M is running"

while ! $(docker run --rm hello-world > /dev/null 2>&1); do

    echo -n "."
    sleep .25
done

cd ${ROOT_DIR}
docker-compose up -d --build ${services[@]}

echo ""

docker ps -a
