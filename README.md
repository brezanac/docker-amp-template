# docker-amp-template

A simple Docker template to easily set up web projects that rely on the Apache/MySQL/PHP stack, with a fully integrated [Traefik](https://traefik.io/) reverse proxy.

## Major changes in version 2.0

### New base image

Due to the removal of the original `blitznote/debase` image from Docker Hub, [brezanac/apt-image](https://hub.docker.com/repository/docker/brezanac/apt-image) is now used as a stand-in replacement.

The `brezanac/apt-image` image is based entirely on the original source code of `blitznote/debase` and is generated automatically by Docker Hub from a forked [repository](https://github.com/brezanac/apt-image) on GitHub.

### Integrated Traefik 2.0

[Traefik 2.0](https://containo.us/traefik/) is now fully integrated into the template and can be run manually, if required.

For more details please see the instructions [here](#integrating-traefik-reverse-proxy).

### New folder structure

In order to integrate the template more easily into existing projects the folder structure has been modified, allowing it to be used from a completely independent location or as part of a git submodule.

### Removed public folder

The document root (`./public`) is no longer part of the template and is by default considered to be located one level above the template folder (`../public`).

## Usage

### The TLDR version please

The shortened version or all the steps required to use this template (explained line by line):

* (optional) create the main project folder (skip if one already exists)
* step into the main project folder
* (optional) initialize an empty git repository (skip if the project is already versioned by git)
* add the template repo as a git submodule (current folder **needs** to be a git repository too!)
* initialize the template submodule
* update the template submodule with required dependencies
*  (optional) create a public folder (skip if one already exists)
* step into the submodule folder
* (optional) run the integrated Traefik 2.0 reverse proxy (skip if you already have another Traefik instance running)
* run the actual template services

```
mkdir my-awesome-project
cd my-awesome-project
git init
git submodule add https://github.com/brezanac/docker-amp-template.git .docker
git submodule init
git submodule update
mkdir public
cd .docker
docker-compose -f docker-compose.traefik.yml -p traefik_reverse_proxy up --build -d
docker-compose up --build
```

### Still too long. TLDR TLDR version please

If you are not comfortable with using git submodules or just don't need the added complexity that comes with using them you can just clone the git repository and delete the `.git` folder inside it.

```
git clone https://github.com/brezanac/docker-amp-template.git .docker
```

However, do note that by doing this you will lose the ability to quickly update the project through git pulls so you will need to do it manually every time.

### Cloning the repository

Clone the repository to a location of your choosing.

```
git clone https://github.com/brezanac/docker-amp-template.git .docker
```

You can also add the repository as a git submodule to an already existing project that uses git, but be aware of the complications that might arise from using submodules.

```
git submodule add https://github.com/brezanac/docker-amp-template.git .docker
```

**NOTE:** if you use the git submodule method you will **need to initialize your submodules** after cloning the repository that has this template as a git submodule.

You can initialize the submodules automatically during the cloning process (replace `REPOSITORY_LOCATION` with the actual URL or local path to the repository).

```
git clone REPOSITORY_LOCATION my-awesome-project --recurse-submodules
```

Alternatively you can also initialize the submodules manually.

```
git clone REPOSITORY_LOCATION my-awesome-project
git submodule init
git submodule update
```

### Configuring the environmental variables file

Copy `.env.example` to `.env` and adjust it's values accordingly.

### Configuring the service configuration files

The service folders (`apache`, `php-fpm`, `mysql`) contain files required to build and configure the service images.

Please adjust these to your needs or simply use them as they are:

* `apache/apache2.conf` - default apache configuration (usually there is no need to change any of this)
* `apache/vhost.conf` - a place to decalare all your virtual hosts
* `mysql/my.cnf` - MySQL server configuration
* `php-fpm/php-fpm.conf` - php-fpm configuration (don't change unless you really know what you are doing)
* `php-fpm/php.ini` - `php.ini` used for web requests
* `php-fpm/php-cli.ini` - `php.ini` used for CLI requests
* `php-fpm/xdebug.ini` - Xdebug configuration for web requests
* `php-fpm/xdebug.ini` - Xdebug configuration for CLI requests

**DO NOT** make changes to files not listed above unless you really know what you are doing.

### Integrating Traefik reverse proxy

[Traefik](https://containo.us/traefik/) is a reverse proxy used to automatically route all HTTP and TCP connections to appropriate Docker containers. 

It also removes the need for *port juggling*, which means that instead of making requests like `localhost:8080` Traefik will allow you to use something like `docker-amp-template.localhost` which will be routed to the appropriate Docker container.

Two scripts are provided with this template to automate the process of bringing Traefik up and down, while also being able to specify the name of the Docker project explicitely:

* `traefik` - Bash script for use on Linux
* `traefik.bat` - Batch script for use on Windows

Starting and stopping Traefik with the default project name of `traefik_reverse_proxy` on Linux.

```
./traefik up
./traefik down
```

Starting and stopping Traefik with an explicitely set project name on Linux.

```
./traefik up unimatrix_zero_one
./traefik down unimatrix_zero_one
```

Windows equivalents for the above commands is as follows.
```
traefik.bat up
traefik.bat down
traefik.bat up unimatrix_zero_one
traefik.bat down unimatrix_zero_one
```

**NOTE:** if you use a custom project name while bringing Traefik up, you also **MUST** use it while bringing it down!

Alternatively you can run Traefik manually by simply using the following line from within the cloned folder (assumed `.docker`).

```
cd .docker
docker-compose -f docker-compose.traefik.yml -p traefik_reverse_proxy up --build -d
```

This will build and run a new instance of Traefik in the background named `traefik_reverse_proxy`.

**NOTE:** you need to run the command **only once** and **only** if you don't already have another Traefik instance that you will be using. 

You can use the same instance of Traefik for **all your projects** if you want to.

To stop Traefik use one of the following two methods (the first one is preferred since it will also prune the generated container and network).

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
    - "traefik.enable=false"
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

After cloning the repository move into the cloned folder (assumed `.docker`) and run `docker-compose` like in the following example.

```
cd .docker
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

For example, if you would like to access the `mysql` container from within your PHP code (`php-fpm`) you need to use the name of the running `mysql` container as host name. Since Docker prefixes all service names with the `COMPOSE_PROJECT_NAME` value the actual host name of the `mysql` container with the default `COMPOSE_PROJECT_VALUE` would be `docker-amp-template_mysql`.

In order to simplify usage this template explicitely sets names for all running containers. This however comes at a cost of not being able to scale the running containers, simply because there is no way to run two containers with the same name at the same time.

If you wish to remove this limitation and don't mind the dynamically named containers just remove all `container_name` lines from `docker-compose.yml` and the `COMPOSE_PROJECT_NAME` line from `.env`.

### Availability of time zones

In order to reduce it's size the base Docker image used for the `apache` and `php-fpm` services (`brezanac/apt-image`) contains very limited support for time zones, with `UTC` being used as default.

For some use cases this might be enough. However, if you rely on having a full collection of up to date time zone definitions you can configure the build process to remove the slimmed down version of `tzdata` and install the complete one. 

For that you just need to set `INSTALL_COMPLETE_TZDATA` to `true` in your `.env` file or any other value other than `true` to keep the original slimmed down version.

## Requirements

The template itself requires Docker `17.04.0` (`Compose 3.2`) or newer. 

However, in order to run the integrated Traefik you will need Docker `17.14.0` (`Compose version 3.5`) or higher.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
