#!/bin/bash

# get project root directory
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"

# get use home directory
HOME_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ~/ && pwd )"

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

mode=${1}
services=()
modes=("nfs" "default");

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


# check if d4m script can be found, if not switch the default d4m installation
if [ ${mode} = "nfs" ] && [ ! -e "${HOME_DIR}/d4m-nfs/d4m-nfs.sh" ]; then \

    echo "[$(basename $BASH_SOURCE)] d4m-nfs could not be found. Please read README-D4M-PERFORMANCE-IMPROVEMENT.md for installation instructions."
    echo "[$(basename $BASH_SOURCE)] switching to the default d4m installation defined in ${ROOT_DIR}/docker-compose.yml"

    mode=default
fi

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
docker-compose start ${services[@]}

echo ""

docker ps -a
