# Changelog

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2019-07-19

### Added

- initial commit, creating the project repository
- added [LICENSE](LICENSE)


## [1.0.1] - 2019-08-06

### Added

- first release of a completed template
- added [README.md


## [1.0.2] - 2019-08-06

### Changed

- small corrections to README.md


## [1.0.3] - 2019-08-06

### Changed

- small corrections to README.md regarding Traefik


## [1.0.4] - 2019-08-07

### Changed

- corrections to README.md


## [1.0.5] - 2019-08-16

### Changed

- added `apache` service as a dependency for the `php-fpm` service.


## [1.0.6] - 2019-09-04

### Changed

- resolved #1 with hard coded value for the exposed `mysql` port


## [1.0.7] - 2019-09-05

### Added

- added suport for explicitely predefined container names (#2)


## [2.0.0] - 2020-02-13

### Added

- integrated support for running Traefik
- added `.gitattributes` to prevent line ending suprises on Windows

### Changed

- the `blitznote/debase` image was replaced by `brezanac/apt-image`
- Traefik upgraded to version 2.0
- changes to the folders and files layout

### Removed

- removed `public` folder from the template

## [2.0.2] - 2020-02-14

### Added

- added a section about Xdebug to README

### Changed

- corrections to README


## [2.1.0] - 2020-02-15

### Added

- added scripts to control bringing up and down the integrated Traefik service

### Changed

- corrections to README to reflect the addition of the Traefik control scripts

## [2.2.0] - 2020-03-14

### Added

- added a new configuration option to .env.example `INSTALL_COMPLETE_TZDATA` as part of fixing #3.

### Changed

- fixed issue #3 where apache and php-fpm containers weren't able to use any other timezone than UTC
- updated README.md and CHANGES.md

## [2.3.0] - 2020-06-02

### Changed

- due to issues with the upstream image the brezanac/apt-image base image was replaced by the official ubuntu:18.04 image
- updated README.md and CHANGES.md 

### Removed
- removed the Blackfire support section in the `php-fpm` service entirely due to it being obsolete

## [2.3.1] - 2020-06-06

### Changed

- disabled XDebug autostart to improve performance for non-debug sessions
- small corrections to README.md

## [2.3.2] - 2020-12-17

### Changed

- small corrections to .env.example

## [2.4.0] - 2020-12-17

### Changed

- upgraded to Xdebug 3.0.1

## [3.0.0] - 2023-02-03

### Added

- added support for `MariaDB`

### Changed

- added support for `PUID` and `PGID` to prevent permission and ownership issues with running containers
- small changes to dynamic configuration for the `apache` container
- updated `.gitignore` to reflect new changes

### Removed

- removed support for `MySQL`

## [3.1.0] - 2023-02-05

### Changed

- removed top level `version` from both docker compose `yml` files

## [3.2.0] - 2023-02-05

### Changed

- switched MariaDB from using bind mount volumes to Docker managed volumes

## [3.3.0] - 2023-03-17

### Added

- added a new service `backup` to support backing up data from services
- added support for backing up database from the `mariadb` service

### Changed

- added healthcheck criteria for the mariadb service to aid the `backup` service

## [3.4.0] - 2023-03-23

### Changed

- moved the location of the backup data folder from `backup/.data` to `.data/backup`

## [3.5.0] - 2023-04-10

### Added

- added support for the `TZ` environmental variable inside all images/containers 

## [3.6.0] - 2023-04-11

### Added

- added support for purging existing backups based on the number of newest retained backups

### Changed

- changed a number of environmental variables for the `backup` process to reflect new functionality

## [3.7.0] - 2023-04-11

### Removed

- removed `INSTALL_COMPLETE_TZDATA` support since `tzdata` is now mandatory for all images

## [3.7.1] - 2023-05-03

### Changed

- fixed the issue with host.docker.internal not being available in the running containers

## [3.7.2] - 2024-01-06

### Changed

- fixed the incompatibility with the old V1 Docker Compose API
