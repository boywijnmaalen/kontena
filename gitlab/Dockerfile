FROM ubuntu:16.04

ARG DEV_ENVIRONMENT=${DEV_ENVIRONMENT}
ARG GITLAB_ADMIN_EMAIL=${GITLAB_ADMIN_EMAIL}
ARG GITLAB_ADMIN_PASSWORD=${GITLAB_ADMIN_PASSWORD}
ARG GITLAB_LOCAL_USER=${GITLAB_LOCAL_USER}
ARG GITLAB_MYSQL_USER=${GITLAB_MYSQL_USER}
ARG GITLAB_MYSQL_PASSWORD=${GITLAB_MYSQL_PASSWORD}
ARG GITLAB_MYSQL_DATABASE=${GITLAB_MYSQL_DATABASE}
ARG GITLAB_RAILS_ENV=production
ARG GITLAB_RESET_DATABASE=false

# output message wheter a new or existing database will be used
RUN if [ ${GITLAB_RESET_DATABASE} = true ]; then \

    echo "\033[0;32m===> Gitlab will be installed with a clean database. Abort if you do not want this and \033[4;32mremove the build-arg 'GITLAB_RESET_DATABASE'\033[0m" \
;else \
    echo "\033[0;31m===> Gitlab will be installed using an existing database. Abort if you want Gitlab to be installed with a clean database, add; \033[4;31m'--build-arg GITLAB_RESET_DATABASE=true'\033[0;31m to your docker build command\033[0m" \
;fi

# https://www.kernel.org/pub/software/scm/git/
ARG GIT_VERSION=2.9.4
# https://cache.ruby-lang.org/pub/ruby/
ARG RUBY_VERSION=2.4.1
# https://golang.org/dl/
ARG GO_VERSION=1.8.3
# https://gitlab.com/gitlab-org/gitlab-ce/branches
ARG GITLAB_VERSION=9-3

# prevent error like 'debconf: unable to initialize frontend: Dialog' because not all packages support 'interactive' mode
# change the way debconf (Debian Package Configuration System) configures packages
# 'noninteractive' is needed for the build steps as all packages must work in noninteractive mode as well
ENV DEBIAN_FRONTEND noninteractive

# set auto config for postfix
RUN ["/bin/bash", "-c", "debconf-set-selections <<< \"postfix postfix/mailname string gitlab.dev.local\""] \
    && ["/bin/bash", "-c", "debconf-set-selections <<< \"postfix postfix/main_mailer_type string 'Internet Site'\""]

# install the required packages (needed to compile Ruby and native extensions to Ruby gems):
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        zlib1g-dev \
        libyaml-dev \
        libssl-dev \
        libgdbm-dev \
        libreadline-dev \
        libncurses5-dev \
        libffi-dev \
        curl \
        sudo \
        openssh-server \
        checkinstall \
        libxml2-dev \
        libxslt-dev \
        libcurl4-openssl-dev \
        libicu-dev \
        logrotate \
        python-docutils \
        pkg-config \
        cmake \
        libexpat1-dev \
        gettext \
        libz-dev \
        tzdata \
        postfix \
        mysql-client \
        libmysqlclient-dev

# if DEV_ENVIRONMENT = true, install dev tools
RUN if [ ${DEV_ENVIRONMENT} = true ]; then \

    apt-get install -y --no-install-recommends \
        apt-utils \
        bash \
        mlocate \
        net-tools \
        vim \
        wget \
        tcpdump \
        telnet \
        inetutils-ping \
    && update-alternatives --set editor /usr/bin/vim.basic \
;fi

# system packaged Git is too old, compile from source, need at least 2.8.4
RUN cd /tmp \
    && curl --remote-name --progress https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz \
    && tar -zxvf git-${GIT_VERSION}.tar.gz \
    && cd git-${GIT_VERSION}/ \
    && ./configure \
    && make prefix=/usr/local all \
    && make prefix=/usr/local install

