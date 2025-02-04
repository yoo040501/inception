#!/bin/bash

sed -i 's/^listen = .*/listen = 0.0.0.0:9000/' /etc/php/7.4/fpm/pool.d/www.conf
mkdir -p /run/php && chown -R www-data:www-data /run/php

if [ ! -f "$WP_PATH/wp-config.php" ]; then
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
    wp core download --path=$WP_PATH --allow-root

	wp config create \
		--dbname="$WORDPRESS_DB_NAME" \
		--dbuser="$WORDPRESS_DB_USER" \
		--dbpass="$WORDPRESS_DB_PASSWORD" \
		--dbhost="$WORDPRESS_DB_HOST" \
		--path=$WP_PATH \
		--allow-root
	wp core install --url="$WORDPRESS_URL" \
					--title="$WORDPRESS_TITLE" \
					--admin_user="$ADMIN_USER" \
					--admin_password="$ADMIN_PASSWORD" \
					--admin_email="$ADMIN_EMAIL" \
					--path=$WP_PATH --allow-root

	wp user create user1 user1@gmail.com --role=subscriber --user_pass="$ADMIN_PASSWORD" --path="$WP_PATH" --allow-root
	wp plugin install akismet --activate --path="$WP_PATH" --allow-root
	wp theme install twentytwentyfour --activate --path="$WP_PATH" --allow-root
fi

/usr/sbin/php-fpm7.4 -F
