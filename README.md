# docker-amp-template

A simple Docker template to easily set up web projects that rely on the Apache/MySQL/PHP stack, with a fully integrated and optional [Traefik](https://traefik.io/) reverse proxy.

## Major changes in version 2.3

### New base image

Due to constant issues with the upstream Docker image the brezanac/apt-image was replaced by the [official Ubuntu 18.04 image](https://hub.docker.com/_/ubuntu).

As a result containers running the `apache` and `php-fpm` services will require more resources, however future updates of the template will not depend upon external projects which might end up being abandoned or in need of constant maintenance.

### Integrated Traefik 2.0

[Traefik 2.0](https://containo.us/traefik/) is now fully integrated into the template and can be optionally run, if required.

For more details please see the instructions [here](#integrating-traefik-reverse-proxy).

### New folder structure

In order to integrate the template more easily into existing projects the folder structure has been modified, allowing the template to be cloned and used from a completely independent location or as part of a git submodule.

### Removed public folder

**NOTE**: The document root (`./public`) is no longer part of the template itself and is by default considered to be located one level above the template folder (`../public`). If your public folder is located somewhere else please adjust the value in `.docker/apache/vhost.conf`.   

## Usage

### Preparation steps

Clone the repository inside an existing project folder or create a new one.

```
mkdir my-awesome-project
cd my-awesome-project
git https://github.com/brezanac/docker-amp-template.git .docker
```

Make sure to create a `public` folder, if you don't already have one, before continuing.

```
mkdir public
```

If you don't have Traefik already running make sure to run it first (this is an optional step).

**NOTE**: You need to do this only once per machine since Traefik will self-restart on each machine restart until it's manually stopped.

```
cd .docker
./traefik up
```

In case you are on a Windows machine use the `traefik.bat` file instead.

```
traefik.bat up
```

For more details on Traefik integration please take a look [here](#integrating-traefik-reverse-proxy). 

### Configuring the environmental variables

Copy `.env.example` to `.env` and adjust it's values accordingly.

### Configuring the service configuration files

The service folders (`apache`, `php-fpm`, `mysql`) contain files required to build and configure the service images.

If required, please adjust these to your needs:

* `apache/apache2.conf` - default apache configuration (usually there is no need to modify any of this)
* `apache/vhost.conf` - a place to declare all your virtual hosts
* `mysql/my.cnf` - MySQL server configuration
* `php-fpm/php-fpm.conf` - php-fpm configuration (don't modify unless you really know what you are doing)
* `php-fpm/php.ini` - `php.ini` used for web requests
* `php-fpm/php-cli.ini` - `php.ini` used for CLI requests
* `php-fpm/xdebug.ini` - Xdebug configuration for web requests
* `php-fpm/xdebug.ini` - Xdebug configuration for CLI requests

**DO NOT** make changes to files that are not listed above unless you really know what you are doing.

### Integrating Traefik reverse proxy

[Traefik](https://containo.us/traefik/) is a reverse proxy used to automatically route HTTPS requests to appropriate Docker containers (services). 

It's main benefit is that it removes the need for constant *port juggling*, which means that instead of making requests such as `localhost:8080` Traefik will accept requests like `docker-amp-template.localhost` instead.

This template provides two scripts to automate the process of running and shutting down Traefik.

* `traefik` - Bash script for use on Linux
* `traefik.bat` - Batch script for use on Windows

To start or stop Traefik with the default project name of `traefik_reverse_proxy` on Linux simply use `./traefik up` or `./traefik down`, respectively.

To do the same on a Windows machine just type `./traefik.bat up` or `./traefik.bat down`.

Please do note that you also have the option to specify the Docker project name under which Traefik will run.

```
./traefik up unimatrix_zero_one
```

**NOTE:** if you use a custom project name while bringing Traefik up, you also **MUST** use the same name while bringing it down!

```
./traefik down unimatrix_zero_one
```

Alternatively you can run Traefik directly through `docker-compose` by simply using the following line from within the cloned folder (assumed `.docker`).

```
docker-compose -f docker-compose.traefik.yml -p traefik_reverse_proxy up --build -d
```

This will build and run a new instance of Traefik in the background named `traefik_reverse_proxy`.

**NOTE:** Once again, you need to run this command **only once** and **only** if you don't already have another Traefik instance running that you will be using. 

Basically, you can use the same instance of Traefik for **all your projects** if you want to.

To stop Traefik directly with `docker-compose`, use one of the following two methods (the first one is preferred since it will also prune the generated container and network).

```
docker-compose -f docker-compose.traefik.yml -p traefik_reverse_proxy down
```

```
docker container stop traefik_reverse_proxy
```

If, for whatever reason, you do not want to use Traefik at all please make the following adjustments to `docker-compose.yml`:

* set `traefik.enable` value to `false` inside the `labels` section for the `apache` service

```
labels:
    - "traefik.enable=true"
    - "traefik.docker.network=${TRAEFIK_NETWORK_NAME}"
    - "traefik.http.routers.${COMPOSE_PROJECT_NAME}.entrypoints=web"
    - "traefik.http.routers.${COMPOSE_PROJECT_NAME}.rule=Host(`${COMPOSE_PROJECT_NAME}.${TRAEFIK_HOSTNAME}`)"
```

* add a `ports` section to the `apache` service (you can choose the value of the local port but make sure it's not already in use)

```
ports:
    - "8080:8080"
```

### Running the actual template

After cloning the repository make sure once again that you are inside the cloned repository (assumed `.docker` here) and run `docker-compose` like in the following example.

```
docker-compose up --build
```

If you would like to run the service in the background use the `-d` (detached) argument.

```
docker-compose up -d --build
```

### Check if everything is working as expected

Use `COMPOSE_PROJECT_NAME.localhost` (replace `COMPOSER_PROJECT_NAME` with the value from `.env`) in your browser to see if everything is working as expected.

In case of the default value for `COMPOSE_PROJECT_NAME` the URL is `docker-amp-template.localhost`.

## Debugging PHP code

The template provides built-in support for PHP debugging through [Xdebug](https://xdebug.org/).

In order to trigger a debugging session the request needs to contain a cookie named `XDEBUG_SESSION`.

For more details please consult the [official Xdebug documentation](https://xdebug.org/docs/remote).

## Troubleshooting

### Communication between containers

In order for Docker containers to be able to communicate with each other when they are part of a custom Docker network, all requests need to use container names as target host names ([details](https://docs.docker.com/v17.09/engine/userguide/networking/configure-dns/)).

For example, if you would like to access the `mysql` container from within your PHP code (`php-fpm`) you need to use the name of the running `mysql` container as host name. Since Docker prefixes all service container names with the `COMPOSE_PROJECT_NAME` value the actual host name of the `mysql` container with the default `COMPOSE_PROJECT_VALUE` would be `docker-amp-template_mysql`.

In order to simplify usage this template explicitly sets names for all running containers. This however comes at a cost of not being able to scale the running containers, simply because there is no way to run two containers with the same name at the same time.

If you wish to remove this limitation and don't mind the dynamically named containers just remove all `container_name` lines from `docker-compose.yml` and the `COMPOSE_PROJECT_NAME` line from `.env`.

### Availability of time zones

The default Ubuntu Docker image does not come with `tzdata` installed which means that it technically does not provide support for timezones.  

If your service depends on timezone support (i.e. your PHP code uses `DataTime` functions etc.) make sure to set the value of `INSTALL_COMPLETE_TZDATA` to `true`.

## Requirements

The template itself requires Docker `17.04.0` (`Compose 3.2`) or newer. 

However, in order to run the integrated Traefik you will need Docker `17.14.0` (`Compose version 3.5`) or higher.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
