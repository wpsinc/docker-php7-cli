# wpsinc/docker-php7-cli

FROM php:7.0-cli

RUN apt-get update

RUN docker-php-ext-install \
    bcmath \
    mbstring \
    pdo_mysql

# Install GD library.
RUN apt-get install -y \
    libpng12-dev \
    libjpeg-dev \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd

# Install `ImageMagick` (Linux app) and `imagick` PHP extension.
RUN apt-get install -y \
    imagemagick \
    libmagickwand-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# Install dumb-init
RUN apt-get install wget -y
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb
RUN dpkg -i dumb-init_*.deb

# Cleanup
RUN apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Runs "/usr/bin/dumb-init -- /my/script --with --args"
ENTRYPOINT ["/usr/bin/dumb-init", "--", "docker-php-entrypoint"]

CMD ["php", "-a"]
