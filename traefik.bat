@echo off
REM A simple script to bring the integrated Traefik service up and down.

REM Default project name for the Traefik service.
REM Prevents Docker from nagging about orphan containers.
set default_project_name="traefik_reverse_proxy"

if "%1" EQU "" goto help

if "%1" NEQ "up" (
    if "%1" NEQ "down" (
        goto help
    )
)

if "%1" EQU "up" goto up
if "%1" EQU "down" goto down

:up
if "%2" NEQ "" (
    docker-compose -f docker-compose.traefik.yml -p "%2" up --build -d
) else (
    docker-compose -f docker-compose.traefik.yml -p %default_project_name% up --build -d
)
goto eof

:down
if "%2" NEQ "" (
    docker-compose -f docker-compose.traefik.yml -p "%2" down
) else  (
    docker-compose -f docker-compose.traefik.yml -p %default_project_name% down
)
goto eof

:help
echo.
echo "USAGE: traefik.bat up|down [project_name]"
echo.

:eof