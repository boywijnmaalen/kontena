#!/bin/bash

# get current directory
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"

# start with clean $HOME dir
cd "${ROOT_DIR}/workspace/home/local_user/"
rm -rf ./.cache/ ./.composer/ ./.config/
rm ./.sudo_as_admin_successful ./.v8flags.5.5.372.40.undefined.json

source ${ROOT_DIR}/_scripts/setup.sh
