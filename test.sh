#!/bin/sh

read -p "Node Name: " nodename
read -p "Database Password: " dbasepass

apt-get update && apt-get upgrade -y --force-yes && apt-get install -y --force-yes git  && cd /usr/src && git clone https://github.com/fusionpbx/fusionpbx-install.sh.git && chmod 755 -R /usr/src/fusionpbx-install.sh && cd /usr/src/fusionpbx-install.sh/debian

sed "s@echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' >> /etc/apt/sources.list.d/pgdg.list@#echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' >> /etc/apt/sources.list.d/pgdg.list@g" -i /usr/src/fusionpbx-install.sh/debian/resources/postgres.sh
sed "s@wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -@#wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -@g" -i /usr/src/fusionpbx-install.sh/debian/resources/postgres.sh
sed "s/\apt-get update && apt-get upgrade -y\/#nope/" -i /usr/src/fusionpbx-install.sh/debian/resources/postgres.sh
sed "s@apt-get install -y --force-yes sudo postgresql@#nope@" -i /usr/src/fusionpbx-install.sh/debian/resources/postgres.sh

sed "s@#echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main'  >> /etc/apt/sources.list.d/postgresql.list@echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main'  >> /etc/apt/sources.list.d/postgresql.list@g" -i /usr/src/fusionpbx-install.sh/debian/resources/postgres.sh
sed "s@#echo 'deb http://packages.2ndquadrant.com/bdr/apt/ jessie-2ndquadrant main' >> /etc/apt/sources.list.d/2ndquadrant.list@echo 'deb http://packages.2ndquadrant.com/bdr/apt/ jessie-2ndquadrant main' >> /etc/apt/sources.list.d/2ndquadrant.list@g" -i /usr/src/fusionpbx-install.sh/debian/resources/postgres.sh
sed "s@#/usr/bin/wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -@/usr/bin/wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -@g" -i /usr/src/fusionpbx-install.sh/debian/resources/postgres.sh
sed "s@#/usr/bin/wget --quiet -O - http://packages.2ndquadrant.com/bdr/apt/AA7A6805.asc | apt-key add -@/usr/bin/wget --quiet -O - http://packages.2ndquadrant.com/bdr/apt/AA7A6805.asc | apt-key add -@g" -i /usr/src/fusionpbx-install.sh/debian/resources/postgres.sh
sed "s@#apt-get update && apt-get upgrade -y@apt-get update && apt-get upgrade -y@" -i /usr/src/fusionpbx-install.sh/debian/resources/postgres.sh
sed "s@#apt-get install -y --force-yes sudo postgresql-bdr-9.4 postgresql-bdr-9.4-bdr-plugin postgresql-bdr-contrib-9.4@apt-get install -y --force-yes sudo postgresql-bdr-9.4 postgresql-bdr-9.4-bdr-plugin postgresql-bdr-contrib-9.4@" -i /usr/src/fusionpbx-install.sh/debian/resources/postgres.sh


cd /usr/src/fusionpbx-install.sh/debian && nano resources/postgres.sh
