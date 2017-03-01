Kontena:
#######

    A Docker PHP development environment

**Kontena** (`Swahili <https://en.wikipedia.org/wiki/Swahili_language>`_ for '*container*', pronounced: *Kon-tee-naa*) is a containerized PHP development environment.
Its goal is to create a platform independent environment.
It provides multiple `PHP-FPM <https://php-fpm.org/>`_ (FastCGI Process Manager) versions (`5.6 <https://github.com/php/php-src/tree/PHP-5.6>`_, `7.0 <https://github.com/php/php-src/tree/PHP-7.0>`_ & `7.1 <https://github.com/php/php-src/tree/PHP-7.1>`_),
is based on a `NGINX <https://www.nginx.com/resources/wiki/>`_ web server and is accompanied by a `MariaDB <https://mariadb.org/>`_ relational database management system.

Check out the `Github.io/kontena <https://boywijnmaalen.github.io/kontena/>`_ and follow me on `Twitter <https://twitter.com/boywijnmaalen/>`_.

.. contents::

.. section-numbering::

Main features
=============

* Linux, Mac OS X and Windows support

Installation
============

Docker
------

* Install Docker for `Mac <https://docs.docker.com/docker-for-mac/install/>`_. Not familiar with Docker? `Get started <https://docs.docker.com/docker-for-mac/>`_!
* Install Docker for `Windows <https://docs.docker.com/docker-for-windows/install/>`_. Not familiar with Docker? `Get started <https://docs.docker.com/docker-for-windows/>`_!
* Install Docker for `Linux <https://docs.docker.com/engine/installation/#on-linux>`_.


Project
-------

* Run ``git clone git@github.com:boywijnmaalen/kontena.git``
* Run ``cd kontena``
* Run ``cp .env.example .env``
* Update the config options in ``.env`` with your own values

If you want to run a first time installation;

* Run ``./_scripts/setup.sh && docker-compose up -d --build``

If you want to do a re-installation from scratch;

* Run ``docker-compose down --remove-orphans && ./_scripts/reset.sh && docker-compose up -d --build``

Now be *patient* :)

Optional
--------

* add Nginx vhosts
* add SSH Keys

Components
==========

* Workspace_
* Nginx_
* PHP-FPM_
* MariaDB_

Workspace
---------

Features
~~~~~~~~

* A fully customizable home directory (without rebuilding the container)
* Pre-defined scripts at your disposal (e.g. clean your directories of Mac files, etc)
* Pre-defined aliasses at your disposal (e.g. easy switching between PHP 5.6, 7.0 or 7.1, etc)
* A ``~/.bashrc`` that if filed with;

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
  * `PHPUnit <https://phpunit.de/>`_ `5.7 <https://github.com/sebastianbergmann/phpunit/tree/5.7/>`_ (for PHP 5.6) & `6.0 <https://github.com/sebastianbergmann/phpunit/tree/6.0/>`_ (for >= PHP 7.0)
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

Nginx

Features
~~~~~~~~

Features

PHP-FPM
-------

PHP-FPM

Features
~~~~~~~~

Features

MariaDB
-------

MariaDB

Features
~~~~~~~~

Features

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
