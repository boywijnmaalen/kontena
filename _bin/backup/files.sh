#!/bin/bash

# set working directory
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../../ && pwd )"

# init the script
source "${ROOT_DIR}"/_bin/backup/_init.sh

#######################################
# Starting backup files & directories #
#######################################

# add line to mail body
mail+=("<h2>&nbsp;&nbsp;Summary 'backup files & directories'</h2>")

echo ""
echo ""
echo -e "\033[1;42m +-------------------------------------+ \033[0m"
echo -e "\033[1;42m | Starting backup files & directories | \033[0m"
echo -e "\033[1;42m +-------------------------------------+ \033[0m"
echo ""

# create list with directories to backup
compress_dirs=()
for i in "${!source_dirs[@]}"; do

    directory="${source_dirs[$i]}"
    if [ "${source_dirs[$i]:(-2)}" == "/*" ]; then

        directory="${source_dirs[$i]/\/\*}"
    fi

    # be defensive; check if directory actually exists, if not skip this iteration
    if [ ! -d "${directory}" ]; then

        # define message
        message=" Warning: directory '${directory}' does not exist and is therefore not included in the backup process! "

        # echo & add line to mail body
        echo -e "\033[1;43m${message}\033[0m"
        mail+=($(html_warning "${message}"))

        let warnings_count++

        continue;
    fi

    # if the directory name does not end with '*' then we want the tar the directory itself
    if [ "${source_dirs[$i]:(-2)}" != "/*" ]; then

        compress_dirs+=("${source_dirs[$i]}")

    # if the directory name ends with a '*' then we want to tar all depth=1 child directories instead
    else

        # loop through all child directories (not including the source director itself)
        for sub_directory in $(find "${source_dirs[$i]/\/\*}" -type d -mindepth 1 -maxdepth 1); do

            # check if the current sub_directory wasn't already added to the compress_dirs list
            # AND check if the current sub_directory wasn't already defined in the source_dirs list
            # if so; add it to the compress_dirs list
            if ! in_array "${sub_directory}" compress_dirs && ! in_array "${sub_directory}/*" source_dirs; then

                compress_dirs+=("${sub_directory}")
            fi
        done
    fi
done

# create list of files and directories that need to be excluded from the backup
for i in "${!excludes[@]}"; do

    excludes[${i}]="--exclude=${excludes[${i}]}"
done

# start backup process
for i in "${!compress_dirs[@]}"; do

    directory="${compress_dirs[$i]}"

    # define message
    message=" ($(($i + 1))/${#compress_dirs[@]}) starting backup of '${directory}'"

    # echo & add line to mail body
    echo ""
    echo "${message}"
    mail+=("${message}")

    backup_filename="$(basename ${directory})"
    if [[ "${directory}" == *"${ROOT_DIR}"* ]]; then

        backup_filename=$(echo "${directory}" | sed "s|${ROOT_DIR}||")
        backup_filename=${backup_filename:(1)}
    fi

    # create backup directory if doesn't already exist
    if [ ! -d "$(dirname ${backup_directory}/${backup_filename})" ]; then

        mkdir -p "$(dirname ${backup_directory}/${backup_filename})"
    fi

    backup_filename+=".tgz"

    # check if the backup file already exists, if so, do not continue as we might overwrite the existing backup file
    # as well as we cannot overwrite the backup file in the first place because of backup file file permissions (400)
    if [ -f "${backup_directory}/${backup_filename}" ]; then

        # define message
        message=" Warning: refused to backup source directory '${directory}' because the backup file ('${backup_directory}/${backup_filename}') already exists "

        # echo & add line to mail body
        echo -e "\033[1;43m${message}\033[0m"
        mail+=($(html_warning "${message}"))

        let warnings_count++

        continue
    fi

    # check if the backup directory is writable
    if [ ! -w "$(dirname ${backup_directory}/${backup_filename})" ]; then

        # define message
        message=" Error: cannot backup source directory '${directory}' because the backup directory ('$(dirname ${backup_directory}/${backup_filename})') is not writable "

        # echo & add line to mail body
        echo -e "\033[1;41m${message}\033[0m"
        mail+=($(html_error "${message}"))

        let errors_count++

        continue
    fi

    # want a progress bar as well?
    # make sure the command 'pv' is installed on the system
    # and add '| pv -s $(($(du -sk ${directory} | awk '{print $1}') * 1024))' between '[..] . |' and 'gzip -cN [..]'

    # start (compressed) backup of folder
    COPYFILE_DISABLE=1 COPY_EXTENDED_ATTRIBUTES_DISABLE=1 tar -c "${excludes[@]}" -C "${directory}" . | gzip -cN --best > "${backup_directory}/${backup_filename}"

    # make it yours only
    if [ -f "${backup_directory}/${backup_filename}" ]; then

        chmod 400 "${backup_directory}/${backup_filename}"
    fi

    # define message
    message=" finished backup of directory '${directory}' to backup file; '${backup_directory}/${backup_filename}'"

    # echo & add line to mail body
    echo "${message}"
    mail+=("${message}")

done

mail+=("<br /><hr />")

# add stats
stats+=("Backup Files & Directories;${warnings_count};${errors_count}")

echo ""
echo -e "\033[1;42m Finished backup files & directories \033[0m"
