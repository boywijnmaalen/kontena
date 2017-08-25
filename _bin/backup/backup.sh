#!/usr/bin/env bash

# Notice: Script is built for Bash version 3 and up

# set working directory
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../../ && pwd )"

# backup files & directories
source "${ROOT_DIR}"/_bin/backup/files.sh

# backup MySQL databases
source "${ROOT_DIR}"/_bin/backup/mysql.sh

# rotate backup directories
source "${ROOT_DIR}"/_bin/backup/rotate.sh

# email backup results
source "${ROOT_DIR}"/_bin/backup/mail.sh
