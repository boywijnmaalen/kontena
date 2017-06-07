#!/bin/bash

# get project root directory
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"
DATA_DIR=${ROOT_DIR}/_data
LOG_DIR=${ROOT_DIR}/_logs

# make sure we always start in project root
cd "${ROOT_DIR}" || exit

# load config
source "${ROOT_DIR}"/.env

# load functions
source "${ROOT_DIR}"/_bin/_functions.sh

# create base dirs
mkdir -p "${DATA_DIR}"
mkdir -p "${LOG_DIR}"

if [ ! -d "${WEB_ROOT}" ]; then
  mkdir -p "${WEB_ROOT}"
fi

# run setups
containers=(
    'cockroachdb'
    'dns'
    'gitlab'
    'mariadb'
    'nginx'
    'php-fpm'
    'redis'
    'workspace'
);

# loop through the setups and execute
for container in "${containers[@]}"; do \

    if [ -f "${ROOT_DIR}"/"${container}"/setup.sh ]; then \

        source "${ROOT_DIR}"/${container}/setup.sh \
    ;fi \
;done

# set permissions for log files
find "${ROOT_DIR}"/_logs/* -type d -exec chmod 744 {} +
find "${ROOT_DIR}"/_logs/* -type f -exec chmod 640 {} +
