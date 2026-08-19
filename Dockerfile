FROM alpine:3.24

LABEL description="Simple forum software for building great communities" \
      maintainer="Jetsung Chan <i@jetsung.com>"

ARG VERSION=v1.8.0

ENV GID=991 \
    UID=991 \
    UPLOAD_MAX_SIZE=50M \
    PHP_MEMORY_LIMIT=128M \
    OPCACHE_MEMORY_LIMIT=128 \
    DB_HOST=mariadb \
    DB_USER=flarum \
    DB_NAME=flarum \
    DB_PORT=3306 \
    FLARUM_TITLE=Docker-Flarum \
    DEBUG=false \
    LOG_TO_STDOUT=false \
    GITHUB_AUTH_ENABLED=false \
    FLARUM_PORT=80

# apk search php8 | awk -F'-' '{print $1}' | uniq | grep php | tail -n 1

RUN <<EOF
apk update && \
apk add --no-progress --no-cache \
    curl \
    git \
    icu-data-full \
    libcap \
    nginx \
    php85 \
    php85-ctype \
    php85-curl \
    php85-dom \
    php85-exif \
    php85-fileinfo \
    php85-fpm \
    php85-gd \
    php85-gmp \
    php85-iconv \
    php85-intl \
    php85-mbstring \
    php85-mysqlnd \
    php85-pecl-apcu \
    php85-openssl \
    php85-pdo \
    php85-pdo_mysql \
    php85-phar \
    php85-session \
    php85-tokenizer \
    php85-xmlwriter \
    php85-zip \
    php85-zlib \
    su-exec \
    s6

cd /tmp
ln -s /usr/bin/php85 /usr/bin/php
curl --progress-bar http://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
sed -i "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" /etc/php85/php.ini
chmod +x /usr/local/bin/composer
mkdir -p /run/php /flarum/app

case "$VERSION" in
  v2*)
    COMPOSER_CACHE_DIR="/tmp" composer create-project "flarum/flarum:^$VERSION" --stability=beta /flarum/app
    ;;
  *)
    COMPOSER_CACHE_DIR="/tmp" composer create-project "flarum/flarum:^$VERSION" /flarum/app
    ;;
esac


composer clear-cache
rm -rf /flarum/.composer /tmp/*
setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/nginx
ln -s /usr/sbin/php-fpm85 /usr/sbin/php-fpm8
ln -s /usr/bin/s6-svscan /bin/s6-svscan
EOF

COPY rootfs /
RUN chmod +x /usr/local/bin/* /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*
VOLUME /etc/nginx/flarum /flarum/app/extensions /flarum/app/public/assets /flarum/app/storage/logs
EXPOSE 80
CMD ["/usr/local/bin/startup"]
