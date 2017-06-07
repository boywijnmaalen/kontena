#!/usr/bin/env bash

COCKROACH_DIR=${ROOT_DIR}/cockroachdb

# load .env config (only needed when this file is called directly)
source "${ROOT_DIR}"/.env

# load mariadb config
source "${COCKROACH_DIR}"/config.sh

# directory check
create_dir

# file check
create_file

################################
# start building entrypoint.sh #
################################
entrypoint_filename=${COCKROACH_DIR}/entrypoint.sh

entrypoint="#!/usr/bin/env bash

# check if cockroach data directory exists
if [ ! -d \"${COCKROACH_DATA_DIR}\" ]; then \

    mkdir -p ${COCKROACH_DATA_DIR} \\
;fi

# check if cockroach Log error log exists
if [ ! -d \"${COCKROACH_LOG_DIR}\" ]; then \

    mkdir -p \"${COCKROACH_LOG_DIR}\" \\
;fi

# set log file permission áfter the mount-binding was done
chown -R cockroach: \"${COCKROACH_DATA_DIR}\" \"${COCKROACH_LOG_DIR}\"
chmod 777 \"${COCKROACH_LOG_DIR}\" \"${COCKROACH_LOG_DIR}\"

# start cockroach
cockroach start-single-node \\
  --certs-dir=\"/certs\" \\
  --store=\"${COCKROACH_DATA_DIR}\" \\
  --port=\"${COCKROACH_PORT}\" \\
  --http-port=\"${COCKROACH_HTTP_PORT}\" \\
  --listen-addr=\"cockroachdb.dev.local\" \\
  --advertise-addr=\"cockroachdb.dev.local\" \\
  --log-dir=\"${COCKROACH_LOG_DIR}\" \\
  --log-file-verbosity=INFO
"

echo "${entrypoint}" > "${entrypoint_filename}"

chmod 755 "${entrypoint_filename}"
