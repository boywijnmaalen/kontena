#!/usr/bin/env bash

WORKSPACE_DIR=${ROOT_DIR}/workspace

# load .env config (only needed when this file is called directly)
source "${ROOT_DIR}"/.env

# load php config
source "${WORKSPACE_DIR}"/config.sh

# directory check
create_dir

#################################################
# create .gitconfig in the local_user directory #
#################################################

gitconfig="[user]
    name = \"${GIT_NAME}\"
    email = \"${GIT_EMAIL}\"
[core]
    excludesfile = \"~/tools/git/.gitignore_global\"
    autocrlf = ${GIT_AUTO_CRLF}
    repositoryformatversion = ${GIT_REPOSITORY_FORMAT_VERSION}
    filemode = ${GIT_FILE_MODE}
    bare = ${GIT_BARE}
    logallrefupdates = ${GIT_LOG_ALL_REF_UPDATES}
    ignorecase = ${GIT_IGNORE_CASE}
[color]
    ui = true"

if [ ! -e "${WORKSPACE_DIR}/home/local_user/.gitconfig" ]; then \
    echo "${gitconfig}" > "${WORKSPACE_DIR}/home/local_user/.gitconfig" \
;fi

############################
# set other config options #
############################

# set permissions for SSH Keys
if [ -e "${WORKSPACE_DIR}"/home/local_user/.ssh/id_rsa ]; then \
    chmod 600 "${WORKSPACE_DIR}"/home/local_user/.ssh/id_* \
;fi

# loop through PHP versions
for php_version in ${PHP_VERSIONS[*]}; do

    # generate local PHP log files
    exploded_php_version=(${php_version//./ });

    # create php log files
    files=("${php_log_files[@]}")
    files=("${files[@]/\$MAJOR_VERSION/${exploded_php_version[0]}}")
    files=("${files[@]/\$MINOR_VERSION/${exploded_php_version[1]}}")

    # create file
    create_file
done

################################
# start building entrypoint.sh #
################################
entrypoint_filename=${WORKSPACE_DIR}/entrypoint.sh

# create entrypoint.sh
entrypoint="#!/usr/bin/env bash

# generate local PHP log files for each version of PHP
for php_version in ${PHP_VERSIONS[*]}; do \\

    exploded_php_version=\"\${php_version//./}\"

    # check if php ${php_version} error log exists
    php_fpm_log_file=/var/log/php\${exploded_php_version[0]}\${exploded_php_version[1]}-fpm.log
    if [ ! -e \"\${php_fpm_log_file}\" ]; then \\

        touch \"\${php_fpm_log_file}\" \\
    ;fi

    # check if php ${php_version} opcache log exists
    php_opcache_log_file=/var/log/php\${exploded_php_version[0]}\${exploded_php_version[1]}-opcache.log
    if [ ! -e \"\${php_opcache_log_file}\" ]; then \\

        touch \"\${php_opcache_log_file}\" \\
    ;fi

    # set log file permission áfter the mount-binding was done
    chown ${WORKSPACE_LOCAL_USER}: \"\${php_fpm_log_file}\" \"\${php_opcache_log_file}\"
    chmod 644 \"\${php_fpm_log_file}\" \"\${php_opcache_log_file}\"

done

# add gitlab.dev.local to /etc/hosts, 172.16.0.8 is gitlab
# added for command for command \'git clone git@gitlab.dev.local:namspace/project.git\'
if ! grep -q \"172.16.0.8\" \"/etc/hosts\"; then
  echo \"\" >> /etc/hosts
  echo \"172.16.0.8	gitlab.dev.local\" >> /etc/hosts
fi

dir=/home/${WORKSPACE_LOCAL_USER}/.ssh
if [ -d \${dir}/.ssh ] && [ \"\$(ls -A \"\${dir}\")\" ]; then
  # chmod all SSH keys to 600 (except .files)
  chmod 600 \${dir}/*

  # make public keys readable to other users
  chmod 644 \${dir}/*.pub
fi

# make the container run forever
/sbin/my_init"

echo "${entrypoint}" > "${entrypoint_filename}"

chmod 755 "${entrypoint_filename}"
