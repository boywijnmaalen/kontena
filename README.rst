Kontena:
########

    A Docker PHP development environment

**Kontena** (`Swahili <https://en.wikipedia.org/wiki/Swahili_language>`_ for '*container*', pronounced: *Kon-tee-naa*) is a containerized PHP development environment.
Its goal is to create an independent software development platform in the context of PHP and other Open-Source technologies.

It provides;

- Multiple `PHP-FPM (FastCGI Process Manager) <https://php-fpm.org/>`_ versions (`5.6 <https://github.com/php/php-src/tree/PHP-5.6>`_, `7.0 <https://github.com/php/php-src/tree/PHP-7.0>`_, `7.1 <https://github.com/php/php-src/tree/PHP-7.1>`_, `7.2 <https://github.com/php/php-src/tree/PHP-7.2>`_, `7.3 <https://github.com/php/php-src/tree/PHP-7.3>`_, `7.4 <https://github.com/php/php-src/tree/PHP-7.4>`_ & `8.0 <https://github.com/php/php-src/tree/PHP-8.0>`_).
- `CockroachDB <https://www.cockroachlabs.com/>`_ - Distributed SQL database management system
- `Bind9 <https://www.isc.org/bind/>`_ - DNS for the dev.local domain (forwarder for all other queries)
- `MariaDB (RDBMS) <https://mariadb.org/>`_ - Relational Database Management System
- `NGINX Web server <https://www.nginx.com/resources/wiki/>`_ - Web Server
- `Redis <https://redis.io/>`_ - In-memory key-value database
-  Workspace container - Development server


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

**Installation**

.. code-block:: bash

  $ git clone git@github.com:boywijnmaalen/kontena.git
  $ cd kontena
  $ cp .env.example .env

  # Configure options in .env
  # Set the DNS server of the current network interface to 127.0.0.1
  # Add any self-signed certificates to the `_certs` directory (optional)

  $ ./_bin/setup.sh && docker-compose up -d --build

**Now go grab a coffee and be patient :)**

Notes:
  - Running ``./_bin/setup.sh`` is non-destructive and can be run as many times as is required

Hostnames
---------

- workspace.dev.local (``172.16.0.3``)
- dns.dev.local (``172.16.0.4``)
- nginx.dev.local (``172.16.0.5``)
- mariadb.dev.local (``172.16.0.6``)
- cockroachdb.dev.local (``172.16.0.7``)
- redis.dev.local (``172.16.0.8``)
- php56-fpm.dev.local (``172.16.0.20``)
- php70-fpm.dev.local (``172.16.0.21``)
- php71-fpm.dev.local (``172.16.0.22``)
- php72-fpm.dev.local (``172.16.0.23``)
- php73-fpm.dev.local (``172.16.0.24``)
- php74-fpm.dev.local (``172.16.0.25``)
- php80-fpm.dev.local (``172.16.0.26``)

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

Workspace
---------

The workspace is a separate container where you can login and use the tools you would on any regular development server setup, it makes sure you don't have to install any tools locally.
Just login into the container via ; ``$ docker-compose exec --user=admin workspace bash`` (make sure you're in the root directory of the Kontena project) and you're all set!
It comes pre-installed with PHP (so you can run it from the CLI), Git, Composer, NodeJS, Yarn, various PHP tools and Bower, Gulp and SASS if you're

Features
~~~~~~~~

* A fully customizable home directory (without rebuilding the container)
* Pre-defined scripts at your disposal (e.g. clean your directories of Mac files, etc)
* Pre-defined aliasses at your disposal (e.g. easy switching between all available PHP versions including phpize, php-config & phar)
* A ``~/.bashrc`` that is filled with;

  * all kinds of additions (e.g. colored bash, custom aliases, etc)
  * GIT & NPM additions (e.g. auto-completion, cli hints, etc)

* Comes installed with;

  * PHP `5.6 <https://github.com/php/php-src/tree/PHP-5.6/>`_, `7.0 <https://github.com/php/php-src/tree/PHP-7.0/>`_, `7.1 <https://github.com/php/php-src/tree/PHP-7.1/>`_, `7.2 <https://github.com/php/php-src/tree/PHP-7.2/>`_, `7.3 <https://github.com/php/php-src/tree/PHP-7.3/>`_, `7.4 <https://github.com/php/php-src/tree/PHP-7.4/>`_ & `8.0 <https://github.com/php/php-src/tree/PHP-8.0/>`_
  * `Git <https://git-scm.com//>`_
  * `Composer <https://getcomposer.org//>`_ (V1 & V2)
  * `NodeJS <https://nodejs.org/>`_ (using NVM - versions 14.15.5 & 15.8.0)
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
  * `GO <https://golang.org/>`_ (1.15.8)


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
* A 100% valid SSL certificate (once imported on host machine) which is valid for the `*.dev.local` domain
* All vhost configuration are located in ``nginx/sites-available/``
* A vhost template can be found in ``nginx/vhost.conf``


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

Connect to Mariadb by using IP ``172.16.0.6`` or ``mariadb.dev.local``


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

TBD

Authors
=======

`Boy Wijnmaalen <https://boywijnmaalen.github.io>`_ (`@boywijnmaalen <https://twitter.com/boywijnmaalen/>`_) created Kontena and `these fine people <https://github.com/boywijnmaalen/kontena/graphs/contributors/>`_ have contributed.
