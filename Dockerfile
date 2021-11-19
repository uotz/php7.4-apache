FROM php:7.4.26-apache-buster

# Start Composer installation
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
# End Composer installation

# Start Project dependencies installation
RUN apt-get update -qq \
  && apt-get install -qq --no-install-recommends \
  git \
  nano \
  zip \
  unzip \
  libzip-dev \
  && docker-php-ext-install \
  zip \
  && apt-get clean
# End Project dependencies installation

# Start mongodb installation
RUN pecl install mongodb
RUN echo "extension=/usr/local/lib/php/extensions/no-debug-non-zts-20190902/mongodb.so" > /usr/local/etc/php/conf.d/mongo.ini

# Enable mods on web server
RUN a2enmod rewrite proxy headers

# Start creation of non-root user
ARG UID=1000
ARG GID=1000

RUN groupmod -g ${GID} www-data \
  && usermod -u ${UID} -g www-data www-data \
  && mkdir -p /home/app \
  && mkdir -p /var/run/apache2 \
  && chown -hR www-data:www-data \
  /var/log/apache2/ \
  /var/run/apache2 \
  /var/www \
  /usr/local/ \
  /home/app

USER www-data:www-data
# End creation of non-root user

WORKDIR /home/app

EXPOSE 80

CMD service apache2 start