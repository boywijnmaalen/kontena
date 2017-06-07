#!/bin/bash

GITLAB_DIR=${ROOT_DIR}/gitlab

# load gitlab config
source ${GITLAB_DIR}/config.sh

# directory check
create_dir

# file check
create_file

# start building entrypoint.sh
entrypoint_filename=${GITLAB_DIR}/entrypoint.sh

entrypoint="#!/usr/bin/env bash

# enter working directory
cd /home/${GITLAB_LOCAL_USER}/gitlab

# start ssh
service ssh start

# start redis
service redis-server start

# add gitlab.dev.local to /etc/hosts, 172.16.0.3 is nginx
# added for command \`bundle exec rake gitlab:check\`
echo \"172.16.0.3	gitlab.dev.local\" >> /etc/hosts

# run database migrations (if any, mostly useful in the update context)
su -s /bin/sh ${GITLAB_LOCAL_USER} -c \"bundle exec rake db:migrate RAILS_ENV=${GITLAB_RAILS_ENV}\"

# change the ownership and permissions of the directory where GitLab repositories are stored
chown ${GITLAB_LOCAL_USER}:root /home/${GITLAB_LOCAL_USER}/repositories
chmod -R ug+rwX,o-rwx /home/${GITLAB_LOCAL_USER}/repositories
chmod -R ug-s /home/${GITLAB_LOCAL_USER}/repositories
find /home/${GITLAB_LOCAL_USER}/repositories -type d -print0 | xargs -0 chmod g+s

# start gitlab
service gitlab start

# unfortunately, the Gitlab web service - by default - can only be run as a daemon
# in order to let the container live forever we need to manually run the Gitlab web service as foreground process
# this however is not supported out of the box
su -s /bin/sh ${GITLAB_LOCAL_USER} -c \"bin/web stop\"

# give the previous script some time to finish
sleep 5

# run Gitlab as foreground service
su -s /bin/sh ${GITLAB_LOCAL_USER} -c \"bundle exec unicorn_rails -c config/unicorn.rb -E ${GITLAB_RAILS_ENV}\""

echo "${entrypoint}" > ${entrypoint_filename}

chmod 755 ${entrypoint_filename}
