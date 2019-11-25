![Atlassian Crowd](https://wac-cdn.atlassian.com/dam/jcr:fd5bfb32-1640-4806-add6-760d7c33b57c/Crowd@2x-blue.png?cdnVersion=532)

Crowd provices single sign-on and user identity that's easy to use.

Learn more about Crowd: [https://www.atlassian.com/software/crowd](https://www.atlassian.com/software/crowd)

# Overview

This Docker container makes it easy to get an instance of Crowd up and running.

# Quick Start

For the `CROWD_HOME` directory that is used to store application data (amongst other things) we recommend mounting a host directory as a [data volume](https://docs.docker.com/engine/tutorials/dockervolumes/#/data-volumes), or via a named volume if using a docker version >= 1.9.

To get started you can use a data volume, or named volumes. In this example we'll use named volumes.

    docker volume create --name crowdVolume
    docker run -v crowdVolume:/var/atlassian/application-data/crowd --name="crowd" -d -p 8095:8095 prepend2/crowd


**Success**. Crowd is now available on [http://localhost:8095](http://localhost:8095)*

Please ensure your container has the necessary resources allocated to it. See [Supported Platforms](https://confluence.atlassian.com/crowd/supported-platforms-191851.html) for further information.


_* Note: If you are using `docker-machine` on Mac OS X, please use `open http://$(docker-machine ip default):8095` instead._

## Memory / Heap Size

If you need to override Crowd's default memory allocation, you can control the minimum heap (Xms) and maximum heap (Xmx) via the below environment variables.

* `JVM_MINIMUM_MEMORY` (default: 384m)

   The minimum heap size of the JVM

* `JVM_MAXIMUM_MEMORY` (default: 768m)

   The maximum heap size of the JVM

## Reverse Proxy Settings

If Crowd is run behind a reverse proxy server as [described here](https://confluence.atlassian.com/crowd031/integrating-crowd-with-apache-949753124.html), then you need to specify extra options to make Crowd aware of the setup. They can be controlled via the below environment variables.

* `CATALINA_CONNECTOR_PROXYNAME` (default: NONE)

   The reverse proxy's fully qualified hostname.

* `CATALINA_CONNECTOR_PROXYPORT` (default: NONE)

   The reverse proxy's port number via which Crowd is accessed.

* `CATALINA_CONNECTOR_SCHEME` (default: http)

   The protocol via which Crowd is accessed.

* `CATALINA_CONNECTOR_SECURE` (default: false)

   Set 'true' if CATALINA_CONNECTOR_SCHEME is 'https'.

## JVM Configuration

If you need to pass additional JVM arguments to Crowd, such as specifying a custom trust store, you can add them via the below environment variable

* `JVM_SUPPORT_RECOMMENDED_ARGS`

   Additional JVM arguments for Crowd

Example:

    docker run -e JVM_SUPPORT_RECOMMENDED_ARGS=-Djavax.net.ssl.trustStore=/var/atlassian/application-data/crowd/cacerts -v crowdVolume:/var/atlassian/application-data/crowd --name="crowd" -d -p 8095:8095 prepend2/crowd

## Container Configuration

* `SET_PERMISSIONS` (default: true)

   Define whether to set home directory permissions on startup. Set to `false` to disable
   this behaviour.

# Upgrade

To upgrade to a more recent version of Crowd you can simply stop the `crowd` container and start a new one based on a more recent image:

    docker stop crowd
    docker rm crowd
    docker run ... (See above)

As your data is stored in the data volume directory on the host it will still  be available after the upgrade.

_Note: Please make sure that you **don't** accidentally remove the `crowd` container and its volumes using the `-v` option._

# Backup

For evaluations you can use the built-in database that will store its files in the Crowd home directory. In that case it is sufficient to create a backup archive of the docker volume.

If you're using an external database, you can configure Crowd to make a backup automatically each night. This will back up the current state, including the database to the `crowdVolume` docker volume, which can then be archived. Alternatively you can backup the database separately, and continue to create a backup archive of the docker volume to back up the Crowd Home directory.

Read more about data recovery and backups: [https://confluence.atlassian.com/crowd/backing-up-and-restoring-data-36470797.html](https://confluence.atlassian.com/crowd/backing-up-and-restoring-data-36470797.html)

# Versioning

The `latest` tag matches the most recent release of Atlassian Crowd. Thus `prepend2/crowd:latest` will use the newest version of Crowd available.

Alternatively you can use a specific major, major.minor, or major.minor.patch version of Crowd by using a version number tag:

* `prepend2/crowd:3`
* `prepend2/crowd:3.7`
* `prepend2/crowd:3.7.0`


# Troubleshooting

These images include built-in scripts to assist in performing common JVM diagnostic tasks.

## Thread dumps

`/opt/atlassian/support/thread-dumps.sh` can be run via `docker exec` to easily trigger the collection of thread
dumps from the containerized application. For example:

    docker exec my_jira /opt/atlassian/support/thread-dumps.sh

By default this script will collect 10 thread dumps at 5 second intervals. This can
be overridden by passing a custom value for the count and interval, by using `-c` / `--count`
and `-i` / `--interval` respectively. For example, to collect 20 thread dumps at 3 second intervals:

    docker exec my_container /opt/atlassian/support/thread-dumps.sh --count 20 --interval 3

Thread dumps will be written to `$APP_HOME/thread_dumps/<date>`.

Note: By default this script will also capture output from top run in 'Thread-mode'. This can
be disabled by passing `-n` / `--no-top`

## Heap dump

`/opt/atlassian/support/heap-dump.sh` can be run via `docker exec` to easily trigger the collection of a heap
dump from the containerized application. For example:

    docker exec my_container /opt/atlassian/support/heap-dump.sh

A heap dump will be written to `$APP_HOME/heap.bin`. If a file already exists at this
location, use `-f` / `--force` to overwrite the existing heap dump file.

## Manual diagnostics

The `jcmd` utility is also included in these images and can be used by starting a `bash` shell
in the running container:

    docker exec -it my_container /bin/bash

# Support

This Docker container is unsupported and is intended for illustration purposes only.
