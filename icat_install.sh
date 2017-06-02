#!/usr/bin/env bash

ICAT_INSTALL_DIR=$HOME/icat_install
cd $HOME

#
# Set up Glassfish
#

# Download glassfish
wget --no-verbose --no-clobber --directory-prefix=/vagrant http://download.java.net/glassfish/4.0/release/glassfish-4.0.zip

# unzip glassfish
unzip -o -q /vagrant/glassfish-4.0.zip

# add glassfish directory to path - reprovisioning will run this again, adding the same string to the end of the PATH. Probably not good. :(
echo 'export PATH=$PATH:$HOME/glassfish4/bin' >> $HOME/.bashrc
source $HOME/.bashrc

# download glassfish setup script
wget --no-verbose --no-clobber --directory-prefix=/vagrant https://icatproject.org/misc/scripts/setup-glassfish.py

# run glassfish setup script
python /vagrant/setup-glassfish.py localhost 75% pw

#
# Copy the MySQL Connector jar file
#
cp /usr/share/java/mysql-connector-java-5.1.17.jar $HOME/glassfish4/glassfish/domains/localhost/lib/ext/

#
# Install ICAT components
#
mkdir -p $ICAT_INSTALL_DIR
cd $ICAT_INSTALL_DIR

#
# Set up anonymous authentication
#

# download ICAT anonymous authentication package
wget --no-verbose --no-clobber --directory-prefix=/vagrant http://www.icatproject.org/mvn/repo/org/icatproject/authn.anon/1.1.1/authn.anon-1.1.1-distro.zip

# unzip anonymous authentication package
unzip -o -q /vagrant/authn.anon-1.1.1-distro.zip

# configure the properties files
echo "#Glassfish
secure = false
container = Glassfish
home = $HOME/glassfish4
port = 4848" > $ICAT_INSTALL_DIR/authn.anon/authn_anon-setup.properties

echo "#Glassfish
ip = 127.0.0.1
mechanism = anon" > $ICAT_INSTALL_DIR/authn.anon/authn_anon.properties

# install anonymous authentication package
cd $ICAT_INSTALL_DIR/authn.anon
./setup configure
./setup install
cd $ICAT_INSTALL_DIR

#
# Set up and install Simple Authentication
#

# download ICAT simple authentication plugin
wget --no-verbose --no-clobber --directory-prefix=/vagrant http://www.icatproject.org/mvn/repo/org/icatproject/authn.simple/1.1.0/authn.simple-1.1.0-distro.zip

# unzip
unzip -o -q /vagrant/authn.simple-1.1.0-distro.zip

# configure the setup properties files
echo "#Glassfish
secure = false
container = Glassfish
home = $HOME/glassfish4
port = 4848" > $ICAT_INSTALL_DIR/authn.simple/authn_simple-setup.properties

# configure the users in the properties file
echo "#User list
user.list = root ingest stuart

user.root.password = pw
user.ingest.password = ingest
user.stuart.password = stuart

mechanism = simple" > $ICAT_INSTALL_DIR/authn.simple/authn_simple.properties

cd $ICAT_INSTALL_DIR/authn.simple
./setup configure
./setup install
cd $ICAT_INSTALL_DIR

#
# Set up ICAT Server
#

wget --no-verbose --no-clobber --directory-prefix=/vagrant https://repo.icatproject.org/repo/org/icatproject/icat.server/4.8.0/icat.server-4.8.0-distro.zip

# unzip ICAT server package
unzip -o -q /vagrant/icat.server-4.8.0-distro.zip

# configure the icat-setup.properties file
echo "#Glassfish
secure = false
container = Glassfish
home = $HOME/glassfish4
port = 4848

# MySQL
db.driver      = com.mysql.jdbc.jdbc2.optional.MysqlDataSource
db.url         = jdbc:mysql://localhost:3306/icat
db.username    = icat
db.password    = icat" > $ICAT_INSTALL_DIR/icat.server/icat-setup.properties

# create directory for lucene data
mkdir -p $HOME/icat/data/lucene

# configure the icat.properties file
echo "# Real comments in this file are marked with '#' whereas commented out lines
# are marked with '!'

# The lifetime of a session
lifetimeMinutes = 120

# Provide CRUD access to authz tables
rootUserNames = simple/root

# Restrict total number of entities to return in a search call
maxEntities = 10000

# Maximum ids in a list - this must not exceed 1000 for Oracle
maxIdsInQuery = 500

# Size of cache to be used when importing data into ICAT
importCacheSize = 50

# Size of cache to be used when exporting data from ICAT
exportCacheSize = 50

# Desired authentication plugin mnemonics
!authn.list = db ldap simple anon
authn.list = simple anon

# Parameters for each of the four plugins
!authn.db.jndi       = java:global/authn.db-1.2.0/DB_Authenticator

!authn.ldap.jndi     = java:global/authn.ldap-1.2.0/LDAP_Authenticator
!authn.ldap.admin    = true
!authn.ldap.friendly = Federal Id

authn.simple.jndi = java:global/authn.simple-1.1.0/SIMPLE_Authenticator
authn.simple.friendly = Simple

authn.anon.jndi     = java:global/authn.anon-1.1.1/ANON_Authenticator
authn.anon.friendly = Anonymous

