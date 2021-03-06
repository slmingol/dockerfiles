#!/bin/bash
if [ ! -f /var/www/html/moodle/config.php ]; then
  #mysql has to be started this way as it doesn't work to call from /etc/init.d
  /usr/bin/mysqld_safe & 
  sleep 10s
  # Here we generate random passwords (thank you pwgen!). The first two are for mysql users, the last batch for random keys in wp-config.php
  MOODLE_DB="moodle"
  MYSQL_PASSWORD=`pwgen -c -n -1 12`
  MOODLE_PASSWORD=`pwgen -c -n -1 12`
  #This is so the passwords show up in logs. 
  echo mysql root password: $MYSQL_PASSWORD
  echo moodle password: $MOODLE_PASSWORD
  echo $MYSQL_PASSWORD > /mysql-root-pw.txt
  echo $MOODLE_PASSWORD > /moodle-db-pw.txt

  cp -ax /var/www/html/moodle/config-dist.php /var/www/html/moodle/config.php
  sed -i "s*pgsql*mysqli*g" /var/www/html/moodle/config.php
  sed -i "s*username*moodle*g" /var/www/html/moodle/config.php
  sed -i "s*password*$MOODLE_PASSWORD*g" /var/www/html/moodle/config.php
  sed -i "s*example.com*$VIRTUAL_HOST*g" /var/www/html/moodle/config.php
  sed -i "s*\/home\/example\/moodledata*\/var\/moodledata*g" /var/www/html/moodle/config.php
  chown www-data:www-data /var/www/html/moodle/config.php

  rm -rf /var/moodledata/*                                                                                                                                                   
  chown -R www-data:www-data /var/moodledata

  mysqladmin -u root password $MYSQL_PASSWORD
  mysql -uroot -p$MYSQL_PASSWORD -e "SET GLOBAL binlog_format = 'MIXED';" 
  mysql -uroot -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
  mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE moodle; GRANT ALL PRIVILEGES ON moodle.* TO 'moodle'@'localhost' IDENTIFIED BY '$MOODLE_PASSWORD'; FLUSH PRIVILEGES;"
  killall mysqld

fi
# start all the services
/usr/local/bin/supervisord -n
