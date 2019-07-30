FROM php:7.2-fpm-alpine

LABEL maintainer="Rezza Kurniawan <rezza@matamerah.com>"

RUN docker-php-ext-install pdo \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install sockets \
    && docker-php-ext-install opcache \
    && docker-php-ext-install tokenizer \
    && docker-php-ext-install bcmath

RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

RUN apk add --no-cache libpng-dev \
    && docker-php-ext-install gd

RUN apk add --no-cache libmcrypt-dev \
    && yes | pecl install -o -f mcrypt-1.0.1 \
    && docker-php-ext-enable mcrypt

RUN apk add nodejs npm tesseract-ocr imagemagick wget

RUN apk add --no-cache bash

RUN apk add --no-cache fcgi

RUN set -xe && echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zz-docker.conf

RUN wget -O /usr/local/bin/php-fpm-healthcheck \
    https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
    && chmod +x /usr/local/bin/php-fpm-healthcheck

RUN echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
    echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
    apk add --no-cache \
    chromium@edge=~73.0.3683.103 \
    nss@edge \
    freetype@edge \
    freetype-dev@edge \
    harfbuzz@edge \
    ttf-freefont@edge

RUN npm install puppeteer@1.12.2

RUN wget -P /usr/share/tessdata https://github.com/tesseract-ocr/tessdata/raw/master/eng.traineddata

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apk --no-cache add shadow && \
    usermod -u 1000 www-data && \
    groupmod -g 1000 www-data

WORKDIR /var/www

RUN chown -R www-data:www-data /var/www

COPY startup.sh /usr/local/startup.sh

CMD ["/usr/local/startup.sh"]