# ruby, first remove previous
RUN apt-get remove ruby1.8 \
    && mkdir /tmp/ruby \
    && cd /tmp/ruby \
    && curl --remote-name --progress https://cache.ruby-lang.org/pub/ruby/ruby-${RUBY_VERSION}.tar.gz \
    && tar -zxvf ruby-${RUBY_VERSION}.tar.gz \
    && cd ruby-${RUBY_VERSION} \
    && ./configure --disable-install-rdoc \
    && make \
    && make install \
    && gem install bundler --no-ri --no-rdoc

# go, first remove previous go installation directory
RUN rm -rf /usr/local/go \
    && mkdir /tmp/go \
    && cd /tmp/go \
    && curl --remote-name --progress https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && ln -sf /usr/local/go/bin/go /usr/local/bin/ \
    && ln -sf /usr/local/go/bin/godoc /usr/local/bin/ \
    && ln -sf /usr/local/go/bin/gofmt /usr/local/bin/

# install NodeJS
RUN mkdir /tmp/nodejs \
    && cd /tmp/nodejs \
    && curl --location https://deb.nodesource.com/setup_7.x | bash - \
    && apt-get install -y --no-install-recommends nodejs

# install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends yarn

# create a new git user for gitlab
RUN adduser --disabled-login --gecos 'GitLab' ${GITLAB_LOCAL_USER}

# install redis
RUN apt-get install -y --no-install-recommends redis-server \
    && cp /etc/redis/redis.conf /etc/redis/redis.conf.orig \
    && sed 's/^port .*/port 0/' /etc/redis/redis.conf.orig | tee /etc/redis/redis.conf \
    && echo 'unixsocket /var/run/redis/redis.sock' | tee -a /etc/redis/redis.conf \
    && echo 'unixsocketperm 770' | tee -a /etc/redis/redis.conf \
    && mkdir /var/run/redis \
    && chown redis:redis /var/run/redis \
    && chmod 755 /var/run/redis \
    && if [ -d /etc/tmpfiles.d ]; then \
        echo 'd  /var/run/redis  0755  redis  redis  10d  -' | tee -a /etc/tmpfiles.d/redis.conf \
    ;fi \
    && usermod -aG redis ${GITLAB_LOCAL_USER}

WORKDIR /home/${GITLAB_LOCAL_USER}

# install Gitlab, first enter ${GITLAB_LOCAL_USER} home directory
RUN sudo -u ${GITLAB_LOCAL_USER} -H git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b ${GITLAB_VERSION}-stable gitlab

WORKDIR /home/${GITLAB_LOCAL_USER}/gitlab

# start configuring Gitlab
# Disabling use DNS in ssh since it tends to slow connecting
RUN echo "UseDNS no" >> /etc/ssh/sshd_config \
    # make sure GitLab can write to the log/ and tmp/ directories
    && chown -R ${GITLAB_LOCAL_USER} log/ \
    && chown -R ${GITLAB_LOCAL_USER} tmp/ \
    && chmod -R u+rwX,go-w log/ \
    && chmod -R u+rwX tmp/ \
    # make sure GitLab can write to the tmp/pids/ and tmp/sockets/ directories
    && chmod -R u+rwX tmp/pids/ \
    && chmod -R u+rwX tmp/sockets/ \
    # change the permissions of the directory where CI job traces are stored
    && chmod -R u+rwX builds/ \
    # change the permissions of the directory where CI artifacts are stored
    && chmod -R u+rwX shared/artifacts/ \
    # change the permissions of the directory where GitLab Pages are stored
    && chmod -R ug+rwX shared/pages/ \
    # copy the GitLab service
    && cp lib/support/init.d/gitlab /etc/init.d/gitlab \
    && cp lib/support/init.d/gitlab.default.example /etc/default/gitlab \
    # make GitLab start on boot:
    && update-rc.d gitlab defaults 21 \
    # restrict Gitaly socket access
    && chmod 0700 /home/${GITLAB_LOCAL_USER}/gitlab/tmp/sockets/private \
    && chown ${GITLAB_LOCAL_USER} /home/${GITLAB_LOCAL_USER}/gitlab/tmp/sockets/private \
    # setup Logrotate
    && cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab

# switch to git user
USER ${GITLAB_LOCAL_USER}

