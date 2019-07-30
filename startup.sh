#!/usr/bin/env bash
set -e

role=${CONTAINER_ROLE:-app}
env=${APP_ENV:-production}

if [ "$role" = "app" ]; then
    /usr/local/sbin/php-fpm -y /usr/local/etc/php-fpm.conf
elif [ "$role" = "horizon" ]; then
    /usr/local/bin/php /var/www/artisan horizon
elif [ "$role" = "operational" ]; then
    /usr/local/bin/php /var/www/artisan operational:collector
else
    exit 1
fi

