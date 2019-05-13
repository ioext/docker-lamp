FROM ubuntu:18.04
MAINTAINER Ayaka209 <ayaworking@gmail.com>
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
RUN apt-get install mariadb-common mariadb-server python3-pip mariadb-client -y
RUN apt-get install postfix -y
RUN apt-get install git composer nano tree vim curl ftp supervisor -y
RUN npm install -g bower grunt-cli gulp

COPY swoole_loader72.so /usr/lib/php/

ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV TERM dumb

RUN mkdir /var/www/ssl

COPY run-lamp.sh /usr/sbin/
COPY change-root.sh /tmp/
COPY ssl.conf /etc/apache2/sites-available/default-ssl.conf
COPY ssl_keys/server.crt /var/www/ssl/server.crt
COPY ssl_keys/server.key /var/www/ssl/server.key


# copy swoole_compiler
COPY swoole_loader72.so /tmp/
RUN cp /tmp/swoole_loader72.so $(php -r 'echo ini_get("extension_dir");')
RUN echo "extension=swoole_loader72.so" > /etc/php/7.2/mods-available/swoole_loader72.ini
RUN phpenmod swoole_loader72

ADD crontab /etc/cron.d/laravel-cron
RUN chmod 0644 /etc/cron.d/laravel-cron
RUN crontab /etc/cron.d/laravel-cron
RUN touch /var/log/cron.log

RUN mkdir /var/log/supervisord
ADD crontab /etc/cron.d/laravel-cron
ADD supervisord-queue-work.conf /etc/supervisor/conf.d/supervisord-queue-work.conf

RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod ssl
RUN a2ensite default-ssl
#RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN chmod +x /usr/sbin/run-lamp.sh
RUN chmod +x /tmp/change-root.sh

VOLUME /var/www/html
VOLUME /var/log/httpd
VOLUME /var/lib/mysql
VOLUME /var/log/mysql
VOLUME /var/www/ssl
RUN /tmp/change-root.sh
RUN echo swoole_license_files=/var/www/html/license_file >> /etc/php/7.2/apache2/php.ini
RUN echo swoole_license_files=/var/www/html/license_file >> /etc/php/7.2/cli/php.ini
VOLUME /etc/apache2

RUN chown -R www-data:www-data /var/www/html
#RUN chmod -R 777 /var/www/html/storage
#RUN chmod -R 777 /var/www/html/boostrap/cache

COPY docker-php-ext-* /usr/local/bin/


EXPOSE 80
EXPOSE 3306
EXPOSE 443

RUN cron

CMD ["/usr/sbin/run-lamp.sh"]
