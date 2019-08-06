# docker-amp-template

A simple Docker Compose template to easily set up web projects that rely on the Apache/MySQL/PHP stack.

The template is heavily based on [Dashtainer](https://github.com/jtreminio/dashtainer) with changes that focus on:

- centralized configuration - most of the configuration is done by making changes to just one file (`.env`)
- restructured layout - all Docker related resources are located inside the `.docker` folder, with `docker-compose.yml` being at a more traditional place (project root)
- data loss protection - by storing volume data on the host, services such as MySQL are protected from accidental data loss through volume pruning etc.

To avoid port management, this template also uses [Traefik](https://traefik.io/) as a reverse proxy by default. However a reverse proxy is not required and with some changes to this template it can be used completely independently.

## Usage

### Cloning the repository ###
Clone the repository to a place where you want your project to be. 

**NOTE:** If you are using Windows please take a look at the [troubleshooting section](#troubleshooting) for a potential issue you might encounter while cloning the repository with Git `core.autocrlf` set to `true`.

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

### Integrating the Traefik reverse proxy ###

By default Traefik is used as a reverse proxy to route all HTTP/HTTPS requests to appropriate services and avoid port juggling on the host machine.

What this means is that the usual requests like `host:port` (example: `localhost:8080`) can simply be replaced with requests like `project_name.localhost` (example: `docker-amp-template.localhost`).

If you do want to use the reverse proxy please consult [docker-web-reverse-proxy](https://github.com/brezanac/docker-web-reverse-proxy) for instructions on how to set it up first before proceeding.

If you do not want to use the reverse proxy and would rather like to use the standard `host:port` format for requests please perform the following changes to `docker-compose.yml`:

- remove the entire `labels` section from the `apache` service

```
labels:
    - traefik.backend=${COMPOSE_PROJECT_NAME}_apache
    - traefik.docker.network=web-reverse-proxy_public
    - traefik.frontend.rule=Host:${COMPOSE_PROJECT_NAME}.localhost
```

- add a `ports` section to the `apache` service (you can choose the value of the local port but make sure it's not already used)

```
ports:
    - "8080:8080"
```

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

### Check if everything is working as expected ###

Use `COMPOSE_PROJECT_NAME.localhost` (replace `COMPOSER_PROJECT_NAME` with the value from `.env`) in your browser to see if everything is working as expected.

In case of the default value for `COMPOSE_PROJECT_NAME` the URL is `docker-amp-template.localhost`.

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
