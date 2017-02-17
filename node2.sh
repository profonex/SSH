#!/bin/bash

thisip=$(hostname -I | cut -d ' ' -f1)

read -p "Node Name: " nodename
read -p "Database Password: " dbasepass
read -p "Total Number of Nodes: " totalnode
echo "IP Address of this node is $thisip "


ip[1]=$thisip

nodenumber=$(($totalnode-1))
c=2
for i in $(seq $nodenumber);
do
    read -p "Node $(($i+1)) IP Address: " ipadd;
    eval ip[$(($i+1))]=$ipadd;
    c=$((c+1));
done

read -p "Node IP you want to connect to: " near_node
read -p "What is the FQDN of this Node: " domainname
read -p "Username for this Node: " username
read -p "Password for this Node: " userpass
read -p "What is your email address: " email_address

#database details
database_host=127.0.0.1
database_port=5432
database_username=fusionpbx

apt-get update && apt-get upgrade -y --force-yes && apt-get install -y --force-yes git  && cd /usr/src && git clone https://github.com/fusionpbx/fusionpbx-install.sh.git && chmod 755 -R /usr/src/fusionpbx-install.sh && cd /usr/src/fusionpbx-install.sh/debian

sed '16,19 s/^/#/' -i /usr/src/fusionpbx-install.sh/debian/resources/postgres.sh
sed '22,27 s/^#//' -i /usr/src/fusionpbx-install.sh/debian/resources/postgres.sh

 ./install.sh && rm /etc/fusionpbx/config.php

#echo 'deb http://packages.2ndquadrant.com/bdr/apt/ jessie-2ndquadrant main' > /etc/apt/sources.list.d/2ndquadrant.list
#wget --quiet -O - http://packages.2ndquadrant.com/bdr/apt/AA7A6805.asc | sudo apt-key add -
#sudo apt-get update
#sudo apt-get install -y postgresql-9.6-bdr-plugin

for i in $(seq $totalnode)
do
  iptables -A INPUT -j ACCEPT -p tcp --dport 5432 -s ${ip[$i]}/32
  iptables -A INPUT -j ACCEPT -p tcp --dport 8080 -s ${ip[$i]}/32
  iptables -A INPUT -j ACCEPT -p tcp --dport 4444 -s ${ip[$i]}/32
done
#answer the questions for iptables persistent
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections

sed -i /etc/postgresql/9.4/main/postgresql.conf -e s:'snakeoil.key:snakeoil-postgres.key:'
cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/ssl-cert-snakeoil-postgres.key
chown postgres:postgres /etc/ssl/private/ssl-cert-snakeoil-postgres.key
chmod 600 /etc/ssl/private/ssl-cert-snakeoil-postgres.key


cat >> /etc/postgresql/9.4/main/postgresql.conf << EOF
listen_addresses = '*'
shared_preload_libraries = 'bdr'
wal_level = 'logical'
track_commit_timestamp = on
max_connections = 200
max_wal_senders = 10
max_replication_slots = 10
# max_replication_slots maximum possible number is 48
# Make sure there are enough background worker slots for BDR to run
max_worker_processes = 20

# These aren't required, but are useful for diagnosing problems
#log_error_verbosity = verbose
#log_min_messages = debug1
#log_line_prefix = 'd=%d p=%p a=%a%q '

# Useful options for playing with conflicts
#bdr.default_apply_delay=2000   # milliseconds
#bdr.log_conflicts_to_table=on
#bdr.skip_ddl_replication = off
EOF

echo "host     all     all     127.0.0.1/32     trust" >> /etc/postgresql/9.4/main/pg_hba.conf

for i in $(seq $totalnode)
do
  echo "hostssl     all     all     ${ip[$i]}/32     trust" >> /etc/postgresql/9.4/main/pg_hba.conf
done

for i in $(seq $totalnode)
do
  echo "hostssl     replication     postgres     ${ip[$i]}/32     trust" >> /etc/postgresql/9.4/main/pg_hba.conf
done


systemctl daemon-reload
systemctl restart postgresql

export PGPASSWORD=$dbasepass

