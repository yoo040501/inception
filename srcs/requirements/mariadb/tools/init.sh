#!/bin/bash

mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld
sed -i 's/^bind-address.*/# bind-address  = 127.0.0.1/' /etc/mysql/mariadb.conf.d/50-server.cnf

mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

mysqld --user=mysql --skip-networking &
MYSQLD_PID=$!

# Wait for MariaDB to start
for i in {30..0}; do
	if echo 'SELECT 1' | mysql --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot &> /dev/null; then
		break
	fi
	sleep 1
done

if [ "$i" = 0 ]; then
	exit 1
fi

mysql --protocol=socket -uroot <<-EOF
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
EOF

# Shut down the temporary MariaDB server
if ps -p "$MYSQLD_PID" > /dev/null; then
    kill -s TERM "$MYSQLD_PID"
    wait "$MYSQLD_PID"
else
    echo "MariaDB process not running."
fi

# Start MariaDB server (foreground mode)
exec mysqld --user=mysql
