#!/bin/bash

# get project root directory
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"
DATA_DIR=${ROOT_DIR}/_data
LOGS_DIR=${DATA_DIR}/logs
SITE_DIR=${DATA_DIR}/sites

# make sure we always start in project root
cd ${ROOT_DIR}

# create base dirs
mkdir -p ${DATA_DIR}
mkdir -p ${LOGS_DIR}
mkdir -p ${SITE_DIR}

# load config
source ${ROOT_DIR}/.env

# load functions
source ${ROOT_DIR}/_scripts/_functions.sh

# run gitlab setup.sh
source ${ROOT_DIR}/gitlab/setup.sh

# run mariadb setup.sh
source ${ROOT_DIR}/mariadb/setup.sh

# run nginx setup.sh
source ${ROOT_DIR}/nginx/setup.sh

# run php setup.sh
source ${ROOT_DIR}/php/setup.sh

# run workspace setup.sh
source ${ROOT_DIR}/workspace/setup.sh

# set permissions for log files
find ${ROOT_DIR}/_data/logs/* -type d -exec chmod 744 {} +
find ${ROOT_DIR}/_data/logs/* -type f -exec chmod 640 {} +