sudo -u postgres psql -c "ALTER USER fusionpbx WITH PASSWORD '$dbasepass';"
sudo -u postgres psql -c "ALTER USER freeswitch WITH PASSWORD '$dbasepass';"
sudo -u postgres psql -d fusionpbx -c "drop schema public cascade;"
sudo -u postgres psql -d fusionpbx -c "create schema public;"
sudo -u postgres psql -d fusionpbx -c "CREATE EXTENSION btree_gist;"
sudo -u postgres psql -d fusionpbx -c "CREATE EXTENSION bdr;"
sudo -u postgres psql -d freeswitch -c "CREATE EXTENSION btree_gist;"
sudo -u postgres psql -d freeswitch -c "CREATE EXTENSION bdr;"
sudo -u postgres psql -d fusionpbx -c "SELECT bdr.bdr_group_join(local_node_name := '$nodename', node_external_dsn := 'host=$thisip port=5432 dbname=fusionpbx connect_timeout=10 keepalives_idle=5 keepalives_interval=1', join_using_dsn := 'host=$near_node port=5432 dbname=fusionpbx connect_timeout=10 keepalives_idle=5 keepalives_interval=1');"
sudo -u postgres psql -d fusionpbx -c "SELECT bdr.bdr_node_join_wait_for_ready();"
sudo -u postgres psql -d freeswitch -c "SELECT bdr.bdr_group_join(local_node_name := '$nodename', node_external_dsn := 'host=$thisip port=5432 dbname=freeswitch connect_timeout=10 keepalives_idle=5 keepalives_interval=1', join_using_dsn := 'host=$near_node port=5432 dbname=freeswitch connect_timeout=10 keepalives_idle=5 keepalives_interval=1');"
sudo -u postgres psql -d freeswitch -c "SELECT bdr.bdr_node_join_wait_for_ready();"
sudo -u postgres psql -d fusionpbx -c "CREATE  EXTENSION pgcrypto;"
sudo -u postgres psql -d freeswitch -c "CREATE  EXTENSION pgcrypto;"


#add the config.php
#rm -R /etc/fusionpbx
#mkdir -p /etc/fusionpbx
chown -R www-data:www-data /etc/fusionpbx
cp /usr/src/fusionpbx-install.sh/debian/resources/fusionpbx/config.php /etc/fusionpbx
sed -i /etc/fusionpbx/config.php -e s:'{database_username}:fusionpbx:'
sed -i /etc/fusionpbx/config.php -e s:"{database_password}:$dbasepass:"


#add the database schema
cd /var/www/fusionpbx && php /var/www/fusionpbx/core/upgrade/upgrade_schema.php > /dev/null 2>&1


#get the ip address
domain_name=$domainname

#get a domain_uuid
domain_uuid=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);

#add the domain name
psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_domains (domain_uuid, domain_name, domain_enabled) values('$domain_uuid', '$domain_name', 'true');"

#app defaults
cd /var/www/fusionpbx && php /var/www/fusionpbx/core/upgrade/upgrade_domains.php

#add the user
user_uuid=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
user_salt=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
user_name=admin
user_password=$userpass
password_hash=$(php -r "echo md5('$user_salt$user_password');");
psql --host=$database_host --port=$database_port --username=$database_username -t -c "insert into v_users (user_uuid, domain_uuid, username, password, salt, user_enabled) values('$user_uuid', '$domain_uuid', '$user_name', '$password_hash', '$user_salt', 'true');"

#get the superadmin group_uuid
group_uuid=$(psql --host=$database_host --port=$database_port --username=$database_username -t -c "select group_uuid from v_groups where group_name = 'superadmin';");
group_uuid=$(echo $group_uuid | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')

#add the user to the group
group_user_uuid=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
group_name=superadmin
psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_group_users (group_user_uuid, domain_uuid, group_name, group_uuid, user_uuid) values('$group_user_uuid', '$domain_uuid', '$group_name', '$group_uuid', '$user_uuid');"

#update xml_cdr url, user and password
xml_cdr_username=$(dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 | sed 's/[=\+//]//g')
xml_cdr_password=$(dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 | sed 's/[=\+//]//g')
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_http_protocol}:http:"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{domain_name}:127.0.0.1:"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_project_path}::"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_user}:$xml_cdr_username:"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_pass}:$xml_cdr_password:"

