# d4m-nfs

Docker for Mac with NFS for performance improvements over osxfs

## Why?

With the Docker for Mac's (D4M) current implementation of osxfs, depending on how read and write heavy containers are on mounted volumes, performance can be abismal.

d4m-nfs blantently steals from the way that DockerRoot/xhyve used NFS mounts to get around i/o performance issues. With this implementation D4M appears to even outperform DockerRoot/xhyve under a full Drupal stack (mariadb/redis/php-fpm/nginx/varnish/haproxy), including persistent MySQL databases.

The advantage of this over a file sync strategy is simpler, less overhead and not having to duplicate files.

## Install

### #1.

Clone the repo.

```bash
$ git clone git@github.com:IFSight/d4m-nfs.git ~/d4m-nfs
```

### #2. 

Create file etc/d4m-nfs-mounts.txt and the following;

```bash
$ echo "/Users/$USER:/mnt/mac_user
/Volumes:/Volumes
/private:/private
/opt:/opt" > ~/d4m-nfs/etc/d4m-nfs-mounts.txt
```

### #3. 

Execute the script (you’ll be asked for your local Mac-username password).
If Docker is not already running the script will attempt to start Docker, if that fails start it manually.

```bash
$ ~/d4m-nfs/d4m-nfs.sh
```

### #4. 
Check if anything went ok by going into the VM, you should see the previously defined mounts at the bottom.

```bash
$ screen -r d4m
```

exit `screen` with ctrl-a d

### #5. 

Go to your docker folder

```bash
$ cd <your Docker folder>
```


### #6. 

Rewrite all volume paths

- replace /**Users/\<your-mac-username\>**/www -> /**mnt/mac_user**/www


### #7.

Start your container(s) by providing the newly created docker-compose-nfs.yml.

```bash
$ docker-compose -f docker-compose-nfs.yml up -d
```

### #8. [**Optional**]

If your containers were already build we need to rebuild them by adding the --build flag.

```bash
$ docker-compose -f docker-compose-nfs.yml up -d --build
```

## Rebooted Mac/restarted Docker?

Execute steps **#3**, **#4** and **#8** once more.

## Facts

- VM (Vagrant) stops when you exit Docker app

## Remove?

Requires sudo

Do not forget to shutdown Docker first! :)

```bash
$ rm /private/tmp/d4m-mount-nfs.sh /private/tmp/d4m-nfs-mounts.txt && rm -rf /private/tmp/d4m-apk-cache && sudo rm /etc/exports && sudo rm -rf /opt/d4m-nfs
```

## Interesting reads

- [Inside Docker’s Moby](https://stephank.nl/p/2017-01-01-inside-dockers-moby.html)
