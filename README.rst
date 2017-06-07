Kontena:
########

    A Docker PHP development environment

**Kontena** (`Swahili <https://en.wikipedia.org/wiki/Swahili_language>`_ for '*container*', pronounced: *Kon-tee-naa*) is a containerized PHP development environment.
Its goal is to create a platform independent environment.
It provides multiple `PHP-FPM (FastCGI Process Manager) <https://php-fpm.org/>`_ versions (`5.6 <https://github.com/php/php-src/tree/PHP-5.6>`_, `7.0 <https://github.com/php/php-src/tree/PHP-7.0>`_ & `7.1 <https://github.com/php/php-src/tree/PHP-7.1>`_),
is based on a `NGINX Web server <https://www.nginx.com/resources/wiki/>`_ and is accompanied by a `MariaDB (RDBMS) <https://mariadb.org/>`_ - a Relational Database Management System.

Check out the `Github.io/kontena <https://boywijnmaalen.github.io/kontena/>`_ and follow me on `Twitter <https://twitter.com/boywijnmaalen/>`_.

.. contents::

.. section-numbering::

Main features
=============

* Linux, Mac OS X and Windows support
* The project is designed for flexibility and being in control, this means that all config & logging is available on the host - outside their respective containers - for easy tailing and editing

Installation
============

Docker
------

* Install Docker for `Mac <https://docs.docker.com/docker-for-mac/install/>`_. Not familiar with Docker? `Get started <https://docs.docker.com/docker-for-mac/>`_!
* Install Docker for `Windows <https://docs.docker.com/docker-for-windows/install/>`_. Not familiar with Docker? `Get started <https://docs.docker.com/docker-for-windows/>`_!
* Install Docker for `Linux <https://docs.docker.com/engine/installation/#on-linux>`_.


Project
-------

* Run ``$ git clone git@github.com:boywijnmaalen/kontena.git`` or download the latest `here <https://github.com/boywijnmaalen/kontena/archive/master.zip>`_.

* Run ``$ cd kontena``
* Run ``$ cp .env.example .env``
* Update the config options in ``.env`` with your own values

**If you want to run a first time installation;**

Obviously you can run your containers via Docker for Mac's (D4M) default implementation of osxfs. Performance however can be abismal.
You can do so by running;

* Run ``$ ./_scripts/setup.sh && ./_scripts/start.sh``

But you can also make use of `d4m-nfs's <https://github.com/IFSight/d4m-nfs>`_ NFS mounts! (rather than the default osxfs implementation)
Read all about it in ``./readme-d4m-performance-improvement``.

Once it is installed you can start using it by running;

* Run ``$ ./_scripts/setup.sh && ./_scripts/start.sh nfs`` (mind the '**nfs**' parameter)

**If you want to do a re-installation from scratch;**

* Run ``$ docker-compose down --remove-orphans && ./_scripts/reset.sh && ./_scripts/start.sh``

  (you can optionally supply the '**nfs**' parameter here as well)

**Now go grab a coffee and be patient :)**

Notes:
 - *The script ./_scripts/start.sh will start the Docker application in the event it wasn't running already*
 - *You can run ./_scripts/setup.sh as often as you like*
 - *using the 'nfs' parameter requires the use of some sudo commands, your password therefor is required*

Optional
--------

* Add `vhosts`_ - Add more vhosts for your web server
* Add `SSH Keys`_ - Add SSH Keys for Github use or because you're to lazy to enter your password when logging into different servers :-)

Components
==========

* `Workspace`_
* `Nginx`_
* `PHP-FPM`_
* `MariaDB`_
* `Gitlab CE`_

Workspace
---------

