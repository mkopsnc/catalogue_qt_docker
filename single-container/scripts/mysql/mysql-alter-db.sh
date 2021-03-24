#!/bin/bash

# Script for altering database

MYSQL_DIR="/usr/local/mysql"

if [ -z $1 ]; then
  echo $1
fi

${MYSQL_DIR}/bin/mysqld_safe --user=mysql &
${MYSQL_DIR}/bin/mysqladmin -uroot -ppassword --silent --wait=30 ping || exit 1

#  
# We prepare structure of DB, by running base script, and its alter scripts 'a_'  
for a_sql_file in /home/imas/opt/catalog_qt_2/sql/schema/a_*; do
  ${MYSQL_DIR}/bin/mysql -uroot -ppassword < $a_sql_file
done
   
#  
#After creating structure od DB we have to import data, and load alter scripts for modyfing data in DB 'd_'  
${MYSQL_DIR}/bin/mysql -uroot -ppassword itm_catalog_qt < /tmp/variables

for d_sql_file in /home/imas/opt/catalog_qt_2/sql/schema/d_*; do
  ${MYSQL_DIR}/bin/mysql -uroot -ppassword itm_catalog_qt < $d_sql_file
done

#
# end of modyfing DB.
${MYSQL_DIR}/bin/mysqladmin shutdown -u root -ppassword --wait=30 ping || exit 1