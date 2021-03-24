#!/bin/bash

# Script for creating database inside MySQL

MYSQL_DIR="/usr/local/mysql"

if [ -z $1 ]; then
  echo $1
fi

${MYSQL_DIR}/bin/mysqld_safe --user=mysql &
${MYSQL_DIR}/bin/mysqladmin --silent --wait=30 ping || exit 1
${MYSQL_DIR}/bin/mysql -e 'ALTER USER "root"@"localhost" IDENTIFIED BY "password";'
${MYSQL_DIR}/bin/mysqladmin shutdown -u root -ppassword --wait=30 ping || exit 1