The workspace is a separate container where you can login and use the tools you would on any regular development server setup, it makes sure you don't have to install any tools locally.
Just login into the container via ; ``$ docker-compose exec --user=admin workspace bash`` (make sure you're in the root directory of the Kontena project) and you're all set!
It comes pre-installed with PHP (so you can run it from the CLI), Git, Composer, NodeJS, Yarn, various PHP tools and Bower, Gulp and SASS if you're

Features
~~~~~~~~

* A fully customizable home directory (without rebuilding the container)
* Pre-defined scripts at your disposal (e.g. clean your directories of Mac files, etc)
* Pre-defined aliasses at your disposal (e.g. easy switching between PHP 5.6, 7.0 or 7.1, etc)
* A ``~/.bashrc`` that is filled with;

  * all kinds of additions (e.g. colored bash, custom aliases, etc)
  * GIT & NPM additions (e.g. auto-completion, cli hints, etc)

* Comes installed with;

  * `PHP 5.6 <https://github.com/php/php-src/tree/PHP-5.6/>`_
  * `PHP 7.0 <https://github.com/php/php-src/tree/PHP-7.0/>`_
  * `PHP 7.1 <https://github.com/php/php-src/tree/PHP-7.1/>`_
  * `Git <https://git-scm.com//>`_
  * `Composer <https://getcomposer.org//>`_
  * `NodeJS <https://nodejs.org/>`_
  * `Yarn <https://yarnpkg.com/>`_
  * `Codeception <http://codeception.com//>`_
  * `Deployer <https://deployer.org//>`_
  * `PHP Mess Detector <https://phpmd.org//>`_
  * `PHP Copy/Paste Detector (CPD) <https://github.com/sebastianbergmann/phpcpd/>`_
  * `PHP CodeSniffer <https://github.com/squizlabs/PHP_CodeSniffer/>`_
  * `PHPUnit <https://phpunit.de/>`_ `5.7 <https://github.com/sebastianbergmann/phpunit/tree/5.7/>`_ (PHP 5.6) & `6.0 <https://github.com/sebastianbergmann/phpunit/tree/6.0/>`_ (>= PHP 7.0)
  * `Splitsh-lite <https://github.com/splitsh/lite/>`_
  * `Bower <https://bower.io//>`_
  * `Gulp <http://gulpjs.com//>`_
  * `Node-sass <https://github.com/sass/node-sass/>`_


Switch between PHP version
~~~~~~~~~~~~~~~~~~~~~~~~~~

Run ``$ switchphp 5.6`` in order to switch to PHP version 5.6 (possible values; ``5.6``, ``7.0`` or ``7.1``)

SSH Keys
~~~~~~~~

You want to add your SSH keys to the workspace container? not a problem!

* Copy your **id_rsa** & **id_rsa.pub** files (or equivalent if your files are named differently) to directory ``workspace/home/local_user/.ssh``
* Make sure both files have permissions 600 (by running ``$ chmod 600 workspace/home/local_user/.ssh/id_rsa*`` - change the filename if you renamed your SSH Key), these files may not be read by anyone else

A trade-off has been made between security and convenience if you protected your SSH Key with a secure passphrase.
There is a little snippet included in ``~/.bashrc`` which automatically asks for your password upon first login to the Workspace container and saves it as long as the container is running.

If you stop/start or reboot the Workspace container, your secure passphrase will be required once more upon first login on the Workspace container.
(This snippet will also work if you decide to forward the host' ssh-agent to the Workspace container)

Nginx
-----

Nginx is a web server, which can also be used as a reverse proxy, load balancer and HTTP cache.

Features
~~~~~~~~

* All config (located in ``nginx/``) is editable without rebuilding the container
* A 100% valid SSL certificate (not self-signed!) which is valid for the `https://*.dev.local` domain.
* A vhost template (``nginx/vhost.conf``) for quick creation of new vhost configurations

Vhosts
~~~~~~

When starting a new development project you're probably going to need a new vhost.


Let's go with the following example;

    You want to create a new website located at https://dashboard.dev.local.
    All the project files will live in directory ``_data/sites/dashboard/``
    (The included SSL Certificate is valid for \*.dev.local domains, hence the example).

* First create the new web root directory ``_data/sites/dashboard`` by running: ``$ mkdir _data/sites/dashboard``
* Create a new vhost configuration file by copying the vhost template to the correct directory by running: ``$ cp nginx/vhost.conf nginx/sites-available/dashboard.conf``
* Update the '*root*' directive in the new ``nginx/sites-available/dashboard.conf`` vhost configuration file with the new web root path '``_data/sites/dashboard``'
* Update the '*server_name*' directive in the new ``nginx/sites-available/dashboard.conf`` vhost configuration file with the new hostname '``dashboard.dev.local``' (no 'http' or https' required here)
* Optionally update any of the other directives if you want to.

The new vhost is now ready for use! But for now, your host machine is not aware of the new hostname so we'll need to add it to its hosts file;

* If you are on Mac/Linux, add '``127.0.0.1	dashboard.dev.local``' to file ``/etc/hosts``, if you are on Windows add it to file ``c:\System32\drivers\etc\hosts``
* The last thing we need to do is tell Nginx there is a new vhost configuration. Nginx only gathers vhost information upon startup. The easiest way to do that is to restart the Nginx container by running ``docker-compose restart nginx``.

PHP-FPM
-------

PHP-FPM

Features
~~~~~~~~

Features

MariaDB
-------

MariaDB

MariaDB is a community-developed fork of the `MySQL <https://en.wikipedia.org/wiki/MySQL>`_ (`relational database management system <https://en.wikipedia.org/wiki/Relational_database_management_system>`_)

Features
~~~~~~~~

Features

Connect to MariaDB
~~~~~~~~~~~~~~~~~~

Connect to Mariadb by using IP ``172.16.0.7``

Gitlab CE
---------

`GitLab <https://about.gitlab.com>`_ is a web-based Git repository manager with wiki and issue tracking features, using an open source license.


Docker
======

.. image:: https://github.com/boywijnmaalen/kontena/raw/gh-pages/assets/images/docker-whale-container.png
    :width: 842 px
    :alt: Docker Whale Container
    :align: center

`Docker <https://www.docker.com//>`_ is an open source project to pack, ship and run any application as a lightweight container.
Docker containers are both hardware-agnostic and platform-agnostic. This means they can run anywhere.


Commands
--------



License
=======

??

Authors
=======

`Boy Wijnmaalen <https://boywijnmaalen.github.io>`_ (`@boywijnmaalen <https://twitter.com/boywijnmaalen/>`_) created Kontena and `these fine people <https://github.com/boywijnmaalen/kontena/graphs/contributors/>`_ have contributed.
