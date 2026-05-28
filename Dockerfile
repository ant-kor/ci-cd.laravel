FROM php:8.3.0-fpm

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV COMPOSER_MEMORY_LIMIT=-1
ENV DEBIAN_FRONTEND noninteractive
ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH

ENV MYSQL_ROOT_PASSWORD root
ENV MYSQL_DATABASE test

# Install production dependencies
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    bash \
    wget \
    curl \
    jq \
    g++ \
    gcc \
    ssh \
    openssh-client \
    libicu-dev \
    git \
    imagemagick \
    libxml2-dev \
    libpng-dev \
    libc-dev \
    mc \
    nano \
    unzip \
    rsync \
    libzip-dev \
    libmagickwand-dev \
    libldap2-dev \
    python3-pip \
    libfreetype6-dev \
    libfreetype6 \
	ca-certificates gnupg \
	default-mysql-server \
    && rm -rf /var/lib/apt/lists/*


# Install PECL and PEAR extensions
RUN pecl install imagick \
    && pecl install -o -f redis \
    && docker-php-ext-enable imagick \
    && docker-php-ext-enable redis \
    && rm -rf /tmp/pear

RUN docker-php-ext-install \
    pdo_mysql \
    pcntl \
    xml \
    gd \
    zip \
    bcmath \
    exif \
    gd \
    ldap \
    soap \
    intl

RUN docker-php-ext-configure gd \
    && docker-php-ext-configure zip \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap_r.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap_r.a /usr/lib/libldap_r.a \
    && docker-php-ext-configure ldap

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer 
# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

RUN npm install -g retire

RUN python3 -m pip install semgrep --break-system-packages

RUN composer global require "squizlabs/php_codesniffer=*" \
    && curl -LO https://deployer.org/releases/v7.5.12/deployer.phar  \
    && mv deployer.phar /usr/local/bin/dep \
    && chmod +x /usr/local/bin/dep
    
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && php -m

RUN service mariadb start && \
    mariadb -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('${MYSQL_ROOT_PASSWORD}'); FLUSH PRIVILEGES;" && \
    mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"

CMD ["mysqld"]
# Setup working directory
WORKDIR /var/www
