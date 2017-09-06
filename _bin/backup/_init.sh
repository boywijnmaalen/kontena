#!/usr/bin/env bash

# set split of input to newlines (rather than <spaces>)
IFS=$'\n'

# be defensive; check if config file actually exists, if not exit
if [ ! -f "${ROOT_DIR}/backup.conf" ]; then

    echo ""
    echo -e "\033[1;41m Error: the config file '${ROOT_DIR}/backup.conf' does not exist! \033[0m"

    exit;
fi

# load config
source ${ROOT_DIR}/backup.conf

# load functions
source ${ROOT_DIR}/_bin/_functions.sh

# create backup directory
backup_directory="${target_dir}/$(date -j '+%Y%m%d')"
if [ ! -d ${backup_directory} ]; then

    mkdir -p ${backup_directory}
    chmod 700 ${backup_directory}
fi

# only set mail variables when they haven't been set yet
if [ -z ${mail+x} ]; then

    mail=()
    stats=()
fi

# variables needed for stats in email
warnings_count=0;
errors_count=0;
