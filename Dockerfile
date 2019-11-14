FROM debian:10

# INIT https://docs.docker.com/engine/reference/commandline/build/
# docker build --tag debian_8_laravel .
# docker run -it debian_8_laravel /bin/bash
# docker run -it -u root  debian_8_laravel /bin/bash
# docker exec -it debian_8_laravel bash

# docker build -t debian --target debian-8-laravel .
# docker run -it debian
# docker run --name debian_bash --rm -i -t debian bash
#docker exec -it
#docker exec -it debian bash
#docker exec -it d9900d0c0ae7 bash
#docker rm $(docker ps -q -f 'status=exited')
#docker rmi $(docker images -q -f "dangling=true")
# docker rmi -f IMAGE ID
# docker rmi -f 4a755ab5a0de
LABEL maintainer=1074746@gmail.com vendor=Binotel
MAINTAINER Vadim <1074746@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

ONBUILD ARG _UID
ONBUILD ARG _GID

ONBUILD RUN groupmod -g $_GID www-data \
 && usermod -u $_UID -g $_GID -s /bin/bash www-data \
 && echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

WORKDIR /root

RUN mkdir -p /var/www/ \
 && mkdir -p /var/run/php/ \
 && mkdir -p /var/log/php/ \
 && mkdir -p /var/run/mysqld/ \
 && mkfifo /var/run/mysqld/mysqld.sock

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    apt-utils dialog sudo automake bash-completion ca-certificates gnupg2 bzip2 net-tools ssh-client \
    dirmngr gcc g++ make rsync chrpath curl wget git vim nano unzip htop cron mc libaio1 \
    software-properties-common libmcrypt-dev \
 # PHP 7.3 Extensions
 && apt-get install -y -q lsb-release apt-transport-https \
 && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
 && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php7.3.list \
 && apt-get update && apt-get install -y \
    php7.3-common \
    php7.3-mysql \
    php7.3-xml \
    php7.3-xmlrpc \
    php7.3-curl \
    php7.3-gd \
    php7.3-imagick \
    php7.3-cli \
    php7.3-dev \
    php7.3-imap \
    php7.3-mbstring \
    php7.3-opcache \
    php7.3-soap \
    php7.3-zip \
    php7.3-intl \
 # Composer
 && cd /root \
 && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
 && php -r "unlink('composer-setup.php');" \
 # NodeJs LTS Release
 && curl -sL https://deb.nodesource.com/setup_10.x | sudo bash \
 && apt-get install nodejs \
 && apt-key adv --recv-keys --keyserver ha.pool.sks-keyservers.net 5072E1F5 \
 # Clean
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Setup working directory
WORKDIR /var/www
