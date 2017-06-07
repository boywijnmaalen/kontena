#!/usr/bin/env bash

DNS_DIR=${ROOT_DIR}/dns

# load dns config
source "${DNS_DIR}"/config.sh

# directory check
create_dir

# file check
create_file

################################
# start building entrypoint.sh #
################################
entrypoint_filename=${DNS_DIR}/entrypoint.sh

dns_log_path="/var/log/named/"
dns_named_conf="/etc/bind/named.conf"
dns_default_log_file="/var/log/named/default.log"
dns_error_log_file="/var/log/named/error.log"
dns_queries_log_file="/var/log/named/query.log"

entrypoint="#!/usr/bin/env bash

# check if dns directory exists
if [ ! -d \"${dns_log_path}\" ]; then \

    mkdir -p ${dns_log_path} \\
;fi

# check if dns default log exists
if [ ! -e \"${dns_default_log_file}\" ]; then \

    touch \"${dns_default_log_file}\" \\
;fi

# check if dns error log exists
if [ ! -e \"${dns_error_log_file}\" ]; then \

    touch \"${dns_error_log_file}\" \\
;fi

# check if dns query log exists
if [ ! -e \"${dns_queries_log_file}\" ]; then \

    touch \"${dns_queries_log_file}\" \\
;fi

# set log file permission áfter the mount-binding was done
chown -R bind: \"${dns_log_path}\"
chmod 740 \"${dns_log_path}\"

/usr/sbin/named -f -c \"${dns_named_conf}\" -4 -u bind"

echo "${entrypoint}" > "${entrypoint_filename}"

chmod 755 "${entrypoint_filename}"