# create directory where GitLab repositories are stored
RUN mkdir /home/${GITLAB_LOCAL_USER}/repositories \
    # make sure only the GitLab user has access to the public/uploads/ directory
    # files in public/uploads are served by gitlab-workhorse
    && mkdir -p public/uploads/tmp \
    && chmod 0700 public/uploads \
    && chmod 0700 public/uploads/tmp \
    # copy the example GitLab config
    && cp config/gitlab.yml.example config/gitlab.yml \
    # copy the example secrets file and make it only readable for the git user
    && cp config/secrets.yml.example config/secrets.yml \
    && chmod 0600 config/secrets.yml \
    # copy the database file and make it only readable for the git user
    && cp config/database.yml.mysql config/database.yml \
    && chmod 0600 config/database.yml \
    # copy the example Rack attack config
    && cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb \
    # configure Git global settings for git user, 'autocrlf' is needed for the web editor
    && git config --global core.autocrlf input \
    # disable 'git gc --auto' because GitLab already runs 'git gc' when needed
    && git config --global gc.auto 0 \
    # enable packfile bitmaps
    && git config --global repack.writeBitmaps true \
    # as we installed git from source we need to change the Git executable path in our config/gitlab.yml config file
    && sed -i -e 's|bin_path: /usr/bin/git|bin_path: /usr/local/bin/git|g' config/gitlab.yml \
    # update database credentials
    # two reasons for doing this during build;
    # - Gitlab needs - if requested - install a new database
    # -
    && sed -i -e "s|database: gitlabhq_production|database: ${GITLAB_MYSQL_DATABASE}|g" config/database.yml \
    && sed -i -e "s|username: git|username: ${GITLAB_MYSQL_USER}|g" config/database.yml \
    && sed -i -e "s|password: \"secure password\"|password: \"${GITLAB_MYSQL_PASSWORD}\"|g" config/database.yml \
    && sed -i -e "s|# host: localhost|host: mariadb|g" config/database.yml

# initialize database and activate advanced features
# https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/install/database_mysql.md
# https://gist.github.com/steinkel/6855062
RUN if [ ${GITLAB_RESET_DATABASE} = true ]; then \

    echo "yes" | bundle exec rake gitlab:setup RAILS_ENV=${GITLAB_RAILS_ENV} GITLAB_ROOT_PASSWORD=${GITLAB_ADMIN_PASSWORD} GITLAB_ROOT_EMAIL=${GITLAB_ADMIN_EMAIL} \
;fi

# install Gems
RUN bundle install --deployment --without development test postgres aws kerberos \
    # install gitlab-shell
    && bundle exec rake gitlab:shell:install REDIS_URL=unix:/var/run/redis/redis.sock RAILS_ENV=${GITLAB_RAILS_ENV} SKIP_STORAGE_VALIDATION=true \
    # install gitlab-workhorse
    && bundle exec rake "gitlab:workhorse:install[/home/${GITLAB_LOCAL_USER}/gitlab-workhorse]" RAILS_ENV=${GITLAB_RAILS_ENV} \
    # install Gitaly
    && bundle exec rake "gitlab:gitaly:install[/home/${GITLAB_LOCAL_USER}/gitaly]" RAILS_ENV=${GITLAB_RAILS_ENV} \
    # install assets, update node dependencies and recompile assets
    && bundle exec rake yarn:install gitlab:assets:compile RAILS_ENV=${GITLAB_RAILS_ENV} NODE_ENV=${GITLAB_RAILS_ENV}


USER root

# set the right permission for the repository folder, this time with root privileges
RUN find /home/${GITLAB_LOCAL_USER}/repositories -type d -print0 | xargs -0 chmod g+s

# clean up
RUN apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc /usr/share/locale /var/log/apt/* /var/log/*.log \
    && dpkg -la | awk '{print $2}' | grep '\-dev' | xargs apt-get remove -y

# fallback to the 'teletype' for  debconf
# this way both interactive and non-interactive modes get set
# 'teletype' is needed for interactive configuration steps the user might want to do inside a running container
ENV DEBIAN_FRONTEND teletype

# expose gitlab and ssh server
EXPOSE 8080 22
