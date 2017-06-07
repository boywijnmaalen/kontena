#!/bin/bash

GITLAB_DIR=${ROOT_DIR}/gitlab

# load gitlab config
source ${GITLAB_DIR}/config.sh

# directory check
create_dir

# file check
create_file

####################################
# synchronize gitlab configuration #
####################################

# synchronise gitlab' (updated) config files on host

# gitlab - gitlab.yml
gitlab_config_dir=${GITLAB_DIR}/home/local_user/gitlab
curl -LsS https://gitlab.com/gitlab-org/gitlab-ce/raw/${GITLAB_VERSION}-stable/config/gitlab.yml.example -o ${gitlab_config_dir}/config/gitlab.yml
sed -i -e "s|host: localhost|host: gitlab.dev.local|g" ${gitlab_config_dir}/config/gitlab.yml
sed -i -e "s|trusted_proxies:|trusted_proxies:\n- 172.16.0.5\n- 2001:3984:3989::5|" ${gitlab_config_dir}/config/gitlab.yml


#"'/^a test$/{$!{N;s/^a test\nPlease do not$/not a test\nBe/;ty;P;D;:y}}' alpha.txt
#sed '/^a test$/{$!{N;s/  /;ty;P;D;:y}}' alpha.txt

################################
# start building entrypoint.sh #
################################
entrypoint_filename=${GITLAB_DIR}/entrypoint.sh

entrypoint="#!/usr/bin/env bash

# enter working directory
cd /home/${GITLAB_LOCAL_USER}/gitlab-ce

# start ssh
service ssh start

# start redis
service redis-server start

# add gitlab.dev.local to /etc/hosts, 172.16.0.5 is nginx,
# added for command \`bundle exec rake gitlab:check\`
echo \"172.16.0.5	nginx.dev.local\" >> /etc/hosts
echo \"172.16.0.7	mariadb.dev.local\" >> /etc/hosts
echo \"172.16.0.8	gitlab.dev.local\" >> /etc/hosts

# check if database host is up and running, if not wait for it
while !(mysqladmin ping -h mariadb -u ${GITLAB_MYSQL_USER} -p${GITLAB_MYSQL_PASSWORD} > /dev/null 2>&1)
do
        echo \"Waiting for database connection...\" >> /home/${GITLAB_LOCAL_USER}/gitlab-ce/log/${GITLAB_RAILS_ENV}.log
        sleep 2
done

echo \"Connected to database host!\" >> /home/${GITLAB_LOCAL_USER}/gitlab-ce/log/${GITLAB_RAILS_ENV}.log

# setup/update database
DATABASE_SHOW_RESULT=\`mysql -h mariadb -u ${GITLAB_MYSQL_USER} -p${GITLAB_MYSQL_PASSWORD} --skip-column-names -e \"SHOW DATABASES LIKE '${GITLAB_MYSQL_DATABASE}'\"\`

echo \"INFO: Result of Gitlab Database check (should be '${GITLAB_MYSQL_DATABASE}'): '\${DATABASE_SHOW_RESULT}'\" >> /home/${GITLAB_LOCAL_USER}/gitlab-ce/log/${GITLAB_RAILS_ENV}.log

if [ \"\${DATABASE_SHOW_RESULT}\" == \"${GITLAB_MYSQL_DATABASE}\" ]; then

    # log the fact we're going to migrate the existing database
    echo \"INFO: Start migrating existing database\" >> /home/${GITLAB_LOCAL_USER}/gitlab-ce/log/${GITLAB_RAILS_ENV}.log

    # run database migrations (if any, mostly useful in the update context)
    su -s /bin/sh git -c \"bundle exec rake db:migrate RAILS_ENV=${GITLAB_RAILS_ENV}\"
else

    # log the fact we're going to install a clean database
    echo \"INFO: Start clean database installation\" >> /home/${GITLAB_LOCAL_USER}/gitlab-ce/log/${GITLAB_RAILS_ENV}.log

    # run database install
    echo \"yes\" | bundle exec rake gitlab:setup \\
        RAILS_ENV=${GITLAB_RAILS_ENV} \\
        GITLAB_ROOT_PASSWORD=${GITLAB_ADMIN_PASSWORD} \\
        GITLAB_ROOT_EMAIL=${GITLAB_ADMIN_EMAIL}
fi

# make sure /home/${GITLAB_LOCAL_USER}/repositories/ has the right permissions in case it is mounted as a volume.
sudo chmod ug+rwX,o-rwx /home/${GITLAB_LOCAL_USER}/repositories/
sudo chmod ug-s /home/${GITLAB_LOCAL_USER}/repositories/
find /home/${GITLAB_LOCAL_USER}/repositories/ -type d -print0 | sudo xargs -0 chmod g+s
chown -R ${GITLAB_LOCAL_USER}: /home/${GITLAB_LOCAL_USER}/repositories

# make sure /home/${GITLAB_LOCAL_USER}/.ssh/ has the right permissions in case it is mounted as a volume.
touch /home/${GITLAB_LOCAL_USER}/.ssh/authorized_keys
chmod 700 /home/${GITLAB_LOCAL_USER}/.ssh
chmod 600 /home/${GITLAB_LOCAL_USER}/.ssh/authorized_keys
chown -R ${GITLAB_LOCAL_USER}: /home/${GITLAB_LOCAL_USER}/.ssh

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

echo "${entrypoint}" > "${entrypoint_filename}"

chmod 755 "${entrypoint_filename}"
