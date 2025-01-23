#!/bin/bash

sed -i 's/^listen = .*/listen = 0.0.0.0:9000/' /etc/php/7.4/fpm/pool.d/www.conf

mkdir -p /run/php && chown -R www-data:www-data /run/php

wget https://wordpress.org/latest.tar.gz && \
    tar -xvf latest.tar.gz && \
    mv wordpress/* . && \
    rmdir wordpress && \
    chown -R www-data:www-data /var/www/html && \
    rm latest.tar.gz

rm /var/www/html/wp-config-sample.php
sed -i -r "s/database_name/$WORDPRESS_DB_NAME/1"   wp-config.php
sed -i -r "s/username/$WORDPRESS_DB_USER/1"  wp-config.php
sed -i -r "s/password/$WORDPRESS_DB_PASSWORD/1"    wp-config.php
sed -i -r "s/localhost/$WORDPRESS_DB_HOST/1"    wp-config.php

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

wp core install --url="$WORDPRESS_URL" \
                --title="$WORDPRESS_TITIE" \
                --admin_user="$ADMIN_USER" \
                --admin_password="$ADMIN_PASSWORD" \
                --admin_email="$ADMIN_EMAIL" \
                --path=/var/www/html --allow-root

wp plugin install akismet --activate --path=/var/www/html --allow-root
wp theme install twentytwentyfour --activate --path=/var/www/html --allow-root

/usr/sbin/php-fpm7.4 -F
