FROM phusion/baseimage:latest

LABEL maintainer="Rezza Kurniawan <rezza@matamerah.com>"

RUN DEBIAN_FRONTEND=noninteractive
RUN locale-gen en_US.UTF-8

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm

# Add the "PHP 7" ppa
RUN apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ondrej/php

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --allow-downgrades --allow-remove-essential \
        --allow-change-held-packages \
        php7.2-fpm \
        php7.2-sockets \
        php7.2-cli \
        php7.2-common \
        php7.2-curl \
        php7.2-intl \
        php7.2-json \
        php7.2-xml \
        php7.2-mbstring \
        php7.2-opcache \
        php7.2-mysql \
        php7.2-zip \
        php7.2-bcmath \
        php7.2-memcached \
        php7.2-gd \
        php7.2-dev \
        pkg-config \
        libcurl4-openssl-dev \
        libedit-dev \
        libssl-dev \
        libxml2-dev \
        xz-utils \
        git \
        curl \
        vim \
        supervisor \
        tesseract-ocr \
        wget \
  && apt-get clean

RUN wget https://github.com/tesseract-ocr/tessdata/raw/master/eng.traineddata -P /usr/share/tessdata

COPY ./config/app.ini /usr/local/etc/php/conf.d
COPY ./config/app.pool.conf /usr/local/etc/php-fpm.d/
COPY ./config/horizon.conf /etc/supervisord.conf

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN set -xe; \
    pecl channel-update pecl.php.net && \
    groupadd -g ${PGID} moota && \
    useradd -u ${PUID} -g moota -m moota -G docker_env && \
    usermod -p "*" moota -s /bin/bash

#####################################
# Composer:
#####################################

# Install composer and add its bin to the PATH.
RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer

RUN mkdir -p /home/moota/.composer/ &&  printf '{ \n "require": {} \n}' >> /home/moota/.composer/composer.json 

RUN chown -R moota:moota /home/moota/.composer

RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc

# Source the bash
RUN . ~/.bashrc

#####################################
# Set Timezone:
#####################################

ARG TZ="Asia/Jakarta"
ENV TZ ${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#####################################
# User Aliases
#####################################

USER moota

RUN echo "" >> ~/.bashrc && \
	  echo "" >> ~/.bashrc

#####################################
# Install Redis
#####################################
USER root

RUN apt-get install -yqq php-redis

###########################################################################
# Imagemagick & PHP ImageMagick
###########################################################################

USER root

RUN apt-get install -y imagemagick php-imagick

###########################################################################
# Node / NVM:
###########################################################################
USER moota

ARG NODE_VERSION=node
ENV NODE_VERSION ${NODE_VERSION}
ENV NVM_DIR /home/moota/.nvm

RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash \
      && . $NVM_DIR/nvm.sh \
      && nvm install ${NODE_VERSION} \
      && nvm use ${NODE_VERSION} \
      && nvm alias ${NODE_VERSION} \
      && ln -s `npm bin --global` /home/moota/.node-bin

USER root

RUN echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="/home/moota/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc

ENV PATH $PATH:/home/moota/.node-bin

# RUN echo "" >> ~/.bashrc && \
#     echo "export PATH='/home/moota/.node-bin:$PATH'" && \
#     echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
#     echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc


###########################################################################
# Chrome / Puppeters
###########################################################################

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

RUN npm i puppeteer

USER root

RUN apt-get -y install \ 
    gconf-service \
    libasound2 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    ca-certificates \
    fonts-liberation \
    libappindicator1 \
    libnss3 \
    lsb-release \
    xdg-utils

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

# Set default work directory
WORKDIR /var/www