# Uncomment to permit configuration of logback
logback.xml = icat.logback.xml

# Notification setup
notification.list = Dataset Datafile
notification.Dataset = CU
notification.Datafile = CU

# Call logging setup
log.list = SESSION WRITE READ INFO

# Lucene
lucene.directory = $HOME/icat/data/icat/lucene
lucene.commitSeconds = 5
lucene.commitCount = 10000

# JMS - uncomment and edit if needed
!jms.topicConnectionFactory = java:comp/DefaultJMSConnectionFactory

# Optional key which must match that of the IDS server if the IDS is in use and has a key for digest protection of Datafile.location
!key = ???" > $ICAT_INSTALL_DIR/icat.server/icat.properties

# configure the icat.logback.xml file

# create the ~/bin dir
mkdir -p $HOME/bin

# Install ICAT Server
cd $ICAT_INSTALL_DIR/icat.server
./setup configure
./setup install

cd $ICAT_INSTALL_DIR

#
# Install ICAT Data Service (IDS)
#

# install File storage plugin first
wget --no-verbose --no-clobber --directory-prefix=/vagrant http://www.icatproject.org/mvn/repo/org/icatproject/ids.storage_file/1.3.3/ids.storage_file-1.3.3-distro.zip

unzip -o -q /vagrant/ids.storage_file-1.3.3-distro.zip

# make directories to store data
ICAT_DATA_DIR=$HOME/icat/data
ICAT_ARCHIVE_DIR=$HOME/icat/archive
mkdir -p $ICAT_DATA_DIR
mkdir -p $ICAT_ARCHIVE_DIR
mkdir -p $ICAT_DATA_DIR/ids/cache
echo "dir=$ICAT_DATA_DIR" > $ICAT_INSTALL_DIR/ids.storage_file/ids.storage_file.main.properties
echo "dir=$ICAT_ARCHIVE_DIR" > $ICAT_INSTALL_DIR/ids.storage_file/ids.storage_file.archive.properties

echo "#Glassfish
secure = false
container = Glassfish
home = $HOME/glassfish4
port = 4848" > $ICAT_INSTALL_DIR/ids.storage_file/ids.storage_file-setup.properties

cd $ICAT_INSTALL_DIR/ids.storage_file
./setup configure
./setup install
cd $ICAT_INSTALL_DIR

# install the IDS
wget --no-verbose --no-clobber --directory-prefix=/vagrant https://repo.icatproject.org/repo/org/icatproject/ids.server/1.7.0/ids.server-1.7.0-distro.zip

unzip -o -q /vagrant/ids.server-1.7.0-distro.zip

echo "#Glassfish
secure = false
container = Glassfish
home = $HOME/glassfish4
port = 4848

# Any libraries needed (space separated list of jars in domain's lib/applibs
libraries=ids.storage_file*.jar" > $ICAT_INSTALL_DIR/ids.server/ids-setup.properties

echo "# General properties
icat.url = http://localhost:8181

plugin.zipMapper.class = org.icatproject.ids.storage.ZipMapper

plugin.main.class = org.icatproject.ids.storage.MainFileStorage
plugin.main.properties = ids.storage_file.main.properties

cache.dir = /home/glassfish/icat/data/ids/cache
preparedCount = 10000
processQueueIntervalSeconds = 5
rootUserNames = simple/root
sizeCheckIntervalSeconds = 60
reader = simple username root password pw
!readOnly = true
maxIdsInQuery = 1000

# Properties for archive storage
plugin.archive.class = org.icatproject.ids.storage.ArchiveFileStorage
plugin.archive.properties = ids.storage_file.archive.properties
writeDelaySeconds = 60
startArchivingLevel1024bytes = 5000000
stopArchivingLevel1024bytes =  4000000
storageUnit = dataset
tidyBlockSize = 500

# File checking properties
filesCheck.parallelCount = 5
filesCheck.gapSeconds = 5
filesCheck.lastIdFile = $HOME/icat/data/ids/lastIdFile
filesCheck.errorLog = $HOME/icat/data/ids/errorLog

# Link properties
linkLifetimeSeconds = 3600

# JMS Logging
log.list = READ WRITE

# Uncomment to permit configuration of logback
!logback.xml = ids.logback.xml

# JMS - uncomment and edit if needed
!jms.topicConnectionFactory = java:comp/DefaultJMSConnectionFactory" > $ICAT_INSTALL_DIR/ids.server/ids.properties 

cd $ICAT_INSTALL_DIR/ids.server
./setup configure
./setup install
cd $ICAT_INSTALL_DIR

#
# Create and load some test data
#

wget --no-verbose --no-clobber --directory-prefix=/vagrant https://raw.githubusercontent.com/icatproject/topcat/master/tools/lorum_facility_generator.rb

# Change the hard-coded root password in the script
sed -e '/password/ s/root/pw/g' /vagrant/lorum_facility_generator.rb > /vagrant/test_data_generator.rb

# Install a recent version of ruby in userspace (instructions from Jody)
curl -sSL https://get.rvm.io | bash
source $HOME/.rvm/scripts/rvm
rvm install 2.3.1
rvm use 2.3.1 --default
gem install faker rest-client

# Run the data creation script
ruby /vagrant/test_data_generator.rb
