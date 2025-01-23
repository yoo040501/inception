FROM debian:bullseye

RUN apt-get update && \
	apt-get upgrade && \
    apt-get -y install \
		php7.4 \
		php-fpm \
		php-cli \
		wget \
		curl \
		php-mysql \
		php-mbstring \
		php-xml \
		sendmail \
		vim && \
    apt-get clean

WORKDIR /var/www/html

EXPOSE 9000

COPY ./requirements/wordpress/tools/script.sh /
COPY ./requirements/wordpress/tools/wp-config.php /var/www/html/wp-config.php

RUN chmod +x /script.sh

CMD [ "/script.sh" ]