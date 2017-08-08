#!/bin/bash

# get project root directory
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"

# start with clean $HOME dir
cd "${ROOT_DIR}/workspace/home/local_user/"
rm -rf ./.cache/ ./.composer/ ./.config/
rm ./.sudo_as_admin_successful ./.v8flags.5.5.372.40.undefined.json

# @TODO; reset all existing log files

# run setup
source ${ROOT_DIR}/_bin/setup.sh
