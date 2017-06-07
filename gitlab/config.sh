#!/usr/bin/env bash

data_dir=${DATA_DIR}/gitlab/repositories
log_dir=${LOG_DIR}/gitlab
project_dir=${ROOT_DIR}/gitlab

directories=(
    ${data_dir}
    ${log_dir}
    ${project_dir}/home/local_user/.ssh
);

files=(
    ${log_dir}/application.log
    ${log_dir}/gitaly.log
    ${log_dir}/gitlab-workhorse.log
    ${log_dir}/sidekiq.log
    ${log_dir}/unicorn.stderr.log
    ${log_dir}/unicorn.stdout.log
    ${log_dir}/${GITLAB_RAILS_ENV}.log
    ${project_dir}/home/local_user/.ssh/authorized_keys
);
