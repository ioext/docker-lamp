FROM ubuntu:18.04
MAINTAINER Fer Uria <fauria@gmail.com>
LABEL Description="Cutting-edge LAMP stack, based on Ubuntu 16.04 LTS. Includes .htaccess support and popular PHP7 features, including composer and mail() function." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST WWW PORT NUMBER]:80 -p [HOST DB PORT NUMBER]:3306 -v [HOST WWW DOCUMENT ROOT]:/var/www/html -v [HOST DB DOCUMENT ROOT]:/var/lib/mysql fauria/lamp" \
	Version="1.0"
ARG SOURCE=GLOBAL
COPY source.china.list /tmp/
RUN if [ "$SOURCE" = "CHINA" ] ; then sh -c "cp /tmp/source.china.list /etc/apt/sources.list" ; fi
RUN apt-get update
RUN apt-get upgrade -y
RUN apt install -y apt-utils curl locales cron  gnupg2
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install nodejs iputils-ping -y

RUN locale-gen en_US.UTF-8

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm
# todo ENV APACHE_USER


COPY debconf.selections /tmp/
RUN debconf-set-selections /tmp/debconf.selections

RUN apt-get install -y zip unzip
RUN apt-get install -y \
	php7.2 \
	php7.2-bz2 \
	php7.2-cgi \
	php7.2-cli \
	php7.2-common \
	php7.2-curl \
	php7.2-dev \
	php7.2-enchant \
	php7.2-fpm \
	php7.2-gd \
	php7.2-gmp \
	php7.2-imap \
	php7.2-interbase \
	php7.2-intl \
	php7.2-json \
	php7.2-ldap \
	php7.2-mbstring \
	php7.2-mysql \
	php7.2-odbc \
	php7.2-opcache \
	php7.2-pgsql \
	php7.2-phpdbg \
	php7.2-pspell \
	php7.2-readline \
	php7.2-recode \
	php7.2-snmp \
	php7.2-sqlite3 \
	php7.2-sybase \
	php7.2-tidy \
	php7.2-xmlrpc \
	php7.2-xsl \
	php7.2-zip
RUN apt-get install apache2 libapache2-mod-php7.2 -y
RUN apt-get install mariadb-common mariadb-server mariadb-client -y
RUN apt-get install postfix -y
RUN apt-get install git composer nano tree vim curl ftp supervisor -y
RUN npm install -g bower grunt-cli gulp

ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV TERM dumb

COPY run-lamp.sh /usr/sbin/
COPY change-root.sh /tmp/

ADD crontab /etc/cron.d/laravel-cron
RUN chmod 0644 /etc/cron.d/laravel-cron
RUN crontab /etc/cron.d/laravel-cron
RUN touch /var/log/cron.log

ADD crontab /etc/cron.d/laravel-cron
ADD supvervisord-queue-work.conf /etc/supervisor/conf.d/supvervisord-queue-work.conf

RUN a2enmod rewrite
RUN a2enmod headers
#RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN chmod +x /usr/sbin/run-lamp.sh
RUN chmod +x /tmp/change-root.sh

VOLUME /var/www/html
VOLUME /var/log/httpd
VOLUME /var/lib/mysql
VOLUME /var/log/mysql
RUN /tmp/change-root.sh
VOLUME /etc/apache2

RUN chown -R www-data:www-data /var/www/html
#RUN chmod -R 777 /var/www/html/storage
#RUN chmod -R 777 /var/www/html/boostrap/cache


EXPOSE 80
EXPOSE 3306

RUN cron

CMD ["/usr/sbin/run-lamp.sh"]
