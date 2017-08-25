#!/usr/bin/env bash

# set working directory
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../../ && pwd )"

# init the script
source "${ROOT_DIR}"/_bin/backup/_init.sh

######################################################
# create list of backup directories we want to keep! #
######################################################

mail+=("rotate")

echo ""
echo ""
echo -e "\033[1;42m +--------------------------------------+ \033[0m"
echo -e "\033[1;42m | Starting rotating backup directories | \033[0m"
echo -e "\033[1;42m +--------------------------------------+ \033[0m"
echo ""

# create haystack with files to keep
keep=()

# create array
removals=()

# last 8 days
for i in {0..7}; do keep[$(date -j -v-${i}d '+%Y%m%d')]=; done

# last 5 weeks (week ends on the last working day of each week)
for i in {0..4}; do keep[$(date -j -v-friday -v-${i}w '+%Y%m%d')]=; done

# last 13 months (month ends on the last working day of each month)
for i in {0..12}; do

    lwdotm=$(date -j -v-${i}m -v1d -v-1d '+%u')
    if [ ${lwdotm} == 7 ]; then diff=-3; elif [ ${lwdotm} == 6 ]; then diff=-2; else diff=-1; fi
    keep[$(date -j -v-${i}m -v1d -v${diff}d '+%Y%m%d')]=
done

# last 5 years (year ends on the last working day of the year)
for i in {0..4}; do
    lwdoty=$(date -j -v-${i}y -v1m -v1d -v-1d '+%u')
    if [ ${lwdoty} == 7 ]; then diff=-3; elif [ ${lwdoty} == 6 ]; then diff=-2; else diff=-1; fi
    keep[$(date -j -v-${i}y -v1m -v1d -v${diff}d '+%Y%m%d')]=
done

# loop through all directories in ${target_dir} and delete the one we no longer want
for directory in $(find ${target_dir} -type d -mindepth 1 -maxdepth 1); do

    # check if directory needs to be deleted
    # be defensive; check if directory actually exists
    if [[ "${!keep[@]}" != *"$(basename ${directory})"* ]] && [ -d "${directory}" ]; then

        removals+=("${directory}")
    fi
done

# show message if there are no directories to be removed
if [ ${#removals[@]} == 0 ]; then

    echo -e "\033[1;104m Info: there are no directories that need to be rotated \033[0m"
fi

# loop through the list of directories that need to be deleted
for directory in "${removals[@]}"; do

    rm -rf ${directory}
    echo " Removed directory; '${directory}'"
done

# add stats
stats+=("Backup directories rotate;${warnings_count};${errors_count}")

echo ""
echo -e "\033[1;42m Finished rotating backup directories \033[0m"


