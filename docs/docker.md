# Docker info

The main readme contains the basic steps to start with Docker:

    git clone git@github.com:concord-consortium/rigse.git portal
    cd portal
    docker-compose up # this will take 15 minutes to download gems

After this you can browse to [http://0.0.0.0:3000](http://0.0.0.0:3000). On OS X this
might take more than 5 minutes to load the first page. Look in the terminal where you ran
`docker-compose up` to monitor progress.

## Notes on basic steps

If you have a clean checkout of the portal, `docker-compose up` should just work. If you
have another service running on port 3000 you might get a port conflict.

By default your local portal folder will be mounted inside of the docker app service.
Any changes you make to your local folder will show up immediately in the docker app
service. The files `config/database.yml`, `config/settings.yml` and
`config/app_environment_variables.yml` are automatically copied from their `.sample.yml`
counterparts when you run `docker-compose up` if they do not exist. If they already
exist, they will not be updated. If they already exist then there is a good chance
they will not be configured correctly for Docker. If you are not using
the docker-compose-sync overlay to sync
your local files (see below), you can delete these files and run

    docker-compose build app # make sure you have the latest app image
    docker-compose up app    # recreate the app container from this image

If you are using the docker-compose-sync overlay then you should delete your sync volume first to be safe. You
can't delete a volume that is still attached to containers, so you also need to delete
all of the containers using the sync volume (pretty much everything):

    docker-compose down                   # stop all containers and remove them
    docker volume ls                      # list all of the volumes
    docker volume rm {portal}_sync-volume # remove the unison volume
    docker-compose build app              # make sure you have the latest app image
    docker-compose up                     # start services

Also, when `config/database.yml` is not present yet, `docker-compose up` will copy it
and run `rake db:setup`. This running of `rake db:setup` will erase any data in the
mysql service created by docker-compose, so be careful if you have data in this docker
managed database.

## Docker Compose Overrides

docker-compose supports the concept of
[overrides](https://docs.docker.com/compose/extends/#understanding-multiple-compose-files).
These are partial docker-compose files that are layered ontop of the main
docker-compose.yml. With no configuration docker-compose will look for a
`docker-compose.override.yml` file and combine that with `docker-compose.yml`.  To
change that behavior you can define a `COMPOSE_FILE` environment variable that has a list
of files to layer on top of each other. If this env variable is defined then
docker-compose will not automatically load `docker-compose.override.yml`. docker-compose
will also look for a `.env` file where you can put environment variables like
`COMPOSE_FILE`.

In this repository we've included a docker-compose.override.yml file which provides the
default ports for Rails and Solr. This way a simple `docker-compose up` does the expected
thing.

There are several docker-compose overrides you can use to customize your docker-compose
environment. These can be found in `docker/dev/`. Currently these overrides support:

- `docker-compose-external-mysql.yml`: external mysql server
- `docker-compose-random-ports.yml`: assign random ports to rails and solr
- `docker-compose-sync.yml`: use a 2 volume sync container for faster performance on OS X, without needing the host to run unison
- `docker-compose-unison.yml`: *deprecated* using unison for faster performance on OS X, requires the host to run unison

There is more on each of these below.

To make the initial setup easier there is a .env-osx-sample file that contains the standard setup we use. So you can simply:

```
cp .env-osx-sample .env
docker-compose up
```

## Running Rails and Rake commands

You can run individual commands like this:

    docker-compose run --rm app [command]

The `--rm` tells docker to remove the container after running the command. Otherwise
docker will save the state of the stopped container, which could take up a lot of space
for certain commands.

For example to run the migrations you would do:

    docker-compose run --rm app bundle exec rake db:migrate

However if you are doing active portal development you will probably need to run several
commands. In that case it is more useful to start up a shell and for your commands:

    docker-compose run --rm app bash

## Speeding up OS X

There are a few ways to run Docker on OS X. We mainly use
[Docker for Mac](https://docs.docker.com/docker-for-mac/).
Docker includes support for mounting your host folders inside of containers. This is
useful in development so you can make changes with a native editor and then immediately
these changes are picked up by the container.  When running Docker on a linux host this
mounting system is very fast. However when running on OS X this mounting system is slow.
Docker for Mac has improved the speed some, and hopes to improve it more. The main
barrier is that the Docker team wants the file mounting to be synchronous. This way if
a local change is made the container is guaranteed to see it immediately. This means that
all read operations need to communicate across to OS X to look for changes. This
performance problem really shows up with Rails which is loading and reloading thousands
of files on each request. In the the case of the portal, it can take 5 minutes to load a
page.

There are several options for speeding this up. The fastest approach is to use a 2
volume syncing container that is using unison inside.
The basic idea is that the source code is synced into a named docker volume.
Docker volumes run at near native speeds and can be accessed and watched by multiple
containers. A separate unison container keeps this volume synced with a second volume
that is mounted to the host file system.

Next you should enable the sync override by adding this to your `.env` file:

    COMPOSE_FILE=docker-compose.yml:docker-compose.override.yml:docker/dev/docker-compose-sync.yml

see above for more info about overrides. Note: the line above will continue to use the
standard Rails and Solr ports. If you want to use random ports see that section below
and replace `docker-compose.override.yml` in the line above with
`docker/dev/docker-compose-random-ports.yml`.

Now you can start things up with a simple `docker-compose up`

There can be some file conflicts that come up if both sides modify a file at the same
time. The sync container is configured to choose the host file in this case. Occasionally
the sync container might crash, I haven't seen it yet, but others that are using a
similar setup have reported this.

When the sync container first starts up it mirrors the contents of the host
directory to the named docker volume. Any changes that are only in the named docker
volume will be lost. This is basically the same as how a docker bind mount works, so
it shouldn't cause any problems.

## Setting up a DNS and Proxy to avoid port conflicts

You can easily setup a DNS and Proxy system so you can access all of your docker-compose
services with urls like: http://app.[folder-name].docker (e.g. http://app.portal.docker)

We use [dingh-http-proxy](https://github.com/codekitchen/dinghy-http-proxy). To install
on OS X follow the
[OS X instructions](https://github.com/codekitchen/dinghy-http-proxy#os-x).
You only need to do this one for your whole machine and it will apply to all of your
docker-compose projects. Basically you start a docker container that automatically
restarts. Second you configure the OS X DNS to know about the DNS server of this
container.

Note that if you get an error that port 80 is already in use (`Error starting userland proxy:
Bind for 0.0.0.0:80: unexpected error (Failure EADDRINUSE)`), it may be that OS X's local
Apache server is running, and you will need to stop it using `sudo apachectl stop`.

With this in place you can now use randomly assigned ports for Rails and Solr and
the Dingy Proxy will pick them up automatically. You can switch to randomly assigned
ports by adding this to your `.env` file:

    COMPOSE_FILE=docker-compose.yml:docker/dev/docker-compose-random-ports.yml

Note that it may take several reloads for your browser to ask you whether you really do
intend to go to http://app.portal.docker/, and not search for it. (Adding the trailing / to
the url helps.)

## Connecting to MySQL running in Docker

If you wish to connect to the MySQL database running in Docker, you can publish the
port using the `docker/dev/docker-compose-publish-mysql-port.yml` override file.

Note that if you have a local MySQL server already running on port 3306, or if you
are already publishing a MySQL port from another Docker container (e.g. LARA) you will
want to change the port you are publishing to something else.

## Using Docker with an external MySQL Server

If you wish to use an existing MySQL server you can use the
`docker/dev/docker-compose-external-mysql.yml` override file.

You will need to provide the database environment variables defined in the override.
An easy way to manage that is to the use the .env file
http://docs.master.dockerproject.org/compose/env-file/

If you are connecting to a mysql running on your host, Docker for Mac requires extra
configuration:
https://docs.docker.com/docker-for-mac/networking/#/i-want-to-connect-from-a-container-to-a-service-on-the-host


## Running rspec and cucumber tests with docker

1. Connect to the running docker instance of your "app" service.
    docker-compose exec app bash
2. Then in the container, the first time you need to create the test and feature databases
    RAILS_ENV=test bundle exec rake db:create
    RAILS_ENV=cucumber bundle exec rake db:create
2. Invoke the appropriate `run-<test>.sh` script. This should be one of the following scripts which will be mounted in the `/rigse` directory:
    * `docker/dev/run-spec.sh`
    * `docker/dev/run-cucumber.sh`

## Docker crashing or running very slow

It is possible that not enough memory is available to Docker. Make sure that it is at least 4GiB-5GiB (default: 2GiB).
If you are using OS X, go to `Preferences...` and then `Advanced` tab.  
