#!/bin/bash

# mysql config                                                                                                                                                                                
sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
sed -ri 's|# * InnoDB|ignore_builtin_innodb\nplugin-load=ha_innodb.so\n# * InnoDB|g' /etc/mysql/my.cnf
sed -i -e 's|\[mysqld\]|\[mysqld\ ]\n binlog_format=MIXED \n|g' /etc/mysql/my.cnf

apt-get update
apt-get install -y expect

mysqld_safe &
sleep 5s

MYSQL_SECURE=$(expect -c "

set timeout 10
spawn mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"\r\"

expect \"Change the root password?\"
send \"n\r\"

expect \"Remove anonymous users?\"
send \"y\r\"

expect \"Disallow root login remotely?\"
send \"y\r\"

expect \"Remove test database and access to it?\"
send \"y\r\"

expect \"Reload privilege tables now?\"
send \"y\r\"

expect eof
")


apt-get remove -y expect
apt-get autoremove -y

killall mysqld
sleep 10s

