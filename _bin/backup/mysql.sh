#!/usr/bin/env bash

# set working directory
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../../ && pwd )"

# init the script
source "${ROOT_DIR}"/_bin/backup/_init.sh

backup_directory+="/MySQL databases"

###################################
# start backup up mysql databases #
###################################

# add line to mail body
mail+=("<br /><hr />")
mail+=("<h2>&nbsp;&nbsp;Summary 'MySQL backup'</h2>")

echo ""
echo ""
echo -e "\033[1;42m +-----------------------+ \033[0m"
echo -e "\033[1;42m | Starting MySQL backup | \033[0m"
echo -e "\033[1;42m +-----------------------+ \033[0m"
echo ""

connection_retries=10

# check if database host is up and running, if not wait for it
for i in $(seq 1 "${connection_retries}"); do

    # A process normally has two outputs to screen: stdout (standard out), and stderr (standard error).
    # Normally informational messages go to sdout, and errors and alerts go to stderr.
    # You can turn off stdout for a command by doing
    # command >/dev/null

    # and turn off stderr by doing:
    # command 2>/dev/null

    # If you want both off, you can do:
    # command 2>&1 >/dev/null
    # The 2>&1 says send stderr to the same place as stdout.
    if [ $(mysqladmin ping -h "${mysql_host}" -u "${mysql_user}" -p"${mysql_pass}" -P "${mysql_port}" --connect-timeout=5 2>/dev/null) ]; then

        break
    else

        echo " MySQL connection (${i}/${connection_retries}) attempt failed; retrying..."

        if [ ${i} == "${connection_retries}" ]; then

            # define message
            message=" Cannot connect to database, exiting! "

            # echo & add line to mail body
            echo ""
            echo -e "\033[1;41m${message}\033[0m"
            mail+=($(html_error "${message}"))

            # define message
            message=" MySQL backup failed! "

            # echo & add line to mail body
            echo ""
            echo -e "\033[1;41m${message}\033[0m"
            mail+=($(html_error "${message}"))

            let errors_count++

            # add stats
            stats+=("Backup MySQL databases;${warnings_count};${errors_count}")

            return 1
        fi

        sleep 2
    fi
done

# define message
message=" Info: Connected to database host! "

# echo & add line to mail body
echo -e "\033[1;104m${message}\033[0m"
mail+=($(html_info "${message}"))

# get all databases
# the extra '()' around the mysql cmd turn the result into an array
databases=($(mysql -h "${mysql_host}" -u "${mysql_user}" -p"${mysql_pass}" -P "${mysql_port}" --skip-column-names -e "SHOW DATABASES;"))

exclude_dbs=(
    "information_schema"
    "performance_schema"
)

# loop through all found databases and remove the database names we don't want to backup
for i in "${!databases[@]}"; do

    if [[ "${exclude_dbs[@]}" == *"${databases[${i}]}"* ]]; then

        unset databases[${i}]
    fi
done
databases=("${databases[@]}")

# create mysql backup directory
if [ ! -d ${backup_directory} ]; then

    mkdir -p ${backup_directory}
    chmod 700 ${backup_directory}
fi

# loop through all databases
for i in "${!databases[@]}"; do

    database="${databases[i]}"

    # define message
    message=" ($(($i + 1))/${#databases[@]}) starting backup of MySQL database '${database}' "

    # echo & add line to mail body
    echo ""
    echo "${message}"
    mail+=($(html_plain "${message}"))

    # create backup filename
    backup_filename="${database}.sql.gz"

    # check if the backup file already exists, if so, do not continue as we might overwrite the existing backup file
    # as well as we cannot overwrite the backup file in the first place because of backup file file permissions (400)
    if [ -f "${backup_directory}/${backup_filename}" ]; then

        # define message
        message=" Warning: refused to backup MySQL database '${database}' because the backup file ('${backup_directory}/${backup_filename}') already exists "

        # echo & add line to mail body
        echo -e "\033[1;43m${message}\033[0m"
        mail+=($(html_warning "${message}"))

        let warnings_count++

        continue
    fi

    # check if the backup directory is writable
    if [ ! -w "$(dirname ${backup_directory}/${backup_filename})" ]; then

        # define message
        message=" Error: cannot backup MySQL database '${database}' because the backup directory ('$(dirname ${backup_directory}/${backup_filename})') is not writable "

        # echo & add line to mail body
        echo -e "\033[1;41m${message}\033[0m"
        mail+=($(html_error "${message}"))

        let errors_count++

        continue
    fi

    # Create database backup and compress using gzip.
    mysqldump -h "${mysql_host}" -u "${mysql_user}" -p"${mysql_pass}" -P "${mysql_port}" "${database}" | gzip -cN --best > ${backup_directory}/"${backup_filename}"

    # make it yours only
    if [ -f "${backup_directory}/${backup_filename}" ]; then

        chmod 400 "${backup_directory}/${backup_filename}"
    fi

    # define message
    message=" finished backup of MySQL database '${database}' to backup file; '${backup_directory}/${backup_filename}'"

    # echo & add line to mail body
    echo "${message}"
    mail+=($(html_ok "${message}"))
done

echo ""

# for completeness sake mention the skipped databases
for skipped_database in "${exclude_dbs[@]}"; do

    # define message
    message=" Info: skipped backup of database '${skipped_database}' because it was excluded "

    # echo & add line to mail body
    echo -e "\033[1;104m${message}\033[0m"
    mail+=($(html_info "${message}"))
done

# add stats
stats+=("Summary 'MySQL backup';${warnings_count};${errors_count}")

echo ""
echo -e "\033[1;42m Finished MySQL backup \033[0m"
