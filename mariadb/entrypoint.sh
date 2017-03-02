#!/usr/bin/env bash

log_path="/var/log/"
mysql_log_path="/var/log/mysql/"
mysql_error_log_file="${log_path}mysql.err"
mysql_log_file="${log_path}mysql.log"

# check if mysql directory exists
if [ ! -d "${mysql_log_path}" ]; then \

    touch ${mysql_log_path} \
;fi

# check if mysql error log exists
if [ ! -e "${mysql_error_log_file}" ]; then \

    touch "${mysql_error_log_file}" \
;fi

# check if mysql access log exists
if [ ! -e "${mysql_log_file}" ]; then \

    touch "${mysql_log_file}" \
;fi

# set log file permission áfter the mount-binding was done
chown -R mysql:adm "${mysql_log_path}"
chmod 740 "${mysql_log_path}"

chown mysql:adm "${mysql_error_log_file}" "${mysql_log_file}"
chmod 640 "${mysql_error_log_file}" "${mysql_log_file}"

# start mysql as user mysql
su -s /bin/sh mysql -c "/usr/sbin/mysqld"
