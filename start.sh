#!/usr/bin/env bash
set -e

role=${CONTAINER_ROLE:-app}
env=${APP_ENV:-production}

if [ "$role" = "fpm" ]; then
    php-fpm
else
    echo "Could not match the container role \"$role\""
    exit 1
fi
