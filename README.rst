Bokisi: a Docker PHP development environment
############################################

Bokisi (pronounced Bo-kie-sie) is a containerized PHP development environment.
Its goal is to create a platform independent environment.
It provides multiple `PHP-FPM <https://php-fpm.org/>`_ (FastCGI Process Manager) versions (`5.6 <https://github.com/php/php-src/tree/PHP-5.6>`_, `7.0 <https://github.com/php/php-src/tree/PHP-7.0>`_ & `7.1 <https://github.com/php/php-src/tree/PHP-7.1>`_),
is based on a `NGINX <https://www.nginx.com/resources/wiki/>`_ web server and is accompanied by a `MariaDB <https://mariadb.org/>`_ relational database management system.

Check out the `Github.io <https://boywijnmaalen.github.io/bokisi/>`_ and follow me on `Twitter <https://twitter.com/boywijnmaalen/>`_.

.. contents::

.. section-numbering::

Main features
=============

* Linux, Mac OS X and Windows support

Installation
============

Docker
------


Project
-------

* ``cp .env.example .env``
* update the values in .env

if you want to run a first time installation;
* ``./_scripts/setup.sh && docker-compose up -d --build``

if you want to do a re-installation from scratch;
* ``docker-compose down --remove-orphans && ./_scripts/reset.sh && docker-compose up -d --build``

Docker
======


Workspace
=========

Features
--------

* Comes pre-installed with
* PHP5.6, PHP7.0, PHP7.1, Git, Composer, NodeJS, Yarn
* A fully customizable home directory
* Pre-defined scripts at your disposal (e.g. clean your directories of Mac files, etc)
* Pre-defined aliasses at your disposal (e.g. easy switching between PHP `5.6`, `7.0` or `7.1`, etc)
* A ~/.bashrc that if fileed with;

        all kinds of additions (e.g. colored bash, custom aliases, etc)
        GIT & NPM additions (e.g. auto-completion, cli hints, etc)

Switch between PHP version
--------------------------

Run ``$ switchphp 5.6`` in order to switch to PHP version 5.6 (possible values; `5.6`, `7.0` or `7.1`)

SSH Keys
--------

You want to add your SSH keys to the workspace container? not a problem!
* Copy your `id_rsa` & `id_rsa.pub` files (or equivalent if your files are named differently) to directory `workspace/home/local_user/.ssh`
* Make sure both files have permissions 600 (by running ``$ chmod workspace/home/local_user/.ssh/id_rsa*`` - change the filename if you renamed your SSH Key), these files may not be read by anyone else

A trade-off has been made between security and convenience if you protected your SSH Key with a secure passphrase.
There is a little snippet included in ``~/.bashrc`` which automatically asks for your password upon first login to the Workspace container and saves it as long as the container is running.
If you stop/start or reboot the Workspace container, your secure passphrase will be required once more upon first login on the Workspace container.
(This snippet will also work if you decide to forward the host' ssh-agent to the Workspace container)
