#!/usr/bin/env bash

REDIS_DIR=${ROOT_DIR}/redis

# load .env config (only needed when this file is called directly)
source "${ROOT_DIR}"/.env

# load mariadb config
source "${REDIS_DIR}"/config.sh

# directory check
create_dir

# file check
create_file

################################
# start building entrypoint.sh #
################################
entrypoint_filename=${REDIS_DIR}/entrypoint.sh

entrypoint="#!/usr/bin/env bash

# check if redis data directory exists
if [ ! -d \"${REDIS_DATA_DIR}\" ]; then \

    mkdir -p \"${REDIS_DATA_DIR}\" \\
;fi

# check if redis log directory exists
if [ ! -d \"${REDIS_LOG_DIR}\" ]; then \

    mkdir -p \"${REDIS_LOG_DIR}\" \\
;fi

# check if redis log file exists
if [ ! -f \"${REDIS_LOG_DIR}\" ]; then \

    touch \"${REDIS_LOG_FILE}\" \\
;fi

# set log file permission áfter the mount-binding was done
chown -R redis: \"${REDIS_DATA_DIR}\" \"${REDIS_LOG_DIR}\" \"${REDIS_LOG_FILE}\"
chmod 777 \"${REDIS_LOG_DIR}\" \"${REDIS_LOG_DIR}\"
chmod 644  \"${REDIS_LOG_FILE}\"

# start redis
redis-server /var/lib/redis.conf"

echo "${entrypoint}" > "${entrypoint_filename}"

chmod 755 "${entrypoint_filename}"
