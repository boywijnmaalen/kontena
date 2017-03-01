#!/bin/bash

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

# get current directory
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"

# make sure we always start in project root
cd ${ROOT_DIR}

# load config
source ${ROOT_DIR}/.env

# create .gitconfig in the local_user directory
if [ ! -e "${ROOT_DIR}/workspace/home/local_user/.gitconfig" ]; then \
    echo "${gitconfig}" > "${ROOT_DIR}/workspace/home/local_user/.gitconfig" \
;fi

# loop through PHP versions
for php_version in 5.6 7.0 7.1; do

    # change working directory
    cd "${ROOT_DIR}/workspace/etc/php/${php_version}"

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

    # copy php.ini to the workspace
    cp "${ROOT_DIR}"/php/${php_version}/php.ini ./cli

    # generate PHP-FPM Dockerfiles from a template
    exploded_php_version=(${php_version//./ });
    cat "${ROOT_DIR}"/php/Dockerfile-template \
        | sed -e "s|\$MAJOR_VERSION|${exploded_php_version[0]}|" \
        | sed -e "s|\$MINOR_VERSION|${exploded_php_version[1]}|" \
       > "${ROOT_DIR}"/php/${php_version}/Dockerfile

    # change working directory
    cd "${ROOT_DIR}"

done
