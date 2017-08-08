#!/usr/bin/env bash

MARIADB_DIR=${ROOT_DIR}/mariadb

# load mariadb config
source ${MARIADB_DIR}/config.sh

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
mysql_error_log_file="${log_path}mysql.err"
mysql_log_file="${log_path}mysql.log"

entrypoint="#!/usr/bin/env bash

# check if mysql directory exists
if [ ! -d \"${mysql_log_path}\" ]; then \

    touch ${mysql_log_path} \\
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

chown mysql:adm \"${mysql_error_log_file}\" \"${mysql_log_file}\"
chmod 640 \"${mysql_error_log_file}\" \"${mysql_log_file}\"

# set database directory/file permissions
# check if mysql directory exists
if [ ! -d \"${mysql_data_path}\" ]; then \

    touch ${mysql_data_path} \\
;fi

chown -R mysql:adm \"${mysql_data_path}\"
chmod 755 \"${mysql_data_path}\"
find \"${mysql_data_path}*\" -type d -exec chmod 700 {} +
find \"${mysql_data_path}*\" -type f -exec chmod 660 {} +

# start mysql as user mysql
su -s /bin/sh mysql -c \"/usr/sbin/mysqld\"

# create a new mysql gitlab user, has to be a two-step process as the 'IDENTIFIED BY' statement does not work in combination with 'CREATE USER IF NOT EXISTS'
# https://stackoverflow.com/a/35898679/4929221
# https://stackoverflow.com/a/10236195/4929221
mysql -h mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e \"CREATE USER IF NOT EXISTS '${GITLAB_MYSQL_USER}'@localhost\";
mysql -h mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e \"SET PASSWORD FOR '${GITLAB_MYSQL_USER}'@localhost = PASSWORD('${GITLAB_MYSQL_PASSWORD}');\";

mysql -h mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e \"CREATE USER IF NOT EXISTS '${GITLAB_MYSQL_USER}'@'%'\";
mysql -h mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e \"SET PASSWORD FOR '${GITLAB_MYSQL_USER}'@'%' = PASSWORD('${GITLAB_MYSQL_PASSWORD}');\";

# create database
mysql -h mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e \"CREATE DATABASE IF NOT EXISTS ${GITLAB_MYSQL_DATABASE} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;\"

# set privileges
mysql -h mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e \"GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER, LOCK TABLES, REFERENCES, TRIGGER ON ${GITLAB_MYSQL_DATABASE}.* TO '${GITLAB_MYSQL_USER}'@localhost;\"
mysql -h mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e \"GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER, LOCK TABLES, REFERENCES, TRIGGER ON ${GITLAB_MYSQL_DATABASE}.* TO '${GITLAB_MYSQL_USER}'@'%';\"

# flush privileges
mysql -h mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e \"FLUSH PRIVILEGES;\""

echo "${entrypoint}" > ${entrypoint_filename}

chmod 755 ${entrypoint_filename}
