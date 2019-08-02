FROM php:7.2-fpm-alpine

LABEL maintainer="Rezza Kurniawan <rezza@matamerah.com>"

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

COPY docker-php-ext-get /usr/local/bin/

RUN echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
    && echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories \
    && apk add --update \
        libmcrypt-dev \ 
        shadow \
        nodejs \
        npm \
        tesseract-ocr \
        imagemagick \
        wget \
        bash \
        fcgi \
        chromium@edge=~73.0.3683.103 \
        nss@edge \
        freetype@edge \
        freetype-dev@edge \
        harfbuzz@edge \
        ttf-freefont@edge \
    && docker-php-source extract \
    && docker-php-ext-get mcrypt 1.0.1 \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-get redis 5.0.2\
    && docker-php-ext-install redis \
    && docker-php-source delete \
    && docker-php-ext-install \
    pdo \
    pdo_mysql \
    pcntl \
    sockets \
    opcache \
    tokenizer \
    bcmath \
    ctype \
    json \
    mbstring \
    && rm -rf /var/cache/apk/* \
    && set -xe && echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
    && wget -O /usr/local/bin/php-fpm-healthcheck \ 
    https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
    && chmod +x /usr/local/bin/php-fpm-healthcheck \
    && usermod -u 1000 www-data \
    && groupmod -g 1000 www-data

WORKDIR /var/www

COPY startup.sh /usr/local/startup.sh

CMD ["/usr/local/startup.sh"]