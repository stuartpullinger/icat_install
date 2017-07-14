#!/usr/bin/env bash

GLASSFISH_USER=glassfish

# Don't update as it seems to destroy the ability to mount the directory share
# - possibly overwrites a kernel module. Is this part of the 'Guest Additions'?
# yum update

# Set up preferred developer environment
yum --quiet --assumeyes install vim screen man
cp /vagrant/vimrc /home/vagrant/.vimrc
cp /vagrant/screenrc /home/vagrant/.screenrc

# Install dependencies
yum --quiet --assumeyes install java-1.8.0-openjdk-headless wget unzip

# Install ICAT Server dependencies
# Ugh! mysql-connector-java depends on full java not headless so this pulls in X11 libs!
# python-requests - undocumented dependency for testicat program
# ruby and rubygems for creating and loading test data
yum --quiet --assumeyes install mysql-server mysql MySQL-python python-suds python-requests mysql-connector-java 

# Install dependencies for ruby installer
# (ruby version in repo is too old for data creation script so we have to install/build from elsewhere)
yum --quiet --assumeyes install patch libyaml-devel glibc-headers autoconf gcc-c++ glibc-devel patch readline-devel zlib-devel libffi-devel openssl-devel automake libtool bison sqlite-devel

# Configure MySQL

# Set the default storage engine to InnoDB
# The code below attempts to do this in python
# Another alternative is to use git-config --file=...
cp /etc/my.cnf /etc/my.cnf.orig
python -c 'from ConfigParser import SafeConfigParser; conf = SafeConfigParser(); conf.read("/etc/my.cnf"); conf.set("mysqld", "default_storage_engine", "InnoDB"); cf = open("/etc/my.cnf", "w"); conf.write(cf); cf.close()'

service mysqld start

# Run the commands from mysql-secure-installation
# Shamelessly ripped from StackOverflow - note the crap password
# http://stackoverflow.com/questions/24270733/automate-mysql-secure-installation-with-echo-command-via-a-shell-script

# Make sure that NOBODY can access the server without a password
mysql -e "UPDATE mysql.user SET Password = PASSWORD('pw') WHERE User = 'root'"
# Kill the anonymous users
mysql -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
mysql -e "DROP USER ''@'$(hostname)'"
# Kill off the demo database
mysql -e "DROP DATABASE test"
# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"
# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd

# Create a database and user for icat
mysqladmin --user=root --password=pw create icat
mysql --user=root --password=pw --execute="CREATE USER 'icat'@'localhost' IDENTIFIED BY 'icat';"
mysql --user=root --password=pw --execute="GRANT ALL PRIVILEGES ON *.* TO 'icat'@'localhost';"

# Configure the database to run on system start up
chkconfig mysqld on

# Create system account for glassfish
useradd $GLASSFISH_USER

# Configure Glassfish to run on system start up
echo '#!/bin/sh

# chkconfig: - 99 01

### BEGIN INIT INFO
# Provides:          glassfish
# Required-Start:    $remote_fs $syslog $local_fs $network
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts a glassfish server
### END INIT INFO

GLASSFISH_HOME=/home/glassfish/glassfish4
DOMAIN=localhost

case "$1" in
start)
    sudo -u glassfish $GLASSFISH_HOME/bin/asadmin start-domain $DOMAIN >/dev/null
    ;;
stop)
    sudo -u glassfish $GLASSFISH_HOME/bin/asadmin stop-domain $DOMAIN >/dev/null
    ;;
restart)
    stop
    start
    ;;
\*)
    echo "usage: $0 (start|stop|restart|help)"
esac' > /etc/init.d/glassfish
chmod 0755 /etc/init.d/glassfish
chkconfig --add glassfish

# Continue setup and install as glassfish user
su --command='cd $HOME; /vagrant/icat_install.sh' $GLASSFISH_USER
