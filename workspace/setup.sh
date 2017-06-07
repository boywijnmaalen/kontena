#!/usr/bin/env bash

WORKSPACE_DIR=${ROOT_DIR}/workspace

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

# create .gitconfig in the local_user directory
if [ ! -e "${WORKSPACE_DIR}/home/local_user/.gitconfig" ]; then \
    echo "${gitconfig}" > "${WORKSPACE_DIR}/home/local_user/.gitconfig" \
;fi

# set permissions for SSH Keys
chmod 600 ${WORKSPACE_DIR}/home/local_user/.ssh/id_*

# loop through PHP versions
for php_version in 5.6 7.0 7.1; do

    # change working directory
    cd "${WORKSPACE_DIR}/etc/php/${php_version}"

    # symlink all files
    for ini_file in `find mods-available -type f -name '*.ini' | sed 's:.*/::'` ;do \

        case ${ini_file} in \

            mysqlnd.ini|opcache.ini|pdo.ini) \
                target_ini_file="10-${ini_file}"
            ;;
            xml.ini) \
                target_ini_file="15-${ini_file}"
            ;;
            memcached.ini) \
                target_ini_file="25-${ini_file}"
            ;;
            *) \
                target_ini_file="20-${ini_file}"
            ;;
        esac

        ln -sf ../../mods-available/${ini_file} cli/conf.d/${target_ini_file} \
    ;done

done


# start building entrypoint.sh
entrypoint_filename=${WORKSPACE_DIR}/entrypoint.sh

# create entrypoint.sh
entrypoint="#!/usr/bin/env bash

# add gitlab.dev.local to /etc/hosts, 172.16.0.8 is gitlab
# added for command for command \'git clone git@gitlab.dev.local:namspace/project.git\'
echo \"172.16.0.8	gitlab.dev.local\" >> /etc/hosts

# make the container run forever
/sbin/my_init"

echo "${entrypoint}" > ${entrypoint_filename}

chmod 755 ${entrypoint_filename}
