#!/usr/bin/env bash

NGINX_DIR=${ROOT_DIR}/nginx

# load nginx config
source ${NGINX_DIR}/setup.conf

# directory check
create_dir

# file check
create_file

# start building entrypoint.sh
entrypoint_filename=${NGINX_DIR}/entrypoint.sh
nginx_log_path="/var/log/nginx/"
nginx_error_log_file="${nginx_log_path}error.log"
nginx_access_log_file="${nginx_log_path}access.log"

################################
# start building entrypoint.sh #
################################
entrypoint="#!/usr/bin/env bash

# check if nginx directory exists
if [ ! -d "${nginx_log_path}" ]; then \\

    touch ${nginx_log_path} \\
;fi

# check if nginx error log exists
if [ ! -e "${nginx_error_log_file}" ]; then \\

    touch "${nginx_error_log_file}" \\
;fi

# check if nginx access log exists
if [ ! -e "${nginx_access_log_file}" ]; then \\

    touch "${nginx_access_log_file}" \\
;fi

# set log file permission áfter the mount-binding was done
chown root:adm "${nginx_log_path}"
chmod 755 "${nginx_log_path}"

chown www-data:adm "${nginx_error_log_file}" "${nginx_access_log_file}"
chmod 640 "${nginx_error_log_file}" "${nginx_access_log_file}"

# start nginx
nginx"

echo "${entrypoint}" > ${entrypoint_filename}

chmod 755 ${entrypoint_filename}
