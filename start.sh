#!/usr/bin/env bash
set -e

role=${CONTAINER_ROLE:-app}
env=${APP_ENV:-production}
scheduleSleep=${SCHEDULE_SLEEP:-60}

if [ "$role" = "fpm" ]; then
    echo "Running the fpm..."
    php-fpm
elif [ "$role" = "horizon" ]; then
    echo "Running the horizon..."
    php /var/www/app/artisan horizon
elif [ "$role" = "scheduler" ]; then
    while [ true ]
    do
      php /var/www/app/artisan schedule:run --verbose --no-interaction
      sleep $scheduleSleep
    done
else
    echo "Could not match the container role \"$role\""
    exit 1
fi
