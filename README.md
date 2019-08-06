# docker-amp-template

A simple Docker Compose template to easily set up web projects that are based on the Apache/MySQL/PHP stack.

The template is heavily based on [Dashtainer](https://github.com/jtreminio/dashtainer) with changes that focus on:

- centralized configuration - most of the configuration is done by making changes to just one file (`.env`)
- restructured layout - all Docker related resources are located inside the `.docker` folder, with `docker-compose.yml` being at a more traditional place (project root)
- data loss protection - by storing volume data on the host, services such as MySQL are protected from accidental data loss through volume purging (prune) etc.

## Usage

### Cloning the repository ###
Clone the repository to a place where you want your project to reside. 

**NOTE:** If you are using Windows please take a look at the [troubleshooting section](#troubleshooting) for a potential issue you might have while cloning the repository with Git `core.autocrlf` set to `true`.

```
git clone https://github.com/brezanac/docker-amp-template.git my_awesome_project
```

### Configuring the environmental variables file (.env) ###

Rename `.env.example` to `.env` and adjust it's values accordingly. 

### Configuring the service configuration files ###

Inside `.docker` folder there are separate folders for each service with configuration files specific for that service.

Adjust these to your needs or simply use them as they are:

* `.docker/apache/apache2.conf` - Apache configuration (usually there is no need to change this one)
* `.docker/apache/vhost.conf` - decalare all your virtual hosts here
* `.docker/mysql/my.cnf` - default MySQL server configuration
* `.docker/php-fpm/php-fpm.conf` - PHP-FPM configuration (don't change unless you really know what you are doing)
* `.docker/php-fpm/php.ini` - `php.ini` used for web requests
* `.docker/php-fpm/php-cli.ini` - `php.ini` used for CLI requests
* `.docker/php-fpm/xdebug.ini` - Xdebug configuration used for web requests
* `.docker/php-fpm/xdebug.ini` - Xdebug configuration used for CLI requests

### Creating the reverse proxy network ###

In order to prepare the build process for eventual use of the web reverse proxy (Traefik) you need to manually create a Docker network called `web-reverse-proxy`, which will be used for all communication with the reverse proxy service.

```
docker network create web-reverse-proxy
```

You need to do this **only once**!

### Running docker-compose ###

Run Docker Compose within the newly created folder.

```
cd my_awesome_project
docker-compose up --build
```

If you would like to run the service in the background use the `-d` (detached) argument.

```
docker-compose up -d --build
```

### Reverse proxy (Traefik) support ###

The template provides full support for [Traefik](https://traefik.io/) which acts as a reverse proxy for request to the service containers.

Please take a look at [docker-web-reverse-proxy](https://github.com/brezanac/docker-web-reverse-proxy) for instructions on how to easily combine a reverse web proxy with this template.

## Troubleshooting ##

### Checking out the repository on Windows with Git core.autocrlf option set to true ###

If you are using Windows and your Git configuration is set to automatically replace line endings in cloned repository files with `\r\n` (`core.autocrlf` is set to `true`), some of the files from the template, that are meant to be executed within the container, might fail to do so and the build process will fail.

In that case please use an editor like [VS Code](https://code.visualstudio.com/) to manually open the files, change their line endings from `CRLF` (`\r\n`) to `LF` (`\n`) and save them.

## Requirements

Docker 17.04.0+ or newer.

## Mentions

Special thanks go to [jtreminio](https://github.com/jtreminio) for creating [Dashtainer](https://github.com/jtreminio/dashtainer) and folks at [Freenode](https://freenode.net/) (#docker) which provided valuable insight into some of the trickier aspects of Docker.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
