#!/usr/bin/env bash

MARIADB_DIR=${ROOT_DIR}/mariadb

# load mariadb config
source "${MARIADB_DIR}"/config.sh

# directory check
create_dir

# file check
create_file

################################
# start building entrypoint.sh #
################################
entrypoint_filename=${MARIADB_DIR}/entrypoint.sh
log_path="/var/log/"
mysql_data_path="/var/lib/mysql/"
mysql_log_path="/var/log/mysql/"
mysql_error_log_file="${mysql_log_path}error.log"
mysql_log_file="${mysql_log_path}mysql.log"

entrypoint="#!/usr/bin/env bash

# check if mysql directory exists
if [ ! -d \"${mysql_log_path}\" ]; then \

    mkdir -p ${mysql_log_path} \\
;fi

# check if mysql error log exists
if [ ! -e \"${mysql_error_log_file}\" ]; then \

    touch \"${mysql_error_log_file}\" \\
;fi

# check if mysql access log exists
if [ ! -e \"${mysql_log_file}\" ]; then \

    touch \"${mysql_log_file}\" \\
;fi

# set log file permission áfter the mount-binding was done
chown -R mysql:adm \"${mysql_log_path}\"
chmod 740 \"${mysql_log_path}\"

# set database directory/file permissions
# check if mysql directory exists
if [ ! -d \"${mysql_data_path}\" ]; then \

    mkdir ${mysql_data_path} \\
;fi

chown -R mysql:adm \"${mysql_data_path}\"
chmod 755 \"${mysql_data_path}\"
find \"${mysql_data_path}\" -type d -exec chmod 700 {} +
find \"${mysql_data_path}\" -type f -exec chmod 660 {} +

# start mysql via the main entrypoint file
/usr/local/bin/docker-entrypoint.sh mysqld"

echo "${entrypoint}" > "${entrypoint_filename}"

chmod 755 "${entrypoint_filename}"

########################################
# start building setup_gitlab_user.sql #
########################################

setup_gitlab_user=""
setup_gitlab_user_filename=${MARIADB_DIR}/setup_gitlab_user.sql

if [ -n "${GITLAB_MYSQL_USER}" ]; then
  setup_gitlab_user="# add user
  CREATE USER '${GITLAB_MYSQL_USER}'@'localhost' IDENTIFIED BY '${GITLAB_MYSQL_PASSWORD}';
  CREATE USER '${GITLAB_MYSQL_USER}'@'%' IDENTIFIED BY '${GITLAB_MYSQL_PASSWORD}';

  # set privileges
  GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER, LOCK TABLES, REFERENCES, TRIGGER ON ${GITLAB_MYSQL_DATABASE}.* TO '${GITLAB_MYSQL_USER}'@'localhost';
  GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER, LOCK TABLES, REFERENCES, TRIGGER ON ${GITLAB_MYSQL_DATABASE}.* TO '${GITLAB_MYSQL_USER}'@'%';

  # flush privileges
  FLUSH PRIVILEGES;"
fi

echo "${setup_gitlab_user}" > "${setup_gitlab_user_filename}"

chmod 755 "${setup_gitlab_user_filename}"
