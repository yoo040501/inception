#!/bin/bash

mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld
sed -i 's/^bind-address.*/# bind-address  = 127.0.0.1/' /etc/mysql/mariadb.conf.d/50-server.cnf

mkdir -p /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
chmod 755 /var/lib/mysql

# MariaDB 데이터 디렉토리가 비어 있을 때만 초기화 실행
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    mysqld --user=mysql --skip-networking &
    MYSQLD_PID=$!

    for i in {30..0}; do
        if echo 'SELECT 1' | mysql --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot &> /dev/null; then
            break
        fi
        sleep 1
    done

    if [ "$i" = 0 ]; then
        echo "MariaDB did not start in time" >&2
        exit 1
    fi

    mysql --protocol=socket -uroot <<-EOF
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOF

    kill -s TERM "$MYSQLD_PID"
    wait "$MYSQLD_PID"
else
    echo "Database already initialized, skipping initialization."
fi

exec mysqld --user=mysql