#app defaults
cd /var/www/fusionpbx && php /var/www/fusionpbx/core/upgrade/upgrade_domains.php

#restart freeswitch
/bin/systemctl daemon-reload
/bin/systemctl restart freeswitch



cd /usr/src
git clone https://github.com/fusionpbx/fusionpbx-apps 
cp -R fusionpbx-apps/bdr /var/www/fusionpbx/app
chown -R www-data:www-data /var/www/fusionpbx/app/bdr

mkdir -p /etc/fusionpbx/resources/templates/
cp -R /var/www/fusionpbx/resources/templates/provision /etc/fusionpbx/resources/templates
chown -R www-data:www-data /etc/fusionpbx


sh -c 'echo "deb http://linux-packages.getsync.com/btsync/deb btsync non-free" > /etc/apt/sources.list.d/btsync.list'
wget -qO - https://linux-packages.resilio.com/resilio-sync/key.asc | sudo apt-key add -
apt-get update
apt-get install btsync

sed -i '8,9s/btsync/www-data/' /lib/systemd/system/btsync.service
sed -i '15s/btsync:btsync/www-data:www-data/' /lib/systemd/system/btsync.service

chown -R www-data:www-data /var/lib/btsync
systemctl daemon-reload
systemctl restart btsync
systemctl enable btsync

#remove previous install
rm -R /opt/letsencrypt
rm -R /etc/letsencrypt

#enable fusionpbx nginx config
cp /usr/src/fusionpbx-install.sh/debian/resources/nginx/fusionpbx /etc/nginx/sites-available/fusionpbx
#ln -s /etc/nginx/sites-available/fusionpbx /etc/nginx/sites-enabled/fusionpbx

#read the config
/usr/sbin/nginx -t && /usr/sbin/nginx -s reload

#install letsencrypt
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
chmod 755 /opt/letsencrypt/certbot-auto
/opt/letsencrypt/./certbot-auto
mkdir -p /etc/letsencrypt/configs
mkdir -p /var/www/letsencrypt/

#cd $pwd
#cd "$(dirname "$0")"

#copy the domain conf
cp /usr/src/fusionpbx-install.sh/debian/resources/letsencrypt/domain_name.conf /etc/letsencrypt/configs/$domain_name.conf

#update the domain_name and email_address
sed "s#{domain_name}#$domain_name#g" -i /etc/letsencrypt/configs/$domain_name.conf
sed "s#{email_address}#$email_address#g" -i /etc/letsencrypt/configs/$domain_name.conf

#letsencrypt
#sed "s@#letsencrypt@location /.well-known/acme-challenge { root /var/www/letsencrypt; }@g" -i /etc/nginx/sites-available/fusionpbx

#get the certs from letsencrypt
cd /opt/letsencrypt && ./letsencrypt-auto --config /etc/letsencrypt/configs/$domain_name.conf certonly

#update nginx config
sed "s@ssl_certificate         /etc/ssl/certs/nginx.crt;@ssl_certificate /etc/letsencrypt/live/$domain_name/fullchain.pem;@g" -i /etc/nginx/sites-available/fusionpbx
sed "s@ssl_certificate_key     /etc/ssl/private/nginx.key;@ssl_certificate_key /etc/letsencrypt/live/$domain_name/privkey.pem;@g" -i /etc/nginx/sites-available/fusionpbx

#read the config
/usr/sbin/nginx -t && /usr/sbin/nginx -s reload

#combine the certs into all.pem
cat /etc/letsencrypt/live/$domain_name/cert.pem > /etc/letsencrypt/live/$domain_name/all.pem
cat /etc/letsencrypt/live/$domain_name/privkey.pem >> /etc/letsencrypt/live/$domain_name/all.pem
cat /etc/letsencrypt/live/$domain_name/chain.pem >> /etc/letsencrypt/live/$domain_name/all.pem

#copy the certs to the switch tls directory
mkdir -p /etc/freeswitch/tls
cp /etc/letsencrypt/live/$domain_name/*.pem /etc/freeswitch/tls
cp /etc/freeswitch/tls/all.pem /etc/freeswitch/tls/wss.pem
chown -R www-data:www-data /etc/freeswitch
