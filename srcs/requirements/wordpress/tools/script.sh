#!/bin/bash

sed -i 's/^listen = .*/listen = 0.0.0.0:9000/' /etc/php/7.4/fpm/pool.d/www.conf
mkdir -p /run/php && chown -R www-data:www-data /run/php

chown -R www-data:www-data $WP_PATH
chmod -R 755 $WP_PATH
# wget https://wordpress.org/latest.tar.gz && \
#     tar -xvf latest.tar.gz && \
#     mv wordpress/* . && \
#     rmdir wordpress && \
#     rm latest.tar.gz


# rm /var/www/html/wp-config-sample.php
# cp /wp-config.php /var/www/html/wp-config.php

# sed -i -r "s/wordpress_db/$WORDPRESS_DB_NAME/1"   wp-config.php
# sed -i -r "s/dongeun/$WORDPRESS_DB_USER/1"  wp-config.php
# sed -i -r "s/password/$WORDPRESS_DB_PASSWORD/1"    wp-config.php
# sed -i -r "s/mariadb:3306/$WORDPRESS_DB_HOST/1"    wp-config.php
if [ ! -f /usr/local/bin/wp ]; then
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
fi
if [ ! -d "$WP_PATH/wp-admin" ]; then
    wp core download --path=$WP_PATH --allow-root
fi

if [ ! -f "$WP_PATH/wp-config.php" ]; then
wp config create \
	--dbname="$WORDPRESS_DB_NAME" \
	--dbuser="$WORDPRESS_DB_USER" \
	--dbpass="$WORDPRESS_DB_PASSWORD" \
	--dbhost="$WORDPRESS_DB_HOST" \
	--path=$WP_PATH \
	--allow-root
fi

if ! wp core is-installed --path=$WP_PATH --allow-root; then
wp core install --url="$WORDPRESS_URL" \
                --title="$WORDPRESS_TITLE" \
                --admin_user="$ADMIN_USER" \
                --admin_password="$ADMIN_PASSWORD" \
                --admin_email="$ADMIN_EMAIL" \
                --path=$WP_PATH --allow-root
fi

if ! wp user list --field=user_login --path="$WP_PATH" --allow-root | grep -q "^user1$"; then
    wp user create user1 user1@gmail.com --role=subscriber --user_pass="$ADMIN_PASSWORD" --path="$WP_PATH" --allow-root
else
    echo "user1 already exists, skipping creation."
fi

if ! wp plugin list --status=active --field=name --path="$WP_PATH" --allow-root | grep -q "^akismet$"; then
    wp plugin install akismet --activate --path="$WP_PATH" --allow-root
else
    echo "Akismet plugin already installed and active."
fi

if ! wp theme list --status=active --field=name --path="$WP_PATH" --allow-root | grep -q "^twentytwentyfour$"; then
    wp theme install twentytwentyfour --activate --path="$WP_PATH" --allow-root
else
    echo "Twenty Twenty-Four theme already installed and active."
fi

/usr/sbin/php-fpm7.4 -F
