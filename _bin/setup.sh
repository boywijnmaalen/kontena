#!/bin/bash

# get project root directory
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"
DATA_DIR=${ROOT_DIR}/_src/data
LOG_DIR=${ROOT_DIR}/_src/logs
SITE_DIR=${DATA_DIR}/sites

# make sure we always start in project root
cd ${ROOT_DIR}

# create base dirs
mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}
mkdir -p ${SITE_DIR}

# load config
source ${ROOT_DIR}/.env

# load functions
source ${ROOT_DIR}/_bin/_functions.sh

# copy the content of docker-compose.yml to docker-compose-nfs.yml and prepare it for d4m-nfs
sed "s|- ./|- \${MOUNT}/|" ${ROOT_DIR}/docker-compose.yml > ${ROOT_DIR}/docker-compose-nfs.yml

# run setups
containers=(
    'gitlab'
    'mariadb'
    'nginx'
    'php'
    'workspace'
);

# loop through the setups and execute
for container in "${containers[@]}"; do \

    if [ -f ${ROOT_DIR}/${container}/setup.sh ]; then \

        source ${ROOT_DIR}/${container}/setup.sh \
    ;fi \
;done

# set permissions for log files
find ${ROOT_DIR}/_src/logs/* -type d -exec chmod 744 {} +
find ${ROOT_DIR}/_src/logs/* -type f -exec chmod 640 {} +