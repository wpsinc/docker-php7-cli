# wpsinc/docker-php7-cli

FROM php:7.4-alpine

RUN apk add --no-cache \
    git \
    postgresql-dev \
    sqlite-dev \
    libzip-dev

RUN docker-php-ext-configure zip --with-libzip

RUN docker-php-ext-install \
    bcmath \
    mbstring \
    pdo_mysql \
    pdo_sqlite \
    pcntl \
    pgsql \
    pdo_pgsql \
    zip \
    mysqli

# Install GD library.
RUN apk add --no-cache \
    freetype \
    freetype-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    libpng \
    libpng-dev \
    && docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    && NPROC=$(getconf _NPROCESSORS_ONLN) \
    && docker-php-ext-install -j${NPROC} gd \
    && apk del --no-cache freetype-dev libjpeg-turbo-dev libpng-dev

# Install `ImageMagick` (Linux app) and `imagick` PHP extension.
RUN set -ex \
    && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS imagemagick-dev libtool \
    && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && pecl install imagick-3.4.3 \
    && docker-php-ext-enable imagick \
    && apk add --no-cache --virtual .imagick-runtime-deps imagemagick \
    && apk del .phpize-deps

# Install Xdebug extension.
RUN apk add --no-cache \
    autoconf \
    gcc \
    g++ \
    make \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install dumb-init.
RUN apk add --no-cache \
    dumb-init --repository http://dl-cdn.alpinelinux.org/alpine/v3.5/community/

# Install Composer.
RUN echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini"
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

ENV GIT_COMMITTER_NAME php-cli
ENV GIT_COMMITTER_EMAIL php-cli@localhost

# Runs "/usr/bin/dumb-init -- /my/script --with --args"
ENTRYPOINT ["/usr/bin/dumb-init", "--", "docker-php-entrypoint"]

CMD ["php", "-a"